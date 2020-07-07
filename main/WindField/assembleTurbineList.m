function [tl_pos,tl_d,tl_ayaw,tl_U] = assembleTurbineList(layout,varargin)
%assembleTurbineList creates list of turbines with their properties
%   Sets the number, position, height and diameter, but also stores the yaw
%   and axial induction factor of the controller, along with the current
%   Power output
%
% INPUT
%   layout  := to be defined (probably name or id)
%
%======================== Structure ======================================%
% Turbine list
% [world        world   world  ]
% [x,y,z,   D,  a,yaw,  Ux,Uy P]
% [1,2,3,   4,   5,6     7,8  9]
%=========================================================================%
T_num = 6;
D=160;


T_Pos = [...
                0 0 90 D;...
                3*D 0 90 D;...
                3*D 6*D 90 D;...
                0 6*D 90 D;...
                3*D 12*D 90 D;...
                0 12*D 90 D];
T_D = ones(T_num,1)*D;

tl_pos  = T_Pos(1:layout,1:3);             %<--- 2D / 3D change
tl_d    = T_D(1:layout,:);
tl_ayaw = zeros(layout,2);
tl_U    = ones(layout,2);

end

%% NEEDS TO BE FILLED WITH PROPER WINDFARMS