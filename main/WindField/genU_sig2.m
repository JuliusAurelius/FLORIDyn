function [U_abs,U_ang,pos] = genU_sig2(len)
% GENU_SIG creates a vector with wind speed measurements at different
% locations in the field.
%
% INPUT
% len   := int; Number of time steps
%
% OUTPUT
% U_abs := [n x m] vec; n Measurements at m places of the wind velocity 
% U_ang := [n x m] vec; n Measurements at m places of the wind angle 
% pos   := [m x 2] vec; m (x,y) positions of the measurements
%

U_free = 13;
% In Deg
%phi = [90,95,110,105];
phi = [90,90,90,90];
pos = [...
    -100,100;...
    1000,100;...
    -100,2000;...
    1000,2000];

numSensors = size(pos,1);

phi = phi./180*pi;

% Save absolute values and angle
U_abs = ones(len,numSensors).*U_free;
U_ang = zeros(size(U_abs));
u_change = linspace(90,82,3)';
offset = 2;
for i = 1:4
    U_ang(1:100+i*offset,i)=u_change(1);
    U_ang(101+i*offset:101+length(u_change)-1+i*offset,i)=u_change;
    U_ang(101+length(u_change)-1+i*offset:end,i)=u_change(end);
end
U_ang = U_ang./180.*pi;
U_ang = repmat(phi,len,1);
end