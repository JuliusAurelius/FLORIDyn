function U = getWindVec(pos)
% GETWINDVEC returns a free wind vector (== speed and direction) for the
% position(s) given as a [x,y] vector
%
% INPUT
% NumChains     := [n x 3] vector with postions [x,y,z]// World coordinates
%
% OUTPUT
% U             := [n x 2] vector with the [Ux, Uy] velocities

% ========================= TODO ========================= 
% ///////////////////////// LINK Wind Dir  //////////

%windspeed = @(x) [x(1) 0;0 x(2)]*x;
%U = windspeed(pos');

U = 12*ones(size(pos,1),2);                                 % TODO Placeholder
end