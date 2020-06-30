function r = getR(OPs)
% GETR calculates the reduction factor of the wind velocity to get the
% effective windspeed based on the eq. u = U*r
%
% INPUT
% OPs           := [n x 5] vector [x,y,z,a,yaw] in World coordinates
%
% OUTPUT
% r             := [n x 1] vector reduction factor
%

% ==================== !!!!DUMMY METHOD!!!! ====================== % 
% ================= should link to wake models =================== %

r = zeros(size(OPs,1),1);
end