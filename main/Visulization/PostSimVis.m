%% Post-Sim Visulization
%   Contour Plot of the wind field
%% Interpolate the values of the grid in the wakes
F = scatteredInterpolant(...
    op_pos_old(:,1),...
    op_pos_old(:,2),...
    sqrt(sum(op_u.^2,2)),'nearest','none');
u_grid_z_tmp = F(u_grid_x(:),u_grid_y(:));

%% Fill up the values outside of the wakes with free windspeed measurements
nan_z = isnan(u_grid_z_tmp);
u_grid_z_tmp2 = getWindVec3(...
    [u_grid_x(nan_z),u_grid_y(nan_z)],...
    IR, U_abs(i,:), U_ang(i,:), uf_n, uf_lims);
u_grid_z_tmp(nan_z) = sqrt(sum(u_grid_z_tmp2.^2,2));
u_grid_z = reshape(u_grid_z_tmp,size(u_grid_z));

%% Plot contour
figure(2)
contourf(u_grid_x,u_grid_y,u_grid_z,30,'LineColor','none');
hold on
for i_T = 1:length(tl_D)
    % Get start and end of the turbine rotor
    rot_pos = ...
        [cos(tl_ayaw(i_T,2)), -sin(tl_ayaw(i_T,2));...
        sin(tl_ayaw(i_T,2)), cos(tl_ayaw(i_T,2))] * ...
        [0,0;tl_D(i_T)/2,-tl_D(i_T)/2];
    rot_pos = rot_pos + tl_pos(i_T,1:2)';
    plot3(rot_pos(1,:),rot_pos(2,:),[20,20],'k','LineWidth',5);
end
title('Filled contour plot')
axis equal
c = colorbar;
c.Label.String ='Windspeed [m/s]';
xlabel('West-East [m]')
ylabel('South-North [m]')
hold off

%% CHANGES to Contour
% Fill grid with turbine data one-by-one turbine -> avoid triangulation
% effects with other turbines.