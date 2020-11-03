%% Get the averaged SOWFA speed
% Expecting to have access to Xaxis,Yaxis,UmeanAbs
%%

narc_height = true(size(OP.t_id));

[u_grid_x,u_grid_y] = meshgrid(Xaxis,Yaxis);
u_grid_z = NaN(size(u_grid_x(:)));

for wakes = 1:length(T.D)
    F = scatteredInterpolant(...
        OP_pos_old(and(OP.t_id==wakes,narc_height),1),...
        OP_pos_old(and(OP.t_id==wakes,narc_height),2),...   % 3
    sqrt(sum(OP.u(and(OP.t_id==wakes,narc_height),:).^2,2)),'nearest','none');

    % Get grid values within the wake, outside nan
    u_grid_z_tmp = F(u_grid_x(:),u_grid_y(:));
    
    u_grid_z = min([u_grid_z, u_grid_z_tmp],[],2);
end

%% Fill up the values outside of the wakes with free windspeed measurements
nan_z = isnan(u_grid_z);

u_grid_z_tmp = getWindVec4(...
    [u_grid_x(nan_z),u_grid_y(nan_z),ones(size(u_grid_x(nan_z)))*119],...
    U_abs, U_ang, UF);

u_grid_z(nan_z) = sqrt(sum(u_grid_z_tmp.^2,2));
u_grid_z=reshape(u_grid_z,size(u_grid_x));


%% Plot
f = figure();
imagesc(Xaxis,Yaxis,max(((UmeanAbs-u_grid_z)./UmeanAbs),-1.5)*100);
set(gca,'YDir','normal');
axis equal;
axis tight;
c = colorbar;
c.Label.String ='Error [%]';
colormap jet
xlabel('West-East [m]')
ylabel('South-North [m]')
%ylabel('Height [m]')
title('Flow field at hub height, relative wind speed error')
% ==== Prep for export ==== %
% scaling
f.Units               = 'centimeters';
f.Position(3)         = 16.1; % line width

% Set font & size
set(f.Children, ...
    'FontName',     'Frontpage', ...
    'FontSize',     10);

set(gca,'LooseInset', max(get(gca,'TightInset'), 0.04))

% Export
f.PaperPositionMode   = 'auto';
%% Store
print('9T_Field_Horizontal_RelError_newI', '-dpng', '-r600')