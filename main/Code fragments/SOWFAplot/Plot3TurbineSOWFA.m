%% Constants
D = 178.4;
% Three DTU 10MW Turbines
T.pos = [...
    1500-5*D 1500 119 D;...
    1500 1500 119 D;...
    1500+5*D 1500 119 D];
T.yaw = [0;0;0]/180*pi;
%% Plot Horizontal slice
pathSlices = '/Users/marcusbecker/Qsync/Masterthesis/Data/ThreeTurbineDataDaan/3Turbine/sliceDataInstantaneous/';
slice = '21000/U_slice_horizontal.vtk';
f = plotVTK([pathSlices,slice]);

title('Horizontal slice at hub height through the wind field');
hold on
for i_T = 1:3
    % Get start and end of the turbine rotor
    rot_pos = ...
        [cos(T.yaw(i_T)), -sin(T.yaw(i_T));...
        sin(T.yaw(i_T)), cos(T.yaw(i_T))] * ...
        [0,0;D/2,-D/2];
    rot_pos = rot_pos + T.pos(i_T,1:2)';
    plot(rot_pos(1,:),rot_pos(2,:),'k','LineWidth',3);
end
hold off

xlabel('Down wind direction [m]');
ylabel('Cross wind direction [m]');
ylim([500,2500])
c = colorbar;
c.Label.String ='Wind speed [m/s]';

% ==== Prep for export ==== %
% Set font & size
set(f.Children, ...
    'FontName',     'Frontpage', ...
    'FontSize',     10);

set(gca,'LooseInset', max(get(gca,'TightInset'), 0.02))
% scaling
f.Units               = 'centimeters';
f.Position(3)         = 16.1; % line width

%% Streamwise slice
slice = '21000/U_slice_streamwise.vtk';
f = plotVTK([pathSlices,slice]);

title('Streamwise slice through the wind field');
hold on

for i_T = 1:3
    plot([1,1]*T.pos(i_T,1),[-D/2, D/2]+T.pos(i_T,3),'k','LineWidth',3);
end

hold off
xL = xlabel('Down wind direction [m]');
yL = ylabel('Height [m]');

c = colorbar;
c.Label.String ='Wind speed [m/s]';

% ==== Prep for export ==== %
% Set font & size
set(f.Children, ...
    'FontName',     'Frontpage', ...
    'FontSize',     10);

set(gca,'LooseInset', max(get(gca,'TightInset'), 0.02))
% scaling
f.Units               = 'centimeters';
f.Position(3)         = 16.1; % line width

% Export
f.PaperPositionMode   = 'auto';
print('StreamwiseSlice', '-dpng', '-r600')

%% Streamwise slice

f = plotVTK('U_slice_horizontal.vtk');

title('SOWFA wind field');
hold on
T.pos = [400 500;1300,500];
T.yaw = [-20;0]/180*pi;
for i_T = 1:2
    % Get start and end of the turbine rotor
    rot_pos = ...
        [cos(T.yaw(i_T)), -sin(T.yaw(i_T));...
        sin(T.yaw(i_T)), cos(T.yaw(i_T))] * ...
        [0,0;D/2,-D/2];
    rot_pos = rot_pos + T.pos(i_T,1:2)';
    plot(rot_pos(1,:),rot_pos(2,:),'k','LineWidth',3);
end

hold off
xL = xlabel('x_0 [m]');
yL = ylabel('y_0 [m]');

c = colorbar;
c.Label.String ='Wind speed [m/s]';

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
print('SOWFAslice', '-dpng', '-r600')
