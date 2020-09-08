%% Comparison FLORIDyn to SOWFA data
% Extract turbine power from SOWFA data
load('/Users/marcusbecker/Qsync/Masterthesis/FLORIDyn/main/ValidationData/torqueSteady2T_genPower.mat')
genP_T0 = generatorPower(1:2:end,2:3);
genP_T1 = generatorPower(2:2:end,2:3);
airDenSOWFA = 1.225;
%% Plot against each other
figure
% SOWFA
plot(genP_T0(2:end,1)-genP_T1(1,1),genP_T0(2:end,2)/airDenSOWFA,...
    'LineWidth',2,'Color',[0 0.4470 0.7410]*1)
hold on
plot(genP_T1(2:end,1)-genP_T1(1,1),genP_T1(2:end,2)/airDenSOWFA,...
    'LineWidth',2,'Color',[0 0.4470 0.7410]*0.8)

% FLORIDyn
plot(ans(:,1),ans(:,2)*airDenSOWFA,'--',...
    'LineWidth',2,'Color',[0.8500 0.3250 0.0980]*1)
plot(ans(:,1),ans(:,3)*airDenSOWFA,'--',...
    'LineWidth',2,'Color',[0.8500 0.3250 0.0980]*0.8)

% FLORIS
plot([400,1000],[3.54*1e6 3.54*1e6],'-.',...
    'LineWidth',2,'Color',[0.9290 0.6940 0.1250]*1)
plot([400,1000],[0.67*1e6 0.67*1e6],'-.',...
    'LineWidth',2,'Color',[0.9290 0.6940 0.1250]*0.8)

% Control model
plot([400,1000],[4.87*1e6 4.87*1e6],':',...
    'LineWidth',2,'Color',[0.4660 0.6740 0.1880]*1)
plot([400,1000],[0.29*1e6 0.29*1e6],':',...
    'LineWidth',2,'Color',[0.4660 0.6740 0.1880]*0.8)

hold off
legend('SOWFA T0','SOWFA T1',...
    'FLORIDyn T0','FLORIDyn T1',...
    'average FLORIS T0','average FLORIS T1',...
    'average Control model T0','average Control model T1')
ylabel('Power [W]')
xlabel('Time [s]')
ylim([0,inf])
grid on
title('Comparison FOLRIDyn data to SOWFA data')