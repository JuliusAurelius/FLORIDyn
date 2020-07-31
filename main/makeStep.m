function [op_pos, op_dw, op_u, u_t]=makeStep(op_pos, op_dw, op_ayaw, op_t_id, op_U, chainList, cl_dstr, tl_pos, tl_D, timeStep)
% MAKESTEP calculates all values necessary to propagate the wind field.
%   It calculates the crosswind position of the OPs, the reduction and the
%   foreign influence. With that information the downwind step can be
%   calculated.
%   With the new downwind position comes a new crosswind position. The
%   function returns the vector describing the down- and crosswind movement
%   of all observation points. It also extracts the wind speed at the rotor
%   planes.
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
%% Init Variables
op_r = zeros(length(op_dw),1);
op_I = ones(size(op_r))*1;               % NEEDS TO BE IMPLEMENTED AS STATE
op_D = tl_D(op_t_id);

% Get variables from the Bastankhah model
[sig_y, sig_z, C_T, Theta, k_y, k_z, x_0] = getBastankhahVars(...
    op_dw, op_ayaw, op_I, op_D);

% For better readability (lol)
yaw = op_ayaw(:,2);

%[1] Eq. 7.4
delta = Theta.*x_0./op_D+...            
    Theta/14.7.*sqrt(cos(yaw)./(k_y.*k_z.*C_T)).*...
    (2.9+1.3*sqrt(1-C_T)-C_T).*log(...
    ((1.6+sqrt(C_T)).*...
    (1.6*sqrt((8*sig_y.*sig_z)./(op_D.^2.*cos(yaw))))-sqrt(C_T))./...
    ((1.6-sqrt(C_T)).*...
    (1.6*sqrt((8*sig_y.*sig_z)./(op_D.^2.*cos(yaw))))+sqrt(C_T))...
    );
delta = delta.*op_D;
%% Calculate the crosswind position
op_c = getChainIDforOP(chainList);
threeDim = 1;
width_factor = 1;
if size(op_pos,2)==2
    threeDim = 0;
end
cw_y = width_factor*sig_y .* cl_dstr(op_c,1);
if threeDim ==1
    cw_z = width_factor*sig_z .* cl_dstr(op_c,2);
else
    cw_z = zeros(size(cw_y));
end


%% Get the reduction factor
% nearWake / far wake border
nw = (op_dw-x_0)<0;
fw = ~nw;
op_r(fw) = (1-sqrt(1-C_T(fw).*cos(yaw(fw))./(8*(sig_y(fw).*sig_z(fw)./op_D(fw).^2)))).*...
    exp(-0.5*((cw_y(fw)-delta(fw))./sig_y(fw)).^2).*...
    exp(-0.5*((cw_z(fw)-delta(fw))./sig_z(fw)).^2);     %[1] Eq. 7.1
op_r(nw) = sqrt(1-C_T(nw));
% Maybe u = (1-r)U
%% Get the foreign influence
%TODO
r_f = ones(size(op_r));

%% Calculate the downwind step
% Windspeed at every OP (also needed for turbine windspeed)
op_u = (1-op_r).*r_f.*op_U;

dw_step = op_u*timeStep;
op_pos(:,1:2) = op_pos(:,1:2) + dw_step;
op_dw = op_dw + sqrt(dw_step(:,1).^2 + dw_step(:,2).^2);
%% Calculate the new crosswind position
[sig_y, sig_z, ~, ~, ~, ~, ~] = getBastankhahVars(...
    op_dw, op_ayaw, op_I, op_D);
cw_y_new = width_factor*sig_y .* cl_dstr(op_c,1);

delta_cw_y = cw_y_new-cw_y;

ang = atan2(op_U(:,2),op_U(:,1));

op_pos(:,1) = op_pos(:,1) - sin(ang).*delta_cw_y;
op_pos(:,2) = op_pos(:,2) + cos(ang).*delta_cw_y;

if size(op_pos,2)==3
    cw_z_new = width_factor*sig_z .* cl_dstr(op_c,2);
    delta_cw_z = cw_z_new-cw_z;
    op_pos(:,3) = op_pos(:,3) + delta_cw_z;
end
%% Extract the windspeed at the rotorplane
% op_u has all speeds of the OPs, the speed of the first ones of the chains
% need to be weighted summed by the area they represent.
u_t = ones(size(tl_D));
end

function op_c = getChainIDforOP(chainList)
% A for loop :(
op_c = zeros(sum(chainList(:,3)),1);
for i = 1:size(chainList,1)-1
    op_c(chainList(i,2):chainList(i+1,2)-1) = i;
end
op_c(chainList(end,2):end)=size(chainList,1);
end

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
%   tl_pos      := [n x 3] vec; [x,y,z] world coord. (can be nx2)
%   tl_D        := [n x 1] vec; Turbine diameter
%   tl_ayaw     := [n x 2] vec; axial induction factor and yaw (world coord.)
%   tl_U        := [n x 2] vec; Wind vector [Ux,Uy] (world coord.)