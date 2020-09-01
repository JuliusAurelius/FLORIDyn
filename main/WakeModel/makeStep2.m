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
w = 1;

op_r = zeros(length(op_dw),1);
op_D = tl_D(op_t_id);

%% Get wake width

%% Get the distribution of the OPs

%% Get speed reduction

%% Get forgeign influence

%% Calculate speed

%% Update down wind position

%% Get new wake width

%% Get new distribution of the OPs

%% Calculate difference

%% Apply step to the world coordinates
end

function width = getWakeWidth()
% GETWAKEWIDTH calculates the width of the near and far wake at the given
% down wind positions
end