path = '/ValidationData/csv/';

%% 2T 00
sowfaPower = importGenPowerFile([path '2T_00_torque_generatorPower.csv']);
sowfaPower(:,2) = sowfaPower(:,2)-sowfaPower(1,2);
sowfaPower(:,3) = sowfaPower(:,3)/1.225;

nT = 2;

% Two turbine case
floidynSteadyState2T00 = [4078000,1266000];
startI = (400/0.2)*2+1;
powSOWFA2T00 = sowfaPower(startI:end,3);

PSmean2T00  = zeros(1,nT);
PSstd2T00   = zeros(1,nT);
PSstd2T00Norm = zeros(1,nT);

for iT = 1:nT
    PSmean2T00(iT)      = mean(powSOWFA2T00(iT:nT:end));
    PSstd2T00(iT)       = std(powSOWFA2T00(iT:nT:end));
    PSstd2T00Norm(iT)  = PSstd2T00(iT)/PSmean2T00(iT);
end

err2T00 = PSmean2T00-floidynSteadyState2T00;
relErr2T00 = err2T00./PSmean2T00;
%% 2T 20
sowfaPower = importGenPowerFile([path '2T_20_generatorPower.csv']);
sowfaPower(:,2) = sowfaPower(:,2)-sowfaPower(1,2);
sowfaPower(:,3) = sowfaPower(:,3)/1.225;

% Two turbine case
floidynSteadyState2T20 = [3.7150*10^6,1.673*10^6];
startI = (500/0.2)*2+1;
powSOWFA2T20 = sowfaPower(startI:end,3);
PSmean2T20  = zeros(1,nT);
PSstd2T20   = zeros(1,nT);
PSstd2T20Norm = zeros(1,nT);

for iT = 1:nT
    PSmean2T20(iT)      = mean(powSOWFA2T20(iT:nT:end));
    PSstd2T20(iT)       = std(powSOWFA2T20(iT:nT:end));
    PSstd2T20Norm(iT)   = PSstd2T20(iT)/PSmean2T20(iT);
end
err2T20 = PSmean2T20-floidynSteadyState2T20;
relErr2T20 = err2T20./PSmean2T20;
%% 2T 20 norm
powSOWFA2T20N = powSOWFA2T20./powSOWFA2T00;
PSmean2T20N  = zeros(1,nT);
PSstd2T20N   = zeros(1,nT);
PSstd2T20NNorm   = zeros(1,nT);
for iT = 1:nT
    PSmean2T20N(iT)      = mean(powSOWFA2T20N(iT:nT:end));
    PSstd2T20N(iT)       = std(powSOWFA2T20N(iT:nT:end));
    PSstd2T20NNorm(iT)   = PSstd2T20N(iT)/PSmean2T20N(iT);
end
err2T20Norm = PSmean2T20N-(floidynSteadyState2T20./floidynSteadyState2T00);
relErr2T20Norm = err2T20Norm./PSmean2T20N;
%% 3T 00
sowfaPower = importGenPowerFile([path '3T_00_generatorPower.csv']);
sowfaPower(:,2) = sowfaPower(:,2)-sowfaPower(1,2);
sowfaPower(:,3) = sowfaPower(:,3)/1.225;

% Three turbine case
nT = 3;
floidynSteadyState3T00 = [5.8068*10^6 , 1.6354*10^6, 2.097*10^6];
startI = (400/0.2)*nT+1;
powSOWFA3T00 = sowfaPower(startI:end,3);

PSmean3T00  = zeros(1,nT);
PSstd3T00   = zeros(1,nT);
PSstd3T00Norm = zeros(1,nT);

for iT = 1:nT
    PSmean3T00(iT)      = mean(powSOWFA3T00(iT:nT:end));
    PSstd3T00(iT)       = std(powSOWFA3T00(iT:nT:end));
    PSstd3T00Norm(iT)   = PSstd3T00(iT)/PSmean3T00(iT);
end
err3T00 = PSmean3T00-floidynSteadyState3T00;
relErr3T00 = err3T00./PSmean3T00;