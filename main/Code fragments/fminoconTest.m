function fminoconTest()
%% Preperation
main_addPaths;
controllerType = 'FLORIDyn_greedy';
[T,fieldLims,Pow,VCpCt,chain] = loadLayout('threeDTU10MW');
[U, I, UF, Sim] = loadWindField('const',... 
    'windAngle',0,...
    'SimDuration',440,...
    'FreeSpeed',true,...
    'Interaction',true,...
    'posMeasFactor',2000,...
    'alpha_z',0.1,...
    'windSpeed',8,...
    'ambTurbulence',0.06);
Vis.online = false;
Vis.Snapshots = false;
Vis.FlowField = false;
Vis.PowerOutput = true;
[OP, chain] = assembleOPList(chain,T,'sunflower');
load('./TurbineData/Cp_Ct_SOWFA.mat');
Control.cpInterp = scatteredInterpolant(...
    sowfaData.pitchArray,...
    sowfaData.tsrArray,...
    sowfaData.cpArray,'linear','nearest');
Control.ctInterp = scatteredInterpolant(...
    sowfaData.pitchArray,...
    sowfaData.tsrArray,...
    sowfaData.ctArray,'linear','nearest');
Control.Type = 'MPC';
% Control.tsr = ones(3,1)*7;
% Control.bpa = ones(3,1)*5;
%Control.yaw = ones(3,1)*0;

Control.axi = ones(3,1)/3;
Control.yaw = ones(3,1)*1;

Control.init = true;
%% MPC test
% Simulate until steady state
[powerHist,OP,T,chain]=FLORIDyn(T,OP,U,I,UF,Sim,fieldLims,Pow,VCpCt,chain,Vis,Control);
powTotal = cell(11,1);
ConTotal = cell(11,1);
%ConTotal{1} = [Control.tsr;Control.bpa;Control.yaw];
ConTotal{1} = [Control.axi;Control.yaw];
powTotal{1} = powerHist;
baseLine = powerHist(end,2:end);
%% FMOINCON Test
nT = 3; % Number of turbines
nK = 2; % Number of time steps
nV = 2; % Number of control variables

% Switch to optimization step duration
SimDuration = 80;
timeSteps   = 0:Sim.TimeStep:SimDuration;
NoTimeSteps = length(timeSteps);
Sim.Duration    = SimDuration;
Sim.TimeSteps   = timeSteps;
Sim.NoTimeSteps = NoTimeSteps;
Control.init = false;

cInp = ones(nT*nK*nV,1)*1;
cInp(1:nT*nK) = 1;
A = [];
b = [];
Aeq = [];
beq = [];
lb = zeros(nT*nK*nV,1);
ub = ones(nT*nK*nV,1);
nonlcon = [];
options = optimoptions('fmincon','PlotFcn','optimplotfval','Algorithm','sqp');
% b(1:nT*nK)           = 14;         % tsr max
% b(nT*nK+1:2*nT*nK)   = 5;          % bpa max
% b(2*nT*nK+1:3*nT*nK) = 20/180*pi;  % yaw max
% b(3*nT*nK+1:4*nT*nK) = 4;          % tsr min
% b(4*nT*nK+1:5*nT*nK) = 0;          % bpa min
% b(5*nT*nK+1:6*nT*nK) = -20/180*pi; % yaw min
for k = 1:10
    % Optimization
    helpOpt = @(x) surrogareModel(x,T,OP,U,I,UF,Sim,fieldLims,Pow,VCpCt,chain,Vis,Control);
    cInp = fmincon(helpOpt,cInp,A,b,Aeq,beq,lb,ub,nonlcon,options);
    
    % Apply optimal values
    nInputs = length(cInp)/nV;
%     tsr = cInp(1:nInputs)*6 + 4;             %[-]
%     bpa = cInp(nInputs+1:2*nInputs)*10;   %deg
%     yaw = (cInp(2*nInputs+1:3*nInputs)*40-20)/180*pi; %rad
    axi = cInp(1:nInputs)*0.33;             %[-]
    yaw = (cInp(nInputs+1:2*nInputs)*40-20)/180*pi; %rad
    
    % Order:
    % tsp = [(t1 k1);(t1 k2);(t1 k3);(t2 k1);(t2 k2);(t2 k3); ... ]
    
    % Simulate 20s
%     Control.tsr = tsr(1:nK:end);
%     Control.bpa = bpa(1:nK:end);
%     Control.yaw = yaw(1:nK:end);
    Control.axi = axi(1:nT);
    Control.yaw = yaw(1:nT);
    try
        [powerHist,OP,T,chain]=FLORIDyn(T,OP,U,I,UF,Sim,fieldLims,Pow,VCpCt,chain,Vis,Control);
    catch
        disp('Error')
    end
    powTotal{k+1} = powerHist;
    ConTotal{1+k} = [Control.axi;Control.yaw];
end
end

function summedP = surrogareModel(cInp,T,OP,U,I,UF,Sim,fieldLims,Pow,VCpCt,chain,Vis,Control)
nT = 3; % Number of turbines
nK = 2; % Number of time steps
nV = 2; % Number of control variables

%% Get turbine inputs
nInputs = length(cInp)/nV;
% tsr = cInp(1:nInputs)*6 + 4;             %[-]
% bpa = cInp(nInputs+1:2*nInputs)*10;   %deg
% yaw = (cInp(2*nInputs+1:3*nInputs)*40-20)/180*pi; %rad
axi = cInp(1:nInputs)*(1/3-0.1)+0.1;             %[-]
yaw = (cInp(nInputs+1:2*nInputs)*40-20)/180*pi; %rad
% Order:
% tsp = [(t1 k1);(t1 k2);(t1 k3);(t2 k1);(t2 k2);(t2 k3); ... ]

for k = 1:nK
    % Set control variables
%     Control.tsr = tsr(k:nK:end);
%     Control.bpa = bpa(k:nK:end);
%     Control.yaw = yaw(k:nK:end);
    Control.axi = axi((k-1)*nT+1:k*nT);
    Control.yaw = yaw((k-1)*nT+1:k*nT);
    
    % Simulate
    try
        [powerHist,OP,T,chain]=FLORIDyn(T,OP,U,I,UF,Sim,fieldLims,Pow,VCpCt,chain,Vis,Control);
    catch
        disp('Error')
    end
end
summedP = -(sum(powerHist(:,2:end),'all'));
disp(['Cost: ' num2str(-summedP*10^(-6))])
end

function [powerHist,OP,T,chain]=FLORIDyn(T,OP,U,I,UF,Sim,fieldLims,Pow,VCpCt,chain,Vis,Control)
%% Preparation for Simulation
%   Script starts the visulization, checks whether the field variables are
%   changing over time, prepares the console progress output and sets
%   values for the turbines and observation points which may not be 0
%   before the simulation starts.
SimulationPrep;

for k = 1:Sim.NoTimeSteps
    tic;
    % Update measurements if they are variable
    if UangVar; U_ang = U.ang(k,:); end
    if UabsVar; U_abs = U.abs(k,:); end
    if IVar;    I_val = I.val(k,:); end
    
    %================= CONTROLLER & POWER CALCULATION ====================%
    % Update Turbine data to get controller input
    T.U = getWindVec4(T.pos, U_abs, U_ang, UF);
    T.I0 = getAmbientTurbulence(T.pos, UF.IR, I_val, UF.Res, UF.lims);
    % Set Ct/Cp and calculate the power output
    ControllerScript;
    
    %================= INSERT NEW OBSERVATION POINTS =====================%
    OP = initAtRotorPlane(OP, chain, T);
    
    %====================== INCREMENT POSITION ===========================%
    % Update wind dir and speed along with amb. turbulence intensity
    OP.U = getWindVec4(OP.pos, U_abs, U_ang, UF);
    
    OP.I_0 = getAmbientTurbulence(OP.pos, UF.IR, I_val, UF.Res, UF.lims);
    
    % Save old position for plotting if needed
    if Vis.online; OP_pos_old = OP.pos;end %#ok<NASGU>
    
    % Calculate the down and crosswind steps along with the windspeed at
    % the turbine rotor planes
    [OP, T]=makeStep2(OP, chain, T, Sim);
    
    % Increment the index of the chain starting entry
    chain.List = shiftChainList(chain.List);
    
    %===================== ONLINE VISULIZATION ===========================%
    if Vis.online; OnlineVis_plot; end
    if and(Vis.FlowField,k == Sim.NoTimeSteps)
        hold off
        PostSimVis;
    end
    
    % Display the current simulation progress
    %ProgressScript;
end

%% Store power output together with time line
powerHist = [Sim.TimeSteps',powerHist'];
%disp(sum(powerHist(end,2:end)))
end

% summed = [
%     powTotal{1}(2:end,2:end);
%     powTotal{2}(2:end,2:end);
%     powTotal{3}(2:end,2:end);
%     powTotal{4}(2:end,2:end);
%     powTotal{5}(2:end,2:end);
%     powTotal{6}(2:end,2:end);
%     powTotal{7}(2:end,2:end);
%     powTotal{8}(2:end,2:end);
%     powTotal{9}(2:end,2:end);
%     powTotal{10}(2:end,2:end);
%     powTotal{11}(2:end,2:end)];