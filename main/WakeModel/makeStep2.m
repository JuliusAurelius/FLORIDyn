function [op_pos, op_dw, op_u, u_t]=makeStep2(op_pos, op_dw, op_ayaw, op_t_id, op_U, op_I, chainList, cl_dstr, tl_pos, tl_D, timeStep)
% MAKESTEP2 calculates all values necessary to propagate the wind field.
%   It calculates the crosswind position of the OPs, the reduction and the
%   foreign influence. With that information the downwind step can be
%   calculated.
%   With the new downwind position comes a new crosswind position. The
%   function returns the vector describing the down- and crosswind movement
%   of all observation points. It also extracts the wind speed at the rotor
%   planes.
%
% INPUT
% OP Data
%   op_pos      := [n x 3] vec; [x,y,z] world coord. (can be nx2)
%   op_dw       := [n x 1] vec; downwind position
%   op_r        := [n x 2] vec; [r_own, r_turbine]
%   op_ayaw     := [n x 2] vec; axial induction factor and yaw (wake coord.)
%   op_t_id     := [n x 1] vec; Turbine op belongs to
%   op_U        := [n x 2] vec; Uninfluenced wind vector at OP position
%
% Chain Data
%   chainList   := [n x 1] vec; (see at the end of the function)
%   cl_dstr     := [n x 1] vec; Distribution relative to the wake width
%
% Turbine Data
%   tl_pos      := [m x 3] vec; [x,y,z] world coord. (can be nx2)
%   tl_D        := [m x 1] vec; Turbine diameter
%
% OUTPUT
% op_pos        := [n x 3] vec; [x,y,z] world coord. (can be nx2)
% op_dw         := [n x 1] vec; downwind position
% u_t           := [m x 1] vec; Effective wind speeds at the turbines
%
% SOURCES
% [1] Experimental and theoretical study of wind turbine wakes in yawed
%     conditions - M. Bastankhah and F. Porté-Agel
% [2] Design and analysis of a spatially heterogeneous wake - A. Farrell,
%     J. King et al.
% ======================================================================= %
% AUTHOR: M. Becker                                                       %
% DATE  : 01.09.2020 (ddmmyyyy)                                           %
% ======================================================================= %
%% Vars
% Factor for sig of gaussian function
w = 6;

op_r = zeros(length(op_dw),1);
op_D = tl_D(op_t_id);
op_c = getChainIDforOP(chainList);
yaw  = op_ayaw(:,2);
% 1 if three dimentions, 0 if only 2
threeDim = mod(size(op_pos,2),2);
%% Get wake width
[sig_y, sig_z, C_T, x_0, delta, pc_y, pc_z] = ...
    getBastankhahVars2(op_dw, op_ayaw, op_I, op_D);

% Sigma of Gauss functions + Potential core
%   both values are already adapted to near/far field
width_y = w*sig_y + pc_y;
width_z = w*sig_z + pc_z;

%% Get the distribution of the OPs
cw_y = width_y.*cl_dstr(op_c,1);

if threeDim
    cw_z= width_z.*cl_dstr(op_c,2);
else
    cw_z = zeros(size(cw_y));
end

% create an radius value of the core and cw values and figure out if the
% OPs are in the core or not
phi_cw  = atan2(cw_z,cw_y);
r_cw    = sqrt(cw_y.^2+cw_z.^2);
core    = or(...
    r_cw < abs(cos(phi_cw).*pc_y*0.5 + sin(phi_cw).*pc_z*0.5),...
    op_dw==0);

%% Get speed reduction
op_r(core) = 1-sqrt(1-C_T(core));

% Remove core from crosswind pos and calculate speed reduction
nw = op_dw<x_0;
fw = ~nw;
gaussAbs = zeros(size(core));

gaussAbs(nw) = 1-sqrt(1-C_T(nw));
gaussAbs(fw) = 1-sqrt(1-C_T(fw)...
    .*cos(yaw(fw))./(8*(sig_y(fw).*sig_z(fw)./op_D(fw).^2)));
op_r(~core) = gaussAbs(~core).*...
    exp(-0.5.*((cw_y(~core)-cos(phi_cw(~core)).*pc_y(~core)*0.5)./sig_y(~core)).^2).*...
    exp(-0.5.*((cw_z(~core)-sin(phi_cw(~core)).*pc_z(~core)*0.5)./sig_z(~core)).^2);

%% Get forgeign influence
% Go through all turbines and use their points in scattered interpolant
r_f = ones(size(op_r)); % == prod((1-r)(1-r)...)



%% Calculate speed
% Windspeed at every OP WITHOUT own wake (needed for turbine windspeed)
op_u = r_f.*op_U;
% Calculate downwind step and add it to the real world coordinates and
% downwind position
dw_step = (1-op_r).*op_u*timeStep;
op_pos(:,1:2) = op_pos(:,1:2) + dw_step;
op_dw = op_dw + sqrt(dw_step(:,1).^2 + dw_step(:,2).^2);

%% Get new wake width
% Save old values
delta_old = delta;
cw_y_old  = cw_y;
cw_z_old  = cw_z;

% Get new values
[sig_y, sig_z, ~, ~, delta, pc_y, pc_z] = ...
    getBastankhahVars2(op_dw, op_ayaw, op_I, op_D);

% Sigma of Gauss functions + Potential core
%   both values are already adapted to near/far field
width_y = w*sig_y + pc_y;
width_z = w*sig_z + pc_z;
%% Get new distribution of the OPs
cw_y = width_y.*cl_dstr(op_c,1);

if threeDim
    cw_z= width_z.*cl_dstr(op_c,2);
else
    cw_z = zeros(size(cw_y));
end
%% Calculate difference and apply step to the world coordinates
% Get wind angle 
ang = atan2(op_U(:,2),op_U(:,1));

% Now also add the deflection offset
diff_cw_y = cw_y + delta - cw_y_old - delta_old;

% Apply y-crosswind step relative to the wind angle
op_pos(:,1) = op_pos(:,1) - sin(ang).*diff_cw_y;
op_pos(:,2) = op_pos(:,2) + cos(ang).*diff_cw_y;

if threeDim
    diff_cw_z = cw_z - cw_z_old;
    op_pos(:,3) = op_pos(:,3) + diff_cw_z;
end

%% Extract the windspeed at the rotorplane
% op_u has all speeds of the OPs, the speed of the first ones of the chains
% need to be weighted summed by the area they represent.
%   Needs to happen BEFORE own reduction is applied. For the down wind step
%   it was applied seperately
u_t = getTurbineWindSpeed(op_u,chainList,tl_D);

%% Apply own reduction to speed vector
op_u = op_u.*(1-op_r);
end

function width = getWakeWidth()
% GETWAKEWIDTH calculates the width of the near and far wake at the given
% down wind positions
end