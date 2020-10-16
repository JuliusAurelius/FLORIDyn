%% BACKUP Plot two turbines

%powSOWFA_PISO = importGenPowerFile([file2val 'piso_generatorPower.csv']);
powSOWFA_WPS = importGenPowerFile([file2val 'generatorPower.csv']);
f = figure;
plot(powSOWFA_WPS(1:2:end,2)-powSOWFA_WPS(1,2),powSOWFA_WPS(1:2:end,3)/UF.airDen,'-.','LineWidth',1)
hold on
plot(powSOWFA_WPS(2:2:end,2)-powSOWFA_WPS(2,2),powSOWFA_WPS(2:2:end,3)/UF.airDen,'-.','LineWidth',1)
% plot(powerHist(:,1),powerHist(:,2),'--','LineWidth',1.5)
% plot(powerHist(:,1),powerHist(:,3),'--','LineWidth',1.5)
plot(powerHist(:,1),powerHist(:,2),'LineWidth',1.5)
plot(powerHist(:,1),powerHist(:,3),'LineWidth',1.5)
% plot(powSOWFA_PISO(1:2:end,2),powSOWFA_PISO(1:2:end,3),'--','LineWidth',1.5)
% plot(powSOWFA_PISO(2:2:end,2),powSOWFA_PISO(2:2:end,3),'--','LineWidth',1.5)
hold off
%legend('T0 FLORIDyn','T1 FLORIDyn','T0 SOWFA piso','T1 SOWFA piso','T0 SWOFA wps','T1 SWOFA wps')
legend(...
    'T0 SOWFA wps','T1 SOWFA wps',...
    'T0 FLORIDyn axial Ind.','T1 FLORIDyn axial Ind.',...
    'T0 FLORIDyn table','T1 FLORIDyn table')
grid on
xlim([0 powerHist(end,1)])
xlabel('Time in s')
ylabel('Power generated in W')
title('Calculation of C_t and C_p')

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