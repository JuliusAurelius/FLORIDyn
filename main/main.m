function [powerHist] = main()

addpath('./WindField')
addpath('./Controller')
addpath('./ObservationPoints')
addpath('./WakeModel')
addpath('./Visulization')
addpath('./TurbineData')

warning('off','MATLAB:scatteredInterpolant:DupPtsAvValuesWarnId')
warning('off','MATLAB:scatteredInterpolant:InterpEmptyTri2DWarnId')

%% Test Variables
NumChains       = 100;

% Uniform chain length or individual chainlength
%chainLength     = randi(20,NumChains*NumTurbines,1)+1;
%chainLength = [ones(NumChains,1)*120;ones(NumChains,1)*80];   
chainLength = 200;

timeStep        = 4;   % in s
SimDuration     = 250*timeStep; % in s

Dim = 3;

onlineVis = true;
%% Derived Variables
timeSteps   = 0:timeStep:SimDuration;
NoTimeSteps = length(timeSteps);

% Create the list of turbines with their properties
[tl_pos,tl_D,tl_ayaw,fieldLims] = assembleTurbineList('nineDTU10MW','Dim',Dim);

%% Get Wind Field
% Generate wind field
[U_abs,U_ang,pos] = genU_sig2(NoTimeSteps);

% Ambient turbulence intensity
I = ones(size(U_abs(1,:)))*0.06; % Constant

% number of x and y points / resolution
ufx_n = 60;
ufy_n = 30;
uf_n = [ufx_n,ufy_n];
uf_lims = ...
    [max(pos(:,1))-min(pos(:,1)),max(pos(:,2))-min(pos(:,2));...
    min(pos(:,1)),min(pos(:,2))];

[ufieldx,ufieldy] = meshgrid(...
    linspace(min(pos(:,1)),max(pos(:,1)),uf_n(1)),...
    linspace(min(pos(:,2)),max(pos(:,2)),uf_n(2)));

IR = createIRMatrix(pos,[fliplr(ufieldx(:)')',fliplr(ufieldy(:)')'],'natural');

%% Create starting OPs and build opList
[op_pos, op_dw, ~, op_U, op_ayaw, op_t_id, chainList, cl_dstr] =...
    assembleOPList(NumChains,chainLength,tl_D,tl_pos,'sunflower',Dim);

%% Start simulation
% Online visulization script (1/2)
if onlineVis
    OnlineVis_Start;
end

powerHist = zeros(length(tl_D),NoTimeSteps);


for i = 1:NoTimeSteps
    
    % Update Turbine data to get controller input
    tl_U = getWindVec3(tl_pos, IR, U_abs(i,:), U_ang(i,:), uf_n, uf_lims);
    
    %====================== CONTROLLER ===================================%
    tl_ayaw = controller(tl_pos,tl_D,tl_ayaw,tl_U);
    %=====================================================================%
    
    % Insert new points
    [op_pos, op_dw, op_ayaw] = ...
        initAtRotorPlane(...
        op_pos, op_dw, op_ayaw, op_t_id, chainList,...
        cl_dstr, tl_pos, tl_D, tl_ayaw, tl_U);
    
    % _____________________ Increment ____________________________________%
    % Update wind dir and speed along with amb. turbulence intensity
    op_U = getWindVec3(op_pos, IR, U_abs(i,:), U_ang(i,:), uf_n, uf_lims);
    op_I = getAmbientTurbulence(op_pos, IR, I, uf_n, uf_lims);
    
    % Calculate the down and crosswind steps along with the windspeed at
    % the turbine rotor planes
    op_pos_old = op_pos;
    [op_pos, op_dw, op_u, tl_u]=makeStep2(...
        op_pos, op_dw, op_ayaw, op_t_id, op_U, op_I,...
        chainList, cl_dstr, tl_pos, tl_D, timeStep);
    
    % Save power output for plotting
    % 1/2*airdensity*AreaRotor*C_P(a,yaw)*U_eff^3
    %airDen  = 1.1716; %kg/m^3
    airDen  = 1.225;    % SOWFA
    eta     = 1.08;     %Def. DTU 10MW
    p_p     = 1.50;     %Def. DTU 10MW
    powerHist(:,i)=...
        0.5*airDen*(tl_D/2).^2.*pi.*... %1/2*rho*A
        4.*tl_ayaw(:,1).*(1-tl_ayaw(:,1)).^2 ... % C_P w/o yaw
        .*tl_u.^3.* eta.*... % u^3*eta
        cos(tl_ayaw(:,2)-atan2(tl_U(:,2),tl_U(:,1))).^p_p; %C_P to yaw adj
    
    % Increment the index of the chain starting entry
    chainList = shiftChainList(chainList);
    
    % Online visulization script (2/2)
    if onlineVis
        OnlineVis_plot;
        if i == NoTimeSteps
            hold off
            PostSimVis;
        end
    end
end
powerHist = [timeSteps',powerHist'./airDen];
end

%% Variables

% OP Data
%   op_pos      := [n x 3] vec; [x,y,z] world coord. (can be nx2)
%   op_dw       := [n x 1] vec; downwind position
%   op_r        := [n x 2] vec; [r_own, r_turbine]
%   op_ayaw     := [n x 2] vec; axial induction factor and yaw (wake coord.)
%   op_t_id     := [n x 1] vec; Turbine op belongs to
%   op_U        := [n x 2] vec; Uninfluenced wind vector at OP position
%
% Chain Data
%   chainList   := [n x 5] vec; (see at the end of the function)
%   cl_dstr     := [n x 1] vec; Distribution relative to the wake width
%
% Turbine Data
%   tl_pos      := [n x 3] vec; [x,y,z] world coord. (can be nx2)
%   tl_D        := [n x 1] vec; Turbine diameter
%   tl_ayaw     := [n x 2] vec; axial induction factor and yaw (world coord.)
%   tl_U        := [n x 2] vec; Wind vector [Ux,Uy] (world coord.)
%
% chainList
% [ off, start_id, length, t_id, relArea]

%% TICKETS
% [ ] Optimized wake interaction
% [ ] Add atmospheric stability factor (min(z,z_h)/z_h)^alpha
% [x] Get rid of temporary fix of the wake expansion
% [x] Delete op_r in main (should only exist in makeStep)
% [x] Implement Bastankhah
% [x] Implement a wind grid for nearest neighbour interpolation
%       [x] Test if own interpolation (coord. -> index) is faster
% [~] Implement wake interaction
% [x] Disable r_T
% [x] Calculate Power Output
% [~] See if it can be formulated as observer or similar