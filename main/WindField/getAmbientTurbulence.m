function I_0 = getAmbientTurbulence(pos, IR, I, n_uf, lims)
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
% OUTPUT
% I_0       := [n x 1] vec; Ambient turbulence intensity at the position

% Get the index of the grid matrix the position is matching to
%   Relates to the output of the IR multiplication
i = pos2ind(pos,n_uf,lims);

nx = n_uf(1);
ny = n_uf(2);

%% Interpolate
% Interpolate absolute value
I_interp = reshape(IR*I',[nx,ny]);
I_0 = I_interp(i);
end