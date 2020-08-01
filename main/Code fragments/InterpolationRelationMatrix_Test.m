% Interpolation relation matrix IR
n = 10;
m = 100;
meas_xy = rand(n,2);
goal_xy = rand(m,2);

IR = zeros(m,n);

v = zeros(n,1);
v(1) = 1;

F = scatteredInterpolant(meas_xy(:,1),meas_xy(:,2),v,'natural','linear');
IR(:,1) = F(goal_xy);

for i = 2:n
    v(i-1:i) = [0;1];
    F.Values = v;
    IR(:,i) = F(goal_xy);
end

testdata = rand(n,1);
F.Values = testdata;
d = IR*testdata - F(goal_xy);
figure
scatter3(goal_xy(:,1),goal_xy(:,2),IR*testdata)
hold on
scatter3(goal_xy(:,1),goal_xy(:,2),F(goal_xy),10)
hold off

%%
x = rand(1000,1);
y = rand(1000,1);
z = rand(size(x));
queryx = rand(10,1);
queryy = rand(10,1);
T = delaunayTriangulation(x,y);
P = [queryx(:) queryy(:)];
m = size(P,1);
n = size(T.Points,1);
ID = pointLocation(T,P);
W = cartesianToBarycentric(T, ID, P);
I = repmat(1:m,1,3);
IMAT = sparse(I,T.ConnectivityList(ID,:),W,m,n);
IMAT*z(:)
F = scatteredInterpolant(x,y,z);
F(queryx,queryy)
%%
% % Generate source image and 2D grid
% z = 10+peaks(50);
% z = z(1:30,:);
% xgrid = linspace(0,1,size(z,2));
% ygrid = linspace(0,1,size(z,1));
% 
% xgrid = rand(1,size(z,2));
% %xgrid = xgrid/sum(xgrid);
% ygrid = rand(1,size(z,1));
% %ygrid = ygrid/sum(ygrid);
% 
% 
% n = 15;
% data = rand(n,3);
% 
% % Generate goalx goaly, it can be scattered points, rotate coordinates, morphology etc...
% xi = linspace(0,1.1,500);
% yi = linspace(0,1.1,500);
% [goalx,goaly] = meshgrid(xi, yi);
% 
% % Build bilinear interpolation matrix
% if isequal(size(goalx),size(goaly))
%     szout = size(goalx);
% else
%     szout = [];
% end
% 
% goalx = goalx(:);
% goaly = goaly(:);
% xgrid = xgrid(:);
% ygrid = ygrid(:);
% xgrid = data(:,1)'*100;
% ygrid = data(:,2)'*10;
% [ygrid, Iy] = sort(ygrid);
% [xgrid, Ix] = sort(xgrid);
% 
% nx = size(xgrid,1);
% ny = size(ygrid,1);
% 
% dx = diff(xgrid);
% dy = diff(ygrid);
% 
% if any(dx==0) || any(dy==0)
%     error('grid not distinct')
% end
% if ~issorted(xgrid) || ~issorted(ygrid)    
%     error('grid is not sorted')
% end
% 
% [~,~,ix] = histcounts(goalx,xgrid);
% [~,~,iy] = histcounts(goaly,ygrid);
% valid = ix > 0 & iy > 0;
% ixvalid = ix(valid);
% iyvalid = iy(valid);
% 
% xgrid = xgrid';
% ygrid = ygrid';
% 
% wx = (goalx(valid)-xgrid(ixvalid)) ./ dx(ixvalid);
% wy = (goaly(valid)-ygrid(iyvalid)) ./ dy(iyvalid);
% wx = reshape(wx,1,1,[]);
% wy = reshape(wy,1,1,[]);
% wx = cat(1, 1-wx, wx);
% wy = cat(2, 1-wy, wy);
% W = wx .* wy;
% j = sub2ind([ny nx], iyvalid, ixvalid);
% J = reshape(j,1,1,[]);
% J = J + [ 0, 1;
%           ny, ny+1];
% nvalid = sum(valid);
% i = 1:nvalid;
% I = reshape(i,1,1,[]);
% I = I + [ 0, 0;
%           0, 0];
% IMAT = sparse([],[],[],length(valid),nx*ny);
% IMAT(valid,:) = sparse(I(:),J(:),W(:),nvalid,nx*ny);
% 
% 
% % Interpolation using matrix
% zi_matmult = IMAT*z(:);
% if ~isempty(szout)
%     zi_matmult = reshape(zi_matmult, szout);
%     goalx = reshape(goalx, szout);
%     goaly = reshape(goaly, szout);
% end
% 
% 
% % and using MATLAB
% zi_intepr = interp2(xgrid,ygrid,z,goalx,goaly,'linear',0);
% % Check
% if ~isvector(zi_matmult)
%     close all
%     subplot(1,2,1);
%     imagesc(zi_intepr)
%     subplot(1,2,2);
%     imagesc(zi_matmult)
% end