path = '/ValidationData/csv/';
sowfaPower00 = importGenPowerFile([path '2T_00_torque_generatorPower.csv']);
sowfaPower00(:,2) = sowfaPower00(:,2)-sowfaPower00(1,2);
sowfaPower00(:,3) = sowfaPower00(:,3)/1.225;

% Two turbine case
floidynSteadyState = [4078000,1266000];
startI = (500/0.2)*2+1;
relErrorT2 = sowfaPower00(startI:end,3);
relErrorT2(1:2:end) = (relErrorT2(1:2:end)-floidynSteadyState(1))./relErrorT2(1:2:end);
relErrorT2(2:2:end) = (relErrorT2(2:2:end)-floidynSteadyState(2))./relErrorT2(2:2:end);

reT0Ave = mean(relErrorT2(1:2:end));
reT1Ave = mean(relErrorT2(2:2:end));

reT0Std = std(relErrorT2(1:2:end)-reT0Ave);
reT1Std = std(relErrorT2(2:2:end)-reT1Ave);

%% 20 deg yawed 2T
sowfaPower = importGenPowerFile([path '2T_20_generatorPower.csv']);
sowfaPower(:,2) = sowfaPower(:,2)-sowfaPower(1,2);
sowfaPower(:,3) = sowfaPower(:,3)/1.225;

% Two turbine case
floidynSteadyState20 = [3.7150*10^6,1.673*10^6];
startI = (500/0.2)*2+1;
relErrorT2_20 = sowfaPower(startI:end,3);
relErrorT2_20(1:2:end) = (relErrorT2_20(1:2:end)-floidynSteadyState20(1))./relErrorT2_20(1:2:end);
relErrorT2_20(2:2:end) = (relErrorT2_20(2:2:end)-floidynSteadyState20(2))./relErrorT2_20(2:2:end);

reT0Ave20 = mean(relErrorT2_20(1:2:end));
reT1Ave20 = mean(relErrorT2_20(2:2:end));

reT0Std20 = std(relErrorT2_20(1:2:end)-reT0Ave);
reT1Std20 = std(relErrorT2_20(2:2:end)-reT1Ave);

%% Normalized 20 deg yawed 2T
relErrorT2_20_Norm = sowfaPower(startI:end,3)./sowfaPower00(startI:end,3);
FLORIDynNorm = floidynSteadyState20./floidynSteadyState;

startI = (500/0.2)*2+1;
relErrorT2_20_Norm(1:2:end) = (relErrorT2_20_Norm(1:2:end)-FLORIDynNorm(1))./relErrorT2_20_Norm(1:2:end);
relErrorT2_20_Norm(2:2:end) = (relErrorT2_20_Norm(2:2:end)-FLORIDynNorm(2))./relErrorT2_20_Norm(2:2:end);

reT0Ave20Norm = mean(relErrorT2_20_Norm(1:2:end));
reT1Ave20Norm = mean(relErrorT2_20_Norm(2:2:end));

reT0Std20Norm = std(relErrorT2_20_Norm(1:2:end)-reT0Ave);
reT1Std20Norm = std(relErrorT2_20_Norm(2:2:end)-reT1Ave);

%%
f = figure;
hold on
histogram(relErrorT2_20_Norm(1:2:end),'Normalization','probability')
histogram(relErrorT2_20_Norm(2:2:end),'Normalization','probability')
hold off
grid on
legend('RE T0','RE T1')
title('Relative error (RE) histogram, normalized two turbine case')
xlabel('Relative error')
ylabel('Probability')
f.Units               = 'centimeters';
f.Position(3)         = 16.1; % line width
set(f.Children, ...
    'FontName',     'Frontpage', ...
    'FontSize',     10);
set(gca,'LooseInset', max(get(gca,'TightInset'), 0.04))

% Export
f.PaperPositionMode   = 'auto';
%% Compare T2 un-yaed to yawed
f = figure;
subplot(2,1,1)
hold on
histogram(relErrorT2(1:2:end),'Normalization','probability')
histogram(relErrorT2_20(1:2:end),'Normalization','probability')
hold off
grid on
legend('RE T0 00','RE T0 20')
title('Relative error (RE) histogram, two turbine case, un-yawed & yawed T0')
xlabel('Relative error')
ylabel('Probability')

subplot(2,1,2)
hold on
histogram(relErrorT2(2:2:end),'Normalization','probability')
histogram(relErrorT2_20(2:2:end),'Normalization','probability')
hold off
grid on
legend('RE T1 00','RE T1 20')
title('Relative error (RE) histogram, two turbine case, un-yawed & yawed T1')
xlabel('Relative error')
ylabel('Probability')

f.Units               = 'centimeters';
f.Position(3)         = 16.1; % line width
set(f.Children, ...
    'FontName',     'Frontpage', ...
    'FontSize',     10);
set(gca,'LooseInset', max(get(gca,'TightInset'), 0.04))

% Export
f.PaperPositionMode   = 'auto';

%% Plot
f = figure;
hold on
histogram(relErrorT2(1:2:end),'Normalization','probability')
histogram(relErrorT2(2:2:end),'Normalization','probability')
hold off

grid on
legend('RE T0','RE T1')
title('Relative error (RE) histogram, two turbine case')
xlabel('Relative error')
ylabel('Probability')

f.Units               = 'centimeters';
f.Position(3)         = 16.1; % line width
set(f.Children, ...
    'FontName',     'Frontpage', ...
    'FontSize',     10);
set(gca,'LooseInset', max(get(gca,'TightInset'), 0.04))

% Export
f.PaperPositionMode   = 'auto';
%% 3 Turbines

sowfaPower = importGenPowerFile([path '3T_00_generatorPower.csv']);
sowfaPower(:,2) = sowfaPower(:,2)-sowfaPower(1,2);
sowfaPower(:,3) = sowfaPower(:,3)/1.225;

% Three turbine case
nT = 3;
floidynSteadyState = [5.8068*10^6 , 1.6354*10^6, 2.097*10^6];
startI = (400/0.2)*nT+1;
relErrorT3 = sowfaPower(startI:end,3);
relAve = zeros(nT,1);
relStd = zeros(nT,1);

f = figure;
hold on

for iT = nT:-1:1
    relErrorT3(iT:nT:end) = ...
        (relErrorT3(iT:nT:end)-floidynSteadyState(iT))./relErrorT3(iT:nT:end);
    relAve(iT) = mean(relErrorT3(iT:nT:end));
    relStd(iT) = std(relErrorT3(iT:nT:end));
    
    histogram(relErrorT3(iT:nT:end),'Normalization','probability')
end

hold off
grid on
legend('RE T2','RE T1','RE T1')
title('Relative error (RE) histogram, two turbine case')
xlabel('Relative error')
ylabel('Probability')

f.Units               = 'centimeters';
f.Position(3)         = 16.1; % line width
set(f.Children, ...
    'FontName',     'Frontpage', ...
    'FontSize',     10);
set(gca,'LooseInset', max(get(gca,'TightInset'), 0.04))

% Export
f.PaperPositionMode   = 'auto';
%% Compare T3 to T2
f = figure;
subplot(3,1,1)
hold on
histogram(relErrorT3(1:3:end),'Normalization','probability')
histogram(relErrorT2(1:2:end),'Normalization','probability')
hold off
grid on
legend('RE T0 (3T)','RE T0 (2T)')
title('Relative error (RE) histogram, two and three turbine case, T0')
xlabel('Relative error')
ylabel('Probability')

subplot(3,1,2)
hold on
histogram(relErrorT3(2:3:end),'Normalization','probability')
histogram(relErrorT2(2:2:end),'Normalization','probability')
hold off
grid on
legend('RE T1 (3T)','RE T1 (2T)')
title('Relative error (RE) histogram, two and three turbine case, T1')
xlabel('Relative error')
ylabel('Probability')

subplot(3,1,3)
hold on
histogram(relErrorT3(3:2:end),'Normalization','probability')
hold off
grid on
legend('RE T2 (3T)')
title('Relative error (RE) histogram, three turbine case, T2')
xlabel('Relative error')
ylabel('Probability')

f.Units               = 'centimeters';
f.Position(3)         = 16.1; % line width
set(f.Children, ...
    'FontName',     'Frontpage', ...
    'FontSize',     10);
set(gca,'LooseInset', max(get(gca,'TightInset'), 0.04))

% Export
f.PaperPositionMode   = 'auto';