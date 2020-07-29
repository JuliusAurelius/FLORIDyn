function [delta_dw, delta_cw, u_t]=makeStep(op_pos, op_dw, op_ayaw, op_t_id, op_U, chainList, cl_dstr, tl_pos, tl_D)
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
% delta_dw      := [n x 1] vec; Step into the downwind direction
% delta_cw      := [n x 1] vec; Step into crosswind direction  //2D
% delta_cw      := [n x 2] vec; Step into crosswind directions //3D
% u_t           := [m x 1] vec; Effective wind speeds at the turbines
%
% SOURCES
% [1] Experimental and theoretical study of wind turbine wakes in yawed
%     conditions - M. Bastankhah and F. Porté-Agel
% [2] Design and analysis of a spatially heterogeneous wake - A. Farrell,
%     J. King et al.
%% Init Variables
op_r = zeros(length(op_dw),1);
op_I = zeros(size(op_r));               % NEEDS TO BE IMPLEMENTED AS STATE
op_D = tl_D(op_t_id);
[sig_y, sig_z, C_T, Theta, k_y, k_z, x_0] = getBastankhahVars(...
    op_dw, op_ayaw, op_I, op_D);
yaw = op_ayaw(:,2);
delta = Theta.*x_0./op_D+...
    Theta/14.7.*sqrt(cos(yaw)./(k_y.*k_z.*C_T)).*...
    (2.9+1.3*sqrt(1-C_T)-C_T).*ln(...
    ((1.6+sqrt(C_T)).*...
    (1.6*sqrt((8*sig_y.*sig_z)./(op_D.^2.*cos(yaw))))-sqrt(C_T))./...
    ((1.6-sqrt(C_T)).*...
    (1.6*sqrt((8*sig_y.*sig_z)./(op_D.^2.*cos(yaw))))+sqrt(C_T))...
    );
%% Calculate the crosswind position


%% Get the reduction factor


%% Get the foreign influence

%% Calculate the downwind step

%% Calculate the new crosswind position

%% Extract the windspeed at the rotorplane

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