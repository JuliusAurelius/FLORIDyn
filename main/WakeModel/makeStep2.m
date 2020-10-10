function [OP, T]=makeStep2(OP, chain, T, Sim)
% MAKESTEP2 calculates all values necessary to propagate the wind field.
%   It calculates the crosswind position of the OPs, the reduction and the
%   foreign influence. With that information the downwind step can be
%   calculated.
%   With the new downwind position comes a new crosswind position. The
%   function returns the updated OP struct.
%   It also extracts the effective wind speed at the rotor planes.
% ======================================================================= %
% INPUT
%   OP          := Struct;    Data related to the state of the OPs
%    .pos       := [nx3] vec; [x,y,z] world coord. (can be nx2)
%    .dw        := [nx1] vec; downwind position (wake coordinates)
%    .yaw       := [nx1] vec; yaw angle (wake coord.) at the time of creat.
%    .Ct        := [nx1] vec; Ct coefficient at the time of creation
%    .t_id      := [nx1] vec; Turbine OP belongs to
%    .U         := [nx2] vec; Uninfluenced wind vector at OP position
%    .u         := [nx1] vec; Effective wind speed at OP position
%
%   chain       := Struct;    Data related to the OP management / chains
%    .NumChains := int;       Number of Chains per turbine
%    .Length    := int/[nx1]; Length of the Chains - either uniform for all
%                             chains or individually set for every chain.
%    .List      := [nx5] vec; [Offset, start_id, length, t_id, relArea]
%    .dstr      := [nx2] vec; Relative y,z distribution of the chain in the
%                             wake, factor multiplied with the width, +-0.5
%
%   T           := Struct;    All data related to the turbines
%    .pos       := [nx3] mat; x & y positions and nacelle height for all n
%                             turbines.
%    .D         := [nx1] vec; Diameter of all n turbines
%    .yaw       := [nx1] vec; Yaw setting of the n turbines
%    .Ct        := [nx1] vec; Current Ct of the n turbines
%    .Cp        := [nx1] vec; Current Cp of the n turbines
%    .U         := [nx2] vec; Wind vector for the n turbines
%    .u         := [nx1] vec; Effective wind speed at the rotor plane
%
%   Sim
%    .Duration  := double;    Duration of the Simulation in seconds
%    .TimeStep  := double;    Duration of one time step
%    .TimeSteps := [1xt] vec; All time steps
%    .NoTimeSteps= int;       Number of time steps
%    .FreeSpeed := bool;      OPs traveling with free wind speed or own
%                             speed
%    .WidthFactor= double;    Multiplication factor for the field width
%    .Interaction= bool;      Whether the wakes interact with each other
% ======================================================================= %
% OUTPUT
%   OP          := Struct;    Data related to the state of the OPs
%    .pos       := [nx3] vec; [x,y,z] world coord. (can be nx2)
%    .dw        := [nx1] vec; downwind position (wake coordinates)
%    .yaw       := [nx1] vec; yaw angle (wake coord.) at the time of creat.
%    .Ct        := [nx1] vec; Ct coefficient at the time of creation
%    .t_id      := [nx1] vec; Turbine OP belongs to
%    .U         := [nx2] vec; Uninfluenced wind vector at OP position
%    .u         := [nx2] vec; Effective wind vector at OP position
%
%   T           := Struct;    All data related to the turbines
%    .pos       := [nx3] mat; x & y positions and nacelle height for all n
%                             turbines.
%    .D         := [nx1] vec; Diameter of all n turbines
%    .yaw       := [nx1] vec; Yaw setting of the n turbines
%    .Ct        := [nx1] vec; Current Ct of the n turbines
%    .Cp        := [nx1] vec; Current Cp of the n turbines
%    .U         := [nx2] vec; Wind vector for the n turbines
%    .u         := [nx1] vec; Effective wind speed at the rotor plane
% ======================================================================= %
% SOURCES
% [1] Experimental and theoretical study of wind turbine wakes in yawed
%     conditions - M. Bastankhah and F. Porté-Agel
% [2] Design and analysis of a spatially heterogeneous wake - A. Farrell,
%     J. King et al.
% ======================================================================= %
%% Vars
% Factor for sig of gaussian function
w    = Sim.WidthFactor;
OP_r = zeros(length(OP.dw),1);
D    = T.D(OP.t_id);
OP_c = getChainIDforOP(chain.List);
yaw  = OP.yaw;

%% Get wake width
[sig_y, sig_z, C_T, x_0, delta, pc_y, pc_z] = getBastankhahVars3(OP, D);

try
[nw, cw_y, cw_z, core, phi_cw]=...
     getCWPosition(OP.dw, w, chain.dstr, OP_c, sig_y, sig_z, pc_y, pc_z, x_0);
catch
    disp('err')
end

%% Get speed reduction
OP_r(core) = 1-sqrt(1-C_T(core));

% Remove core from crosswind pos and calculate speed reduction
%nw = OP.dw<x_0;
fw = ~nw;
gaussAbs = zeros(size(core));

gaussAbs(nw) = 1-sqrt(1-C_T(nw));
gaussAbs(fw) = 1-sqrt(1-C_T(fw)...
    .*cos(yaw(fw))./(8*(sig_y(fw).*sig_z(fw)./D(fw).^2)));
OP_r(~core) = gaussAbs(~core).*...
    exp(-0.5.*((cw_y(~core)-cos(phi_cw(~core)).*pc_y(~core)*0.5)./sig_y(~core)).^2).*...
    exp(-0.5.*((cw_z(~core)-sin(phi_cw(~core)).*pc_z(~core)*0.5)./sig_z(~core)).^2);

%% Get forgeign influence
if Sim.Interaction
    % Calculate foreign influence
    r_f = getForeignInfluence(OP.pos, OP_r, OP.t_id, length(T.D));
else
    % Foreign influence ignored
    r_f = ones(size(OP_r));
end

%% Calculate speed
% Windspeed at every OP WITHOUT own wake (needed for turbine windspeed)
OP.u = r_f.*OP.U;

%% Extract the windspeed at the rotorplane
% OP.u has all speeds of the OPs, the speed of the first ones of the chains
% need to be weighted summed by the area they represent.
%   Needs to happen BEFORE own reduction is applied. For the down wind step
%   it was applied seperately
T.u = getTurbineWindSpeed(OP.u,chain.List,T.D);

%% Down wind step
% Calculate downwind step, based on the simulation settings, the OPs travel
% at their effective speed u or at the uninfluenced wind speed U.

if Sim.FreeSpeed
    % Frozen turbulence hypothesis
    %   All OPs travel with free wind speed
    dw_step = OP.U*Sim.TimeStep;
else
    % OPs travel with their effective wind speed
    dw_step = (1-OP_r).*OP.u*Sim.TimeStep;
end

% Apply the down wind step to the x,y world coordinates and the down wind
% location
OP.pos(:,1:2) = OP.pos(:,1:2) + dw_step;
OP.dw = OP.dw + sqrt(dw_step(:,1).^2 + dw_step(:,2).^2);

%% Get new wake width
% Save old values
delta_old = delta;
cw_y_old  = cw_y;
cw_z_old  = cw_z;

% Get new values
[sig_y, sig_z, ~, ~, delta, pc_y, pc_z] = getBastankhahVars3(OP, D);

[~, cw_y, cw_z, ~, ~]=...
    getCWPosition(OP.dw, w, chain.dstr, OP_c, sig_y, sig_z, pc_y, pc_z, x_0);
 
%% Calculate difference and apply step to the world coordinates
OP.pos = updatePosition(...
    OP.pos, OP.U, cw_y, cw_z, cw_y_old, cw_z_old, delta, delta_old);

%% Apply own reduction to speed vector
OP.u = OP.u.*(1-OP_r);
end
%% ===================================================================== %%
% = Reviewed: 2020.09.29 (yyyy.mm.dd)                                   = %
% === Author: Marcus Becker                                             = %
% == Contact: marcus.becker.mail@gmail.com                              = %
% ======================================================================= %