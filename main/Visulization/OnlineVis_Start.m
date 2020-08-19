% Start Online visulization
% Step (1/3)

% Field Limits
fLim_x = [-300,2100];
fLim_y = [-100,2100];

[u_grid_x,u_grid_y] = meshgrid(fLim_x(1):10:fLim_x(2),fLim_y(1):10:fLim_y(2));
u_grid_z = zeros(size(u_grid_x));

figure(1)
pos = [...
    -100,100;...
    1000,100;...
    -100,2000;...
    1000,2000];
if Dim == 2
    scatter(pos(:,1),pos(:,2),50,[1,0,0;1,0,0;1,0,0;1,0,0],'filled')
else
    scatter3(pos(:,1),pos(:,2),[300,300,300,300],50,[1,0,0;1,0,0;1,0,0;1,0,0],'filled')
end
hold on
%axis equal
c = colorbar;
c.Label.String ='Windspeed [m/s]';
c.Limits = [0,10];
xlabel('West-East [m]')
ylabel('South-North [m]')
xlim(fLim_x);
ylim(fLim_y);
if Dim == 3
    zlabel('Height [m]')
    zlim([-300,500]);
end
grid on
clear pos
rotors = cell(length(tl_D),1);