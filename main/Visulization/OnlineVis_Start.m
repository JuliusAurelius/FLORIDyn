% Start Online visulization
% Step (1/3)

% Field Limits
fLim_x = [-300,2100];
fLim_y = [-100,2100];

%% create a meshgrid for the field coordinates, used by the contour plot
res = 10;
[u_grid_x,u_grid_y] = meshgrid(fLim_x(1):10:fLim_x(2),fLim_y(1):10:fLim_y(2));
u_grid_z = zeros(size(u_grid_x));

%% Create live plot figure
figure(1)
% if Dim == 2
%     scatter(pos(:,1),pos(:,2),50,[1,0,0;1,0,0;1,0,0;1,0,0],'filled')
% else
%     scatter3(pos(:,1),pos(:,2),[300,300,300,300],50,[1,0,0;1,0,0;1,0,0;1,0,0],'filled')
% end
hold on
%axis equal
% c = colorbar;
% c.Label.String ='Windspeed [m/s]';
% c.Limits = [0,13];
% xlabel('West-East [m]')
% ylabel('South-North [m]')
% xlim(fLim_x);
% ylim(fLim_y);
% if Dim == 3
%     zlabel('Height [m]')
%     zlim([-300,500]);
% end
% grid on

%% creating a cell array to store the rotor graphics
% since the number of rotors changes, there is not one object to delete but
% a varying number.
rotors = cell(length(tl_D),1);

%% Clean up
clear pos res