function [] = main()

addpath('./WindField')
addpath('./Controller')
addpath('./ObservationPoints')
addpath('./WakeModel')
addpath('./Visulization')

%% Test Variables
NumChains       = 150;
NumTurbines     = 1;

% Uniform chain length or individual chainlength
%chainLength     = randi(20,NumChains*NumTurbines,1)+1;
chainLength = 60;   

timeStep        = 4;   % in s
SimDuration     = 400; % in s

Dim = 2;

onlineVis = true;
%% Derived Variables
timeSteps   = 0:timeStep:SimDuration;
NoTimeSteps = length(timeSteps);

% Create the list of turbines with their properties
[tl_pos,tl_D,tl_ayaw,tl_U] = assembleTurbineList(NumTurbines,'Dim',Dim);               % TODO should call layout

%% Get Wind Vector
U_sig = genU_sig(NoTimeSteps);

%% Create starting OPs and build opList
[op_pos, op_dw, op_r, op_U, op_ayaw, op_t_id, chainList, cl_dstr] =...
    assembleOPList(NumChains,chainLength,tl_D,tl_pos,'sunflower',Dim);

%% Start simulation
% Online visulization script (1/4)
if onlineVis
    OnlineVis_Start;
end

for i = 1:NoTimeSteps
    % Online visulization script (2/4)
    if onlineVis
    	OnlineVis_deletePoints;
    end
    
    % Update Turbine data to get controller input
    tl_U    = getWindVec(tl_pos,i,U_sig);
    %====================== CONTROLLER ===================================%
    tl_ayaw = controller(tl_pos,tl_D,tl_ayaw,tl_U);
    %=====================================================================%
    
    % Insert new points
    [op_pos, op_dw, op_r, op_ayaw] = ...
        initAtRotorPlane(...
        op_pos, op_dw, op_ayaw, op_r, op_t_id, chainList,...
        cl_dstr, tl_pos, tl_D, tl_ayaw, tl_U);
    
    % _____________________ Increment ____________________________________%
    % Update wind dir and speed
    op_U    = getWindVec(op_pos,i,U_sig);
    
    % Calculate the down and crosswind steps along with the windspeed at
    % the turbine rotor planes
    [op_pos, op_dw, op_u, u_t]=makeStep(...
        op_pos, op_dw, op_ayaw, op_t_id, op_U,...
        chainList, cl_dstr, tl_pos, tl_D, timeStep);
    
    % Increment the index of the chain starting entry
    chainList = shiftChainList(chainList);
    
    % Online visulization script (3/4)
    if onlineVis
        OnlineVis_plot;
    end
end

% Online visulization script (4/4)
if onlineVis
    hold off
end
%% PLOT
%PostSimVis;
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
%   chainList   := [n x 1] vec; (see at the end of the function)
%   cl_dstr     := [n x 1] vec; Distribution relative to the wake width
%
% Turbine Data
%   tl_pos      := [n x 3] vec; [x,y,z] world coord. (can be nx2)
%   tl_D        := [n x 1] vec; Turbine diameter
%   tl_ayaw     := [n x 2] vec; axial induction factor and yaw (world coord.)
%   tl_U        := [n x 2] vec; Wind vector [Ux,Uy] (world coord.)

%% TICKETS
% [ ] Get rid of temporary fix of the wake expansion
% [~] Implement Bastankhah
% [ ] Implement a wind grid for nearest neighbour interpolation
%       [ ] Test if own interpolation (coord. -> index) is faster
% [ ] Implement wake interaction
% [ ] Disable r_T
% [ ] Calculate Power Output
% [ ] See if it can be formulated as observer or similar
% [ ] Get one version of r_f working
% [ ] Calc / Set Chainlength (?)