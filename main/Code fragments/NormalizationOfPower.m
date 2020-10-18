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
xlabel('Time in s')
ylabel('Normalized power generated in W/W')
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
print('Norm_T3_T0', '-dpng', '-r600')
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
xlabel('Time in s')
ylabel('Normalized power generated in W/W')
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
print('Norm_T3_T1', '-dpng', '-r600')
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
xlabel('Time in s')
ylabel('Normalized power generated in W/W')
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
print('Norm_T3_T2', '-dpng', '-r600')