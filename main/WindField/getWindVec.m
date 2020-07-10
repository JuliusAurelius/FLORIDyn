function U = getWindVec(pos)
% GETWINDVEC returns a free wind vector (== speed and direction) for the
% position(s) given as a [x,y] vector
%
% INPUT
% pos   := [n x 3] vector with postions [x,y,z]// World coordinates
% pos   := [n x 2] vector with postions [x,y]  // World coordinates
% 
%
% OUTPUT
% U  	:= [n x 2] vector with the [Ux, Uy] velocities

% ========================= TODO ========================= 
% ///////////////////////// LINK Wind Dir  //////////

%windspeed = @(x) [x(1) 0;0 x(2)]*x;
%U = windspeed(pos');

U = zeros(size(pos,1),2);

MaxSpeed = 8;
phi = 0/180*pi;


U_tmp = ([cos(phi) -sin(phi);sin(phi),cos(phi)]*[MaxSpeed;0])';
U = repmat(U_tmp,size(pos,1),1);
end

% U(:,1) = MaxSpeed*(cos(pos(:,2)'*pi/9000))';
% U(:,2) = MaxSpeed*(sin(pos(:,1)'*pi/600))';