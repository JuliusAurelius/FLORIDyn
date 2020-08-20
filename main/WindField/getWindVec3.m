function U = getWindVec3(pos,IR, U_meas_abs, U_meas_ang, n_uf, lims)
%GETWINDVEC3 returns a wind vector related to the desired position
%
% INPUTS
% pos       := [n x 2] vec; points to get velocity for
% IR        := [m x n] Mat; Matrix which takes n measurements and
%                     returns m interpolated values: x2=IR*x1;
% U_meas_abs:= [1 x n] vec; n Measurements of the absolute wind speed
% U_meas_ang:= [1 x n] vec; n Measurements of the wind direction
% n_uf      := [1 x 2] vec; Number of points in x and y direction
% lims      := [2 x 2] mat; [delta x, delta y; (x,y) bottom left]
%
% ======================================================================= %

nx = n_uf(1);
ny = n_uf(2);

%% Nearest neighbour interpolation
% Transform the (x,y) coordinates into the indeces of the wind field, so
% that the position is automatically matched to an entry in the matrix.
n_pos = pos(:,1:2)-lims(2,:);

% This way the points actually get the windspeeds from the right source
n_pos(:,1) = (1-n_pos(:,1)./lims(1,1));
n_pos(:,2) = (1-n_pos(:,2)./lims(1,2));

% match outliers to closest edge
n_pos(n_pos>1) = 1;
n_pos(n_pos<0) = 0;

% round to index-space [1:n]
n_pos(:,1) = round(n_pos(:,1) * (nx-1))+1;
n_pos(:,2) = round(n_pos(:,2) * (ny-1))+1;

n_uf2 = [n_uf(2),n_uf(1)];
i = sub2ind(n_uf2,n_pos(:,2),n_pos(:,1));

U = zeros(size(pos(:,1:2)));

%% Interpolate
% Interpolate absolute value
Abs_interp = reshape(IR*U_meas_abs',[nx,ny]);

% Interpolate angle
%   get angles relative to first one as offset
tmp_ang = mod((U_meas_ang-U_meas_ang(1))+pi/2,pi)-pi/2;
%   Interpolate the differences
Ang_interp = reshape(IR*tmp_ang',[nx,ny]);
%   Add offset again and match to range [0,2pi]
Ang_interp = mod(U_meas_ang(1)+Ang_interp,2*pi);

% Polar coordinates to cartesian coordinatess
U(:,1) = cos(Ang_interp(i)).*Abs_interp(i);
U(:,2) = sin(Ang_interp(i)).*Abs_interp(i);
end

