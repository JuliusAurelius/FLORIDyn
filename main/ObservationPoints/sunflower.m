function [y,z] = sunflower(n, alpha)   %  example: n=500, alpha=2
% SUNFLOWER distributes n points in a sunflower pattern 
%   Uses altered code from stack overflow:
% https://stackoverflow.com/questions/28567166/uniformly-distribute-x-points-inside-a-circle#28572551
%
% INPUT
% n     := Int, Number of points to be placed
% alpha := Int, weight of points on the rim (musn't be above sqrt(n)!)

if alpha>sqrt(n)
    error(['Sunflower: Rimpoints weight alpha is to large, must be' ... 
        ' smaller than sqrt(n), with n points.'])
end

b   = round(alpha*sqrt(n));      % number of boundary points
gr  = (sqrt(5)+1)/2;             % golden ratio
k   = 1:n;
r   = ones(1,n);

r(1:n-b) = sqrt(k(1:n-b)-1/2)/sqrt(n-(b+1)/2);
theta = 2*pi*k/gr^2;

y = (r.*cos(theta))';
z = (r.*sin(theta))';
end