

path1 = '/Users/marcusbecker/Qsync/Masterthesis/Data/ThreeTurbineDataDaan/3TurbineYawPos/sliceDataInstantaneous/2';
path2 = '/Users/marcusbecker/Qsync/Masterthesis/Data/ThreeTurbineDataDaan/3Turbine/sliceDataInstantaneous/2';
file = '/U_slice_horizontal.vtk';

yawSOWFA = importYawAngleFile('./ValidationData/csv/3T_pos_y_nacelleYaw.csv');
yawSOWFA(:,2) = yawSOWFA(:,2)-yawSOWFA(1,2);
D = 178.4;
T_Pos = [...
    1500-5*D 1500 119 D;...
    1500 1500 119 D;...
    1500+5*D 1500 119 D];
        
for k = 2:2:1000
    
    %% Get yaw angle
    yaw = zeros(size(T.yaw));
    for iT = 1:3
        yaw(iT) = interp1(...
            yawSOWFA(iT:3:end,2),yawSOWFA(iT:3:end,3),k);
    end
    
    % Yaw conversion SOWFA to FLORIDyn
    yaw = (270*ones(size(yaw))-yaw)/180*pi;
    
    
    %% Prep
    fileNr = pad(num2str(k),4,'left','0');
    %% =================== YAW ===================
    [~,cellCenters,cellData] = importVTK([path1 fileNr file]);
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
    U_SOWFA_yaw = interpolant(Xm,Ym);
    
    %% =================== ORG ===================
    [~,cellCenters,cellData] = importVTK([path2 fileNr file]);
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
    U_SOWFA_org = interpolant(Xm,Ym);
    
    %% =================== Plot ===================
    
    f = figure(12);
    s1 = subplot(3,1,1);
    imagesc(Xaxis,Yaxis,U_SOWFA_yaw);
    hold on
    set(gca,'YDir','normal');
    axis equal;
    axis tight;
    c = colorbar;
    c.Label.String ='Wind speed [m/s]';
    c.Limits = [0,14];
    set(gca, 'Clim', [0, 14])
    colormap jet
    xlabel('West-East [m]')
    ylabel('South-North [m]')
    title('SOWFA yaw flow field')
    ylim([1000,2000])
    for i_T = 1:3
        % Get start and end of the turbine rotor
        rot_pos = ...
            [cos(yaw(i_T)), -sin(yaw(i_T));...
            sin(yaw(i_T)), cos(yaw(i_T))] * ...
            [0,0;D/2,-D/2];
        rot_pos = rot_pos + repmat(T_Pos(i_T,1:2)',1,size(rot_pos,2));
        plot3(rot_pos(1,:),rot_pos(2,:),[20,20],'k','LineWidth',2);
    end
    hold off
    
    s2 = subplot(3,1,2);
    imagesc(Xaxis,Yaxis,U_SOWFA_yaw./U_SOWFA_org);
    set(gca,'YDir','normal');
    axis equal;
    axis tight;
    c = colorbar;
    c.Label.String ='Wind speed [m/s]';
    c.Limits = [0,2];
    set(gca, 'Clim', [0, 2])
    colormap jet
    xlabel('West-East [m]')
    ylabel('South-North [m]')
    title('SOWFA yaw divided by un-yawed')
    ylim([1000,2000])
    c.Limits = [0,2];
    
    s3 = subplot(3,1,3);
    imagesc(Xaxis,Yaxis,U_SOWFA_org);
    hold on
    set(gca,'YDir','normal');
    axis equal;
    axis tight;
    c = colorbar;
    c.Label.String ='Wind speed [m/s]';
    c.Limits = [0,14];
    set(gca, 'Clim', [0, 14])
    c.Limits = [0,14];
    colormap jet
    xlabel('West-East [m]')
    ylabel('South-North [m]')
    title('SOWFA un-yawed flow field')
    ylim([1000,2000])
    set(gca, 'Clim', [0, 14])
    
    yaw = zeros(size(T.yaw));
    for i_T = 1:3
        % Get start and end of the turbine rotor
        rot_pos = ...
            [cos(yaw(i_T)), -sin(yaw(i_T));...
            sin(yaw(i_T)), cos(yaw(i_T))] * ...
            [0,0;D/2,-D/2];
        rot_pos = rot_pos + repmat(T_Pos(i_T,1:2)',1,size(rot_pos,2));
        plot3(rot_pos(1,:),rot_pos(2,:),[20,20],'k','LineWidth',2);
    end
    hold off
    
    pause(0.1)
    nr = num2str(k);
    nr = pad(nr,5,'left','0');
    print(['./Snapshot/' nr], '-dpng', '-r300')
end


