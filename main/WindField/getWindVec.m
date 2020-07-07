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
borderAng = 600;
borderSpe = 100;
beyond_Ang = pos(:,1)>borderAng;
pre_Speed  = pos(:,1)<borderSpe;
U = 8*ones(size(pos,1),2) * [1, 0; 0, 0.5];             % m/s   % TODO Placeholder
U(beyond_Ang,2) = -U(beyond_Ang,2);
U(pre_Speed,:) = U(pre_Speed,:)*0.6;
end