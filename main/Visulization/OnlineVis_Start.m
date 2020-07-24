% Start Online visulization
% Step (1/3)

figure(1)
if Dim == 2
    scatter([0,1000,0],[0,2000,2000],50,[1,0,0;1,0,0;1,0,0],'filled')
else
    scatter3([0,1000,0],[0,2000,2000],[300,300,300],50,[1,0,0;1,0,0;1,0,0],'filled')
end
hold on
axis equal
c = colorbar;
c.Label.String ='Windspeed [m/s]';
c.Limits = [0,10];
xlabel('West-East [m]')
ylabel('South-North [m]')
xlim([-300,2100]);
ylim([-100,2100]);
if Dim == 3
    zlabel('Height [m]')
    zlim([-300,500]);
end
grid on