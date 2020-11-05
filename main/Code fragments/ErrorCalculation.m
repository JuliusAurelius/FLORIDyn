path = '/ValidationData/csv/';
sowfaPower = importGenPowerFile([path '2T_00_torque_generatorPower.csv']);
sowfaPower(:,2) = sowfaPower(:,2)-sowfaPower(1,2);
sowfaPower(:,3) = sowfaPower(:,3)/1.225;

nT = 2;

% Two turbine case
floidynSteadyState = [4078000,1266000];
startI = (500/0.2)*2+1;
powSOWFA = sowfaPower(startI:end,3);

PSmean  = zeros(1,nT);
PSstd   = zeros(1,nT);
PSerrMean = zeros(1,nT);

figure
hold on

for iT = 1:nT
    PSmean(iT)      = mean(powSOWFA(iT:nT:end));
    PSstd(iT)       = std(powSOWFA(iT:nT:end));
    PSerrMean(iT)   = PSstd(iT)/sqrt(length(powSOWFA(iT:nT:end)));
    
    plot(powSOWFA(iT:nT:end))
    plot([1,length(powSOWFA(iT:nT:end))],[PSmean(iT),PSmean(iT)])
    plot([1,length(powSOWFA(iT:nT:end))],[PSmean(iT)+sqrt(PSstd(iT)),PSmean(iT)+sqrt(PSstd(iT))])
    plot([1,length(powSOWFA(iT:nT:end))],[PSmean(iT)-sqrt(PSstd(iT)),PSmean(iT)-sqrt(PSstd(iT))])
end
%%
figure
histogram(powSOWFA(iT:nT:end))
hold on
x = linspace(1.2*10^6,2.4*10^6,10000);
mu = PSmean(iT);
sigma = PSstd(iT);
f = exp(-(x-mu).^2./(2*sigma^2))./(sigma*sqrt(2*pi));
plot(x,f*10^7,'LineWidth',1.5)