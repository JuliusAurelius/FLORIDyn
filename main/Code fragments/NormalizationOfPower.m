%% Normalization and plotting
% simulate the greedy case, store the powerHist matrix in greedyPowerHist
% and the power output of SOWFA in greedySOWFAPower.
normFLORIdyn = powerHist(1:251,2:4)./greedyPowerHist(:,2:4);
normSOWFA = powSOWFA_WPS(1:15003,3)./greedySOWFAPower(:,3)*UF.airDen;

%% T0
f = figure;
hold on
t = 1;
plot(...
    greedySOWFAPower(t:nT:end,2)-greedySOWFAPower(t,2),...
    normSOWFA(t:nT:end)/UF.airDen,...
    '-.','LineWidth',1)
plot(greedyPowerHist(:,1),normFLORIdyn(:,t),'LineWidth',1.5)

hold off
grid on
xlim([0 greedyPowerHist(end,1)])
xlabel('Time [s]')
ylabel('Norm. P [W/W]')
title(['Normalized power output of turbine ' num2str(t-1)])
legend('SOWFA','FLORIDyn')
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
%%
print('ThreeT_Norm_T0_negYaw_newI', '-dpng', '-r600')
%% T1
f = figure;
hold on
t = 2;
plot(...
    greedySOWFAPower(t:nT:end,2)-greedySOWFAPower(t,2),...
    normSOWFA(t:nT:end)/UF.airDen,...
    '-.','LineWidth',1)
plot(greedyPowerHist(:,1),normFLORIdyn(:,t),'LineWidth',1.5)

hold off
grid on
xlim([0 greedyPowerHist(end,1)])
xlabel('Time [s]')
ylabel('Normalized power [W/W]')
title(['Normalized power output of turbine ' num2str(t-1)])
legend('SOWFA','FLORIDyn')
% scaling
f.Units               = 'centimeters';
f.Position(3)         = 8; % line width


% Set font & size
set(f.Children, ...
    'FontName',     'Frontpage', ...
    'FontSize',     10);
set(gca,'LooseInset', max(get(gca,'TightInset'), 0.04))

% Export
f.PaperPositionMode   = 'auto';
%%
print('ThreeT_Norm_T1_negYaw_newI', '-dpng', '-r600')
%% T2
f = figure;
hold on
t = 3;
plot(...
    greedySOWFAPower(t:nT:end,2)-greedySOWFAPower(t,2),...
    normSOWFA(t:nT:end)/UF.airDen,...
    '-.','LineWidth',1)
plot(greedyPowerHist(:,1),normFLORIdyn(:,t),'LineWidth',1.5)

hold off
grid on
xlim([0 greedyPowerHist(end,1)])
xlabel('Time [s]')
ylabel('Normalized power [W/W]')
title(['Normalized power output of turbine ' num2str(t-1)])
legend('SOWFA','FLORIDyn')
% scaling
f.Units               = 'centimeters';
f.Position(3)         = 8; % line width


% Set font & size
set(f.Children, ...
    'FontName',     'Frontpage', ...
    'FontSize',     10);
set(gca,'LooseInset', max(get(gca,'TightInset'), 0.04))

% Export
f.PaperPositionMode   = 'auto';
%%
print('ThreeT_changingCt_newI', '-dpng', '-r600')