function [tl_pos,tl_D,tl_ayaw,tl_U] = assembleTurbineList(layout,varargin)
%assembleTurbineList creates list of turbines with their properties
%   Sets the number, position, height and diameter, but also stores the yaw
%   and axial induction factor of the controller, along with the current
%   Power output
%
% INPUT
%   layout  := to be defined (probably name or id)
%
% OUTPUT
% Turbine Data
%   tl_pos      := [n x 3] vec; [x,y,z] world coord. (can be nx2)
%   tl_D        := [n x 1] vec; Turbine diameter
%   tl_ayaw     := [n x 2] vec; axial induction factor and yaw (world coord.)
%   tl_U        := [n x 2] vec; Wind vector [Ux,Uy] (world coord.)

T_num = 6;
D=160;

Dim = 3;             %<--- 2D / 3D change

T_Pos = [...
                0 0 90 D;...
                3*D 0 90 D;...
                3*D 6*D 90 D;...
                0 6*D 90 D;...
                3*D 12*D 90 D;...
                0 12*D 90 D];
T_D = ones(T_num,1)*D;

tl_pos  = T_Pos(1:layout,1:Dim);
tl_D    = T_D(1:layout,:);
tl_ayaw = zeros(layout,2);
tl_U    = ones(layout,2);

end

%% NEEDS TO BE FILLED WITH PROPER WINDFARMS