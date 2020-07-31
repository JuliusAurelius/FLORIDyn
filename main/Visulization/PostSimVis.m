% Post-Sim Visulization
% World coordinates
figure(1)
if size(op_pos,2) == 3 % Dimentions
    subplot(2,1,1)
    scatter3(op_pos(:,1),op_pos(:,2),op_pos(:,3),...
    ones(size(op_t_id))*10,sqrt(sum((op_U.*op_r(:,1)).^2,2)),...
    'filled');
    zlabel('height [m]')
    title(['3D wake with ' num2str(NumChains) ' chains with each ' ...
        num2str(chainLength) ' observation points'])
else
    subplot(2,1,2)
    scatter(op_pos(:,1),op_pos(:,2),...
    ones(size(op_t_id))*10,sqrt(sum((op_U.*op_r(:,1)).^2,2))+op_U(:,2)*0.5,...
    'filled');
    title(['2D wake with ' num2str(NumChains) ' chains with each ' ...
        num2str(chainLength) ' observation points'])
end

axis equal
colormap parula
c = colorbar;
c.Label.String = 'Windspeed in m/s';
%title(['Proof of concept: wind speed and direction change, ' num2str(length(tl_D)) ' turbines'])
%title(['Proof of concept: Simple wake model, 60 chains with 80 observation points'])
xlabel('east - west [m]')
%xlim([-50,3500])
ylabel('south - north [m]')
%ylim([-400,400])
grid on