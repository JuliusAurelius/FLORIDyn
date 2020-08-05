function [U_abs,U_ang,pos] = genU_sig2(len)
% GENU_SIG creates a vector with wind speed measurements at different
% locations in the field.
%
% INPUT
% len   := int; Number of time steps
%
% OUTPUT
% U_x   := [n x m] vec; n Measurements at m places of the x wind velocity 
% U_y   := [n x m] vec; n Measurements at m places of the y wind velocity 
% pos   := [m x 2] vec; m (x,y) positions of the measurements
%

U_free = 13;
% In Deg
phi = [110,105,85,105];
pos = [...
    -100,100;...
    1000,100;...
    -100,2000;...
    1000,2000];

numSensors = size(pos,1);

phi = phi./180*pi;

% Save absolute values and angle
U_abs = ones(len,numSensors).*U_free;
U_ang = repmat(phi,len,1);

end