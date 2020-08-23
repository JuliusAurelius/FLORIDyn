function tl_ayaw = controller(tl_pos,tl_D,tl_ayaw,tl_U)
% CONTROLLER delivers the axial induction factor and yaw for each turbine
%
% INPUT
% Turbine Data
%   tl_pos      := [n x 3] vec; [x,y,z] world coord. (can be nx2)
%   tl_D        := [n x 1] vec; Turbine diameter
%   tl_ayaw     := [n x 2] vec; axial induction factor and yaw (world coord.)
%   tl_U        := [n x 2] vec; Wind vector [Ux,Uy] (world coord.)
%
% OUTPUT
%   tl_ayaw     := [n x 2] vec; new axial induction factor and yaw (world coord.)

persistent k
if isempty(k)
    k = 0;
else
    k = k+1;
end

% Current implementation follows the wind angle and sets a to 0.3
%yaw = atan2(tl_U(:,2),tl_U(:,1))- 0/180*pi + sin(k*1/(2*pi)*0)*30/180*pi;


yaw = atan2(tl_U(:,2),tl_U(:,1)) + [30;20;0]./180*pi;
tl_ayaw = [ones(size(tl_D))*0.3, yaw]; % TODO Placeholder
end