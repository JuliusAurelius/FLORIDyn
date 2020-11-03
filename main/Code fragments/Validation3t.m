%% PLOTTING 3 Turbines

powSOWFA_WPS = importGenPowerFile([file2val 'wps_generatorPower.csv']);
f = figure;
plot(powSOWFA_WPS(1:3:end,2)-powSOWFA_WPS(1,2),powSOWFA_WPS(1:3:end,3)/UF.airDen,'-.','LineWidth',1.8)
hold on
plot(powSOWFA_WPS(2:3:end,2)-powSOWFA_WPS(2,2),powSOWFA_WPS(2:3:end,3)/UF.airDen,'-.','LineWidth',1.8)
plot(powSOWFA_WPS(3:3:end,2)-powSOWFA_WPS(3,2),powSOWFA_WPS(3:3:end,3)/UF.airDen,'-.','LineWidth',1.8)
plot(powerHist(:,1),powerHist(:,2),'LineWidth',3)
plot(powerHist(:,1),powerHist(:,3),'LineWidth',3)
plot(powerHist(:,1),powerHist(:,4),'LineWidth',3)
% plot(powSOWFA_PISO(1:2:end,2),powSOWFA_PISO(1:2:end,3),'--','LineWidth',1.5)
% plot(powSOWFA_PISO(2:2:end,2),powSOWFA_PISO(2:2:end,3),'--','LineWidth',1.5)

hold off
%legend('T0 FLORIDyn','T1 FLORIDyn','T0 SOWFA piso','T1 SOWFA piso','T0 SWOFA wps','T1 SWOFA wps')
legend(...
    'T0 SOWFA wps','T1 SOWFA wps','T2 SOWFA wps',...
    'T0 FLORIDyn free speed','T1 FLORIDyn free speed','T2 FLORIDyn free speed')
grid on
xlim([0 powerHist(end,1)])
xlabel('Time in s')
ylabel('Power generated in W')
title('Three turbine case, 9m/s, 5% amb. turbulence, 0.1 shear exp., C_t and C_p table')


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

%% Controller script
% Read yaw of SOWFA Sim
yawT1 = interp1(yawSOWFA(1:3:end,2),yawSOWFA(1:3:end,3),Sim.TimeSteps(i));
yawT2 = interp1(yawSOWFA(2:3:end,2),yawSOWFA(2:3:end,3),Sim.TimeSteps(i));
yawT3 = interp1(yawSOWFA(3:3:end,2),yawSOWFA(3:3:end,3),Sim.TimeSteps(i));

yaw = [yawT1;yawT2;yawT3];