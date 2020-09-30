function [powerHist,OP,T,UF,Sim] = main()
% Add necessary local paths
main_addPaths;

%% Load Layout
%   Load the turbine configuration (position, diameter, hub height,...) the
%   power constants (Efficiency, p_p), data to connect wind speed and
%   power / thrust coefficient and the configuration of the OP-chains:
%   relative position, weights, lengths etc.
%
%   Currently implemented Layouts
%       'twoDTU10MW_Maarten'    -> two turbines at 900m distance
%       'nineDTU10MW_Maatren'   -> nine turbines in a 3x3 grid, 900m dist.
%  
%   Chain length & the number of chains can be set as extra vars, see 
%   comments in the function for additional info.
[T,fieldLims,Pow,VCtCp,chain] = loadLayout('twoDTU10MW_Maarten'); %#ok<ASGLU>

%% Load the environment
%   U provides info about the wind: Speed(s), direction(s), changes.
%   I does the same, but for the ambient turbulence, UF hosts constant
%   used for the wind field interpolation, the air density, atmospheric
%   stability etc. The Sim struct holds info about the simulation: Duration
%   time step, various settings. See comments in the function for 
%   additional info.
% 
%   Currently implemented scenarios:
%       'const'                     -> Constant wind speed, direction and 
%                                       amb. turbulence
%       '+60DegChange'              -> 60 degree wind angle change after
%                                       300s (all places at the same time)  
%       'Propagating40DegChange'    -> Propagating 40 degree wind angle
%                                       change starting after 300s
%
%   Numerous settings can be set via additional arguments, see the comments
%   for more info.
[U, I, UF, Sim] = loadWindField('Propagating40DegChange',... 
    'SimDuration',1000,...
    'FreeSpeed',false,...
    'Interaction',true,...
    'posMeasFactor',2000);

%% Visulization
% Set to true or false, if set to false, the only output is what this
% function returns. Disabeling decreases the computational effort noticably
onlineVis = false;

%% Create starting OPs and build opList
%   Creates the observation point struct (OP) and extends the chain struct.
%   Here, the distribution of the OPs in the wake is set, currently, only
%   the sunflower distribution is avaiable.
[OP, chain] = assembleOPList(chain,T,'sunflower');

%% Preparation for Simulation
%   Script starts the visulization, checks whether the field variables are
%   changing over time, prepares the console progress output and sets
%   values for the turbines and observation points which may not be 0
%   before the simulation starts.
SimulationPrep;

%% Start simulation
for i = 1:Sim.NoTimeSteps
    tic;
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
    
    % Display the current simulation progress
    ProgressScript;
end

%% Store power output together with time line
powerHist = [Sim.TimeSteps',powerHist'];
end
%% ===================================================================== %%
% = Reviewed: 2020.09.30 (yyyy.mm.dd)                                   = %
% === Author: Marcus Becker                                             = %
% == Contact: marcus.becker.mail@gmail.com                              = %
% ======================================================================= %