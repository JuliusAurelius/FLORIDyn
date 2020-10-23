%path = '/Users/marcusbecker/Qsync/Masterthesis/Data/DataMarteen/3Turbine/sliceDataInstantaneous/20';
path = '/Users/marcusbecker/Qsync/Masterthesis/Data/ThreeTurbineDataDaan/3Turbine/sliceDataInstantaneous/20';
file = '/U_slice_streamwise.vtk';

UmeanAbs = 0;

for ind = 810:30:990
    [~,cellCenters,cellData] = importVTK([path num2str(ind) file]);
    UmeanAbsScattered = sqrt(sum(cellData.^2,2));
    
    % Horizontal slice trough the wake field (xy plane)
    % Create 2D interpolant
    interpolant = ...
        scatteredInterpolant(cellCenters(:,[1,3]),UmeanAbsScattered); % [1,2]),UmeanAbsScattered);
    
    % x axis plot = x axis field
    Xaxis = linspace(...
        min(cellCenters(:,1),[],1),...
        max(cellCenters(:,1),[],1),301);
    
    % y axis plot = y axis field
    Yaxis = linspace(...
        min(cellCenters(:,3),[],1),...      % (:,2),[],1),...
        max(cellCenters(:,3),[],1),301);    % (:,2),[],1),300);
    
    % Create meshgrid for interpolation
    [Xm,Ym] = meshgrid(Xaxis,Yaxis);
    UmeanAbs = UmeanAbs + interpolant(Xm,Ym);
    
    disp(num2str(ind))
end

UmeanAbs = UmeanAbs/length(930:5:960);

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