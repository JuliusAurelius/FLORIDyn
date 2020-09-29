function [powerHist,OP,T,UF,Sim] = main2()

addpath('./WindField')
addpath('./Controller')
addpath('./ObservationPoints')
addpath('./WakeModel')
addpath('./Visulization')
addpath('./TurbineData')

%% Load Layout
[T,fieldLims,Pow,VCtCp,chain] = loadLayout('twoDTU10MW_Maarten'); %#ok<ASGLU>

%% Load the environment
[U, I, UF, Sim] = loadWindField('const',... %'+60DegChange'
    'SimDuration',1000,...
    'FreeSpeed',true,...
    'Interaction',false);

onlineVis = true;

%% Create starting OPs and build opList
[OP, chain] = assembleOPList(chain,T,'sunflower');

%% Preparation for Simulation
% Online visulization script (1/2)
if onlineVis
    OnlineVis_Start;
end

% Check if field variables are changing over Simulation time
UangVar = size(U.ang,1)>1;
UabsVar = size(U.abs,1)>1;
IVar    = size(I.val,1)>1;
U_ang   = U.ang(1,:);
U_abs   = U.abs(1,:);
I_val   = I.val(1,:);

% Preallocate the power history
powerHist = zeros(length(T.D),Sim.NoTimeSteps);

% Set free wind speed as starting wind speed for the turbines
T.U = getWindVec4(T.pos, U_abs, U_ang, UF);
T.u = sqrt(T.U(:,1).^2+T.U(:,2).^2);
i = 1; % Maybe needed for Controlle Script
ControllerScript;
OP.Ct = T.Ct(OP.t_id);
%% Start simulation
for i = 1:Sim.NoTimeSteps
    
    % Update measurements if they are variable
    if UangVar; U_ang = U.ang(i,:); end
    if UabsVar; U_abs = U.abs(i,:); end
    if IVar;    I_val = I.val(i,:); end
    
    %================= CONTROLLER & POWER CALCULATION ====================%
    % Update Turbine data to get controller input
    T.U = getWindVec4(T.pos, U_abs, U_ang, UF);
    
    % Set Ct/Cp and calculate the power output
    ControllerScript;
    
    %================= INSERT NEW OBSERVATION POINTS =====================%
    OP = initAtRotorPlane(OP, chain, T);
    
    %====================== INCREMENT POSITION ===========================%
    % Update wind dir and speed along with amb. turbulence intensity
    OP.U = getWindVec4(OP.pos, U_abs, U_ang, UF);
    OP.I = getAmbientTurbulence(OP.pos, UF.IR, I_val, UF.Res, UF.lims);
    
    % Save old position for plotting if needed
    if onlineVis; OP_pos_old = OP.pos;end %#ok<NASGU>
    
    % Calculate the down and crosswind steps along with the windspeed at
    % the turbine rotor planes
    [OP, T]=makeStep2(OP, chain, T, Sim);
    
    % Increment the index of the chain starting entry
    chain.List = shiftChainList(chain.List);
    
    %===================== ONLINE VISULIZATION ===========================%
    % Script (2/2)
    if onlineVis
        OnlineVis_plot;
        if i == Sim.NoTimeSteps
            hold off
            PostSimVis;
        end
    end
end
%% Store power output together with time line
powerHist = [Sim.TimeSteps',powerHist'];
end