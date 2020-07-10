[x1,y1] = sunflower(10,2);
[x2,y2] = sunflower(60,2);
[x3,y3] = sunflower(10,3);
[x4,y4] = sunflower(60,4);

figure(1)
subplot(2,2,1)
voronoi(x1,y1)
hold on
scatter(x1,y1,'filled')
title('10 points, \alpha = 2')
ylabel('cw_z/\sigma_z')
xlabel('cw_y/\sigma_y')
axis equal
xlim([-1.1 1.1])
ylim([-1.1 1.1])
grid on
hold off

subplot(2,2,2)
voronoi(x2,y2)
hold on
scatter(x2,y2,'filled')
title('60 points, \alpha = 2')
ylabel('cw_z/\sigma_z')
xlabel('cw_y/\sigma_y')
axis equal
xlim([-1.1 1.1])
ylim([-1.1 1.1])
grid on
hold off

subplot(2,2,3)
voronoi(x3,y3)
hold on
scatter(x3,y3,'filled')
title('10 points, \alpha = 3')
ylabel('cw_z/\sigma_z')
xlabel('cw_y/\sigma_y')
axis equal
xlim([-1.1 1.1])
ylim([-1.1 1.1])
grid on
hold off

subplot(2,2,4)
voronoi(x4,y4)
hold on
scatter(x4,y4,'filled')
title('60 points, \alpha = 4')
ylabel('cw_z/\sigma_z')
xlabel('cw_y/\sigma_y')
axis equal
xlim([-1.1 1.1])
ylim([-1.1 1.1])
grid on
hold off