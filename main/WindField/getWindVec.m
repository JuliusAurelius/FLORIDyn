function U = getWindVec(pos,timeStep,U_sig)
% GETWINDVEC returns a free wind vector (== speed and direction) for the
% position(s) given as a [x,y] vector
%
% INPUT
% pos   := [n x 3] Vector with postions [x,y,z]// World coordinates
% pos   := [n x 2] Vector with postions [x,y]  // World coordinates
% timeStep := int Index of the current entry in U_sig
% U_sig := [n x 2] Vector which lasts the entire simulation and provides a
%                   wind vector
%
% OUTPUT
% U  	:= [n x 2] vector with the [Ux, Uy] velocities

% ========================= TODO ========================= 
% ///////////////////////// LINK Wind Dir  //////////

%windspeed = @(x) [x(1) 0;0 x(2)]*x;
%U = windspeed(pos');

% off = [0,-10,-15,-30];
% x = [0, 1000, 0, 1000];
% y = [0, 0, 2000, 2000];

off = [0,0,0];
x = [0, 1000, 0];
y = [0, 2000,2000];

k = off+timeStep;
k(k<2) = 2;         % Starts at 2 because the old value is used as well

U_meas = PT1(k,U_sig);

Fx = scatteredInterpolant(x',y',U_meas(:,1),'linear','nearest');
Fy = scatteredInterpolant(x',y',U_meas(:,2),'linear','nearest');

U = zeros(size(pos,1),2);
U(:,1) = Fx(pos(:,1:2));
U(:,2) = Fy(pos(:,1:2));
% MaxSpeed = 8;
% phi = 30/180*pi;
% 
% 
% U_tmp = ([cos(phi) -sin(phi);sin(phi),cos(phi)]*[MaxSpeed;0])';
% U = repmat(U_tmp,size(pos,1),1);
end

% U(:,1) = MaxSpeed*(cos(pos(:,2)'*pi/9000))';
% U(:,2) = MaxSpeed*(sin(pos(:,1)'*pi/600))';
%{
Maybe this should be coded object oriented...
%}
function U = PT1(timeStep,U_sig)

deltaT  = 1;     % Hard coded fix
T       = 80;
K       = 1;

U = 1/(T/deltaT + 1)*(K*U_sig(timeStep,:) + T/deltaT*U_sig(timeStep-1,:));
end