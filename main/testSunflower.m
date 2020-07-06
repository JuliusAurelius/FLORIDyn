function testSunflower()
n = 10;
figure(1)
[theta3, r3] = sunflower3(n,2);
%[theta2, r2] = sunflower2(n,2);
%[theta1, r1] = sunflower1(n,2);
[y,z] = sunflower(n,2);
%plot(r3.*cos(theta3), r3.*sin(theta3), 'r*')
plot(y.*cos(z), y.*sin(z), 'r*')
end
%% 1
function [theta, r]=sunflower1(n, alpha)   %  example: n=500, alpha=2
    clf
    hold on
    b = round(alpha*sqrt(n));      % number of boundary points
    phi = (sqrt(5)+1)/2;           % golden ratio
    
    r = zeros(1,n);
    theta = zeros(1,n);
    
    for k=1:n
        r(k) = radius(k,n,b);
        theta(k) = 2*pi*k/phi^2;
        plot(r(k)*cos(theta(k)), r(k)*sin(theta(k)), 'r*');
    end
    axis equal
end

function r = radius(k,n,b)
    if k>n-b
        r = 1;            % put on the boundary
    else
        r = sqrt(k-1/2)/sqrt(n-(b+1)/2);     % apply square root
    end
end

%% 3

function [theta, r] = sunflower3(n, alpha)   %  example: n=500, alpha=2
    b   = round(alpha*sqrt(n));     % number of boundary points
    gr  = (sqrt(5)+1)/2;            % golden ratio
    k   = 1:n;
    r   = ones(1,n);
    in_c = (k<=n-b);                % Points in circle
    r(in_c) = sqrt(k(in_c)-1/2)/sqrt(n-(b+1)/2);
    theta = 2*pi*k/gr^2;
end
%%
function [y,z] = sunflower(n, alpha)   %  example: n=500, alpha=2
% SUNFLOWER distributes n points in a sunflower pattern 
%   Uses altered code from stack overflow (link below).
%
% INPUT
% n     := Int, Number of points to be placed
% alpha := Int, weight of points on the rim
    b   = round(alpha*sqrt(n));      % number of boundary points
    gr  = (sqrt(5)+1)/2;            % golden ratio
    k   = 1:n;
    r   = ones(1,n);
    
    r(1:n-b) = sqrt(k(1:n-b)-1/2)/sqrt(n-(b+1)/2);
    theta = 2*pi*k/gr^2;
    
    clf
    plot(r.*cos(theta), r.*sin(theta), 'r*')
    axis equal
    y = r;
    z = theta;
end % HAS A BUG

%% 2

function [theta, r] = sunflower2(n, alpha)   %  example: n=500, alpha=2
    clf
    hold on
    b = round(alpha*sqrt(n));      % number of boundary points
    gr = (sqrt(5)+1)/2;            % golden ratio
    k = 1:n;
    r = radius2(k,n,b);
    theta = 2*pi*k/gr^2;
    plot(r.*cos(theta), r.*sin(theta), 'r*')
    axis equal
end

function r = radius2(k,n,b)
    % k vec
    % n num of points
    % b boundary points
    r = ones(n,1);
    r(1:n-b) = sqrt(k(1:n-b)-1/2)/sqrt(n-(b+1)/2);     % apply square root
end