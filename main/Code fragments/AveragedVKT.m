%path = '/Users/marcusbecker/Qsync/Masterthesis/Data/DataMarteen/data/two.01.step.20.wps/sliceDataInstantaneous/20';
%path = '/Users/marcusbecker/Qsync/Masterthesis/Data/ThreeTurbineDataDaan/3TurbineYawPos/sliceDataInstantaneous/20';
path = '/Users/marcusbecker/Qsync/Masterthesis/Data/DataMarteen/data/torque.02.rotating.9T/sliceDataInstantaneous/21';
%file = '/U_slice_streamwise.vtk';
file = '/U_slice_horizontal.vtk';

UmeanAbs = 0;

for ind = 350:30:500
    [~,cellCenters,cellData] = importVTK([path num2str(ind) file]);
    UmeanAbsScattered = sqrt(sum(cellData.^2,2));
    
    % Horizontal slice trough the wake field (xy plane)
    % Create 2D interpolant
    interpolant = ...
        scatteredInterpolant(cellCenters(:,[1,2]),UmeanAbsScattered); % [1,3]),UmeanAbsScattered);
    
    % x axis plot = x axis field
    Xaxis = linspace(...
        min(cellCenters(:,1),[],1),...
        max(cellCenters(:,1),[],1),301);
    
    % y axis plot = y axis field
    Yaxis = linspace(...
        min(cellCenters(:,2),[],1),...      % (:,2),[],1),...
        max(cellCenters(:,2),[],1),301);    % (:,2),[],1),300);
    
    % Create meshgrid for interpolation
    [Xm,Ym] = meshgrid(Xaxis,Yaxis);
    UmeanAbs = UmeanAbs + interpolant(Xm,Ym);
    
    disp(num2str(ind))
end

UmeanAbs = UmeanAbs/length(350:30:500);

%% Plot result
f = figure();
imagesc(Xaxis,Yaxis,UmeanAbs);
set(gca,'YDir','normal');
axis equal;
axis tight;
c = colorbar;
c.Label.String ='Windspeed [m/s]';
xlabel('West-East [m]')
ylabel('South-North [m]')
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

%% imagesc(Xaxis,Yaxis,(UmeanAbs-u_grid_z)./UmeanAbs);