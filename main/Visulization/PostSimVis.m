%% Post-Sim Visulization
%   Contour Plot of the wind field
%% Interpolate the values of the grid in the wakes
u_grid_z = NaN(size(u_grid_x(:)));
narc_height = true(size(op_t_id));

if size(op_pos_old,2)==3
    narc_height = op_pos_old(:,3)<mean(tl_pos(:,3))*1.2;
    narc_height = and(op_pos_old(:,3)>mean(tl_pos(:,3))*0.8,narc_height);
end
for wakes = 1:length(tl_D)
    % Use wake of turbine "wakes" to triangulate
    F = scatteredInterpolant(...
        op_pos_old(and(op_t_id==wakes,narc_height),1),...
        op_pos_old(and(op_t_id==wakes,narc_height),2),...
    sqrt(sum(op_u(and(op_t_id==wakes,narc_height),:).^2,2)),'nearest','none');

    % Get grid values within the wake, outside nan
    u_grid_z_tmp = F(u_grid_x(:),u_grid_y(:));
    
    % Find grid values which are nan and are not nan in the interpolated
    % data
    writeGridZ = and(~isnan(u_grid_z_tmp),isnan(u_grid_z));
    
    % Fill these entries with the aquired data
    u_grid_z(writeGridZ)=F(u_grid_x(writeGridZ),u_grid_y(writeGridZ));
end

%% Fill up the values outside of the wakes with free windspeed measurements
nan_z = isnan(u_grid_z);
u_grid_z_tmp2 = getWindVec3(...
    [u_grid_x(nan_z),u_grid_y(nan_z)],...
    IR, U_abs(i,:), U_ang(i,:), uf_n, uf_lims);
u_grid_z(nan_z) = sqrt(sum(u_grid_z_tmp2.^2,2));
u_grid_z = reshape(u_grid_z,size(u_grid_x));

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
    plot3(rot_pos(1,:),rot_pos(2,:),[20,20],'k','LineWidth',3);
end
title('Filled contour plot')
axis equal
c = colorbar;
c.Label.String ='Windspeed [m/s]';
xlabel('West-East [m]')
ylabel('South-North [m]')
hold off


%% Power Hist

% figure(3)
% plot(powerHist(1,:));
% hold on
% for i = 2:NumTurbines
%     plot(powerHist(i,:));
% end
% title('Effective wind speed at the rotor plane')
% ylabel('Wind speed in m/s')
% xlabel('time step')
% grid on
% hold off
%% CHANGES to Contour
% Fill grid with turbine data one-by-one turbine -> avoid triangulation
% effects with other turbines.