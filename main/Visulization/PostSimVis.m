% % Post-Sim Visulization
% % World coordinates
figure(2)
F = scatteredInterpolant(...
    op_pos(:,1),...
    op_pos(:,2),...
    sqrt(sum(op_u.^2,2)),'nearest','none');

u_grid_z_tmp = F(u_grid_x(:),u_grid_y(:));
nan_z = isnan(u_grid_z_tmp);
u_grid_z_tmp2 = getWindVec3(...
    [u_grid_x(nan_z),u_grid_y(nan_z)],...
    IR, U_abs(i,:), U_ang(i,:), uf_n, uf_lims);
u_grid_z_tmp(nan_z) = sqrt(sum(u_grid_z_tmp2.^2,2));
u_grid_z = reshape(u_grid_z_tmp,size(u_grid_z));
contourf(u_grid_x,u_grid_y,u_grid_z);
title('Filled contour plot')
axis equal
% if size(op_pos,2) == 3 % Dimentions
%     subplot(2,1,1)
%     scatter3(op_pos(:,1),op_pos(:,2),op_pos(:,3),...
%     ones(size(op_t_id))*10,sqrt(sum((op_U.*op_r(:,1)).^2,2)),...
%     'filled');
%     zlabel('height [m]')
%     title(['3D wake with ' num2str(NumChains) ' chains with each ' ...
%         num2str(chainLength) ' observation points'])
% else
%     subplot(2,1,2)
%     scatter(op_pos(:,1),op_pos(:,2),...
%     ones(size(op_t_id))*10,sqrt(sum((op_U.*op_r(:,1)).^2,2))+op_U(:,2)*0.5,...
%     'filled');
%     title(['2D wake with ' num2str(NumChains) ' chains with each ' ...
%         num2str(chainLength) ' observation points'])
% end
% 
% axis equal
% colormap parula
% c = colorbar;
% c.Label.String = 'Windspeed in m/s';
% %title(['Proof of concept: wind speed and direction change, ' num2str(length(tl_D)) ' turbines'])
% %title(['Proof of concept: Simple wake model, 60 chains with 80 observation points'])
% xlabel('east - west [m]')
% %xlim([-50,3500])
% ylabel('south - north [m]')
% %ylim([-400,400])
% grid on