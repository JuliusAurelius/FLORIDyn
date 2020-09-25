function [powerHist] = main2()

addpath('./WindField')
addpath('./Controller')
addpath('./ObservationPoints')
addpath('./WakeModel')
addpath('./Visulization')
addpath('./TurbineData')

warning('off','MATLAB:scatteredInterpolant:DupPtsAvValuesWarnId')
warning('off','MATLAB:scatteredInterpolant:InterpEmptyTri2DWarnId')

%% Load Layout
[T,fieldLims,Pow,VCtCp,chain] = loadLayout('twoDTU10MW_Maarten');

%% Load the environment
[U, I, UF, Sim] = loadWindField('const');

onlineVis = false;

%% Create starting OPs and build opList
[OP.pos, OP.dw, ~, OP.U, OP.ayaw, OP.t_id, chain.List, chain.dstr] =...
    assembleOPList(chain.NumChains,chain.Length,T.D,T.pos,'sunflower',3);

%% Start simulation
% Online visulization script (1/2)
if onlineVis
    OnlineVis_Start;
end

powerHist = zeros(length(T.D),Sim.NoTimeSteps);
UangVar = size(U.ang,1)>1;
UabsVar = size(U.abs,1)>1;
IVar    = size(I.val,1)>1;
U_ang   = U.ang(1,:);
U_abs   = U.abs(1,:);
I_val   = I.val(1,:);
for i = 1:Sim.NoTimeSteps
    
    % Update measurements if they are variable
    if UangVar; U_ang = U.ang(i,:); end
    if UabsVar; U_abs = U.abs(i,:); end
    if IVar;    I_val = I.val(i,:); end
    
    % Update Turbine data to get controller input
    T.U = getWindVec3(T.pos, UF.IR, U_abs, U_ang, UF.Res, UF.lims);
    
    %====================== CONTROLLER ===================================%
    T.ayaw = controller(T.pos,T.D,T.ayaw,T.U);
    %=====================================================================%
    
    % Insert new points
    [OP.pos, OP.dw, OP.ayaw] = ...
        initAtRotorPlane(...
        OP.pos, OP.dw, OP.ayaw, OP.t_id, chain.List,...
        chain.dstr, T.pos, T.D, T.ayaw, T.U);
    
    % _____________________ Increment ____________________________________%
    % Update wind dir and speed along with amb. turbulence intensity
    OP.U = getWindVec3(OP.pos, UF.IR, U_abs, U_ang, UF.Res, UF.lims);
    OP.I = getAmbientTurbulence(OP.pos, UF.IR, I_val, UF.Res, UF.lims);
    
    % Calculate the down and crosswind steps along with the windspeed at
    % the turbine rotor planes
    OP.pos_old = OP.pos;
    [OP.pos, OP.dw, OP.u, T.u]=makeStep2(...
        OP.pos, OP.dw, OP.ayaw, OP.t_id, OP.U, OP.I,...
        chain.List, chain.dstr, T.pos, T.D, Sim.TimeStep);
    
    % Save power output for plotting
    % 1/2*airdensity*AreaRotor*C_P(a,yaw)*U_eff^3
    powerHist(:,i)=...
        0.5*U.airDen*(T.D/2).^2.*pi.*... %1/2*rho*A
        4.*T.ayaw(:,1).*(1-T.ayaw(:,1)).^2 ... % C_P w/o yaw
        .*T.u.^3.* Pow.eta.*... % u^3*eta
        cos(T.ayaw(:,2)-atan2(T.U(:,2),T.U(:,1))).^Pow.p_p; %C_P to yaw adj
    
    % Increment the index of the chain starting entry
    chain.List = shiftChainList(chain.List);
    
    % Online visulization script (2/2)
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