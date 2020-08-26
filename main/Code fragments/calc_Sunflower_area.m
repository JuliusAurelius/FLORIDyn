n=50;
alpha=2;

[x,y,area] = sunflower(n, alpha);
phi = linspace(0,2*pi,100);
xc = 1.1*cos(phi');
yc = 1.1*sin(phi');
[v,c] = voronoin([x y;xc,yc]) ;
figure
hold on
A = zeros(length(c),1) ;
for i = 1:length(c)
    v1 = v(c{i},1) ; 
    v2 = v(c{i},2) ;
    patch(v1,v2,rand(1,3))
    A(i) = polyarea(v1,v2) ;
end
voronoi([x;xc],[y;yc])
plot(xc,yc,'--r','LineWidth',1.5)
axis equal
title('Relative areas represented by Observarion Points ')
xlabel('y/D')
ylabel('z/D')
hold off
