function U = getWindVec(pos)
% GETWINDVEC returns a free wind vector (== speed and direction) for the
% position(s) given as a [x,y] vector
%
% INPUT
% NumChains     := [n x 3] vector with postions [x,y,z]// World coordinates
%
% OUTPUT
% u             := [n x 2] vector with the [ux, uy] velocities

% ========================= TODO ========================= 
% ///////////////////////// LINK Wind Dir  //////////

U = ones(size(pos,1),2);                                 % TODO Placeholder
end