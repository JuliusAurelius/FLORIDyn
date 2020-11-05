function [powerHist,OP,T,UF,Sim] = FLORIDynMainSOWFA(file2val,layout)
%% FLORIDyn main function to simulate SOWFA simulations
% To run this, modify the SOWFA output files to have the ending .csv they
% are expected to be avaiable under i.e. [file2val 'generatorPower.csv']
%
% Example: 
% [powerHist,OP,T,UF,Sim] = ...
%       FLORIDynMainSOWFA('/ValidationData/csv/2T_00_torque_','twoDTU10MW')
%
% Two options are avaiable:
%   1) Run greedy control
%       Needed files:
%       'nacelleYaw.csv'
%   2) Calculate Ct and Cp based on blade pitch and tip speed ratio
%       Needed files:
%       'nacelleYaw.csv','generatorPower.csv',
%       'bladePitch.csv','rotorSpeedFiltered.csv'
%       ATTENTION!
%       The SOWFA file 'bladePitch.csv' has to be modified to say
%           0     instead of     3{0}
%       Search & delete all "3{" and "}"
%
% Needed for plotting:
%   'generatorPower.csv'
% ======================================================================= %
% INPUT
%   file2val := String; Path to 'nacelleYaw.csv' and 'generatorPower.csv'
%                       if 'bladePitch.csv' and 'rotorSpeedFiltered.csv'
%                       are available at the path, the blade pitch angle
%                       and the tip speed ratio will be used to calculate
%                       Ct and Cp
%   layout   := String  Layout name
%
% OUTPUT
%   powerHist   := [nx(nT+1)] [Time,P_T0,P_T1,...,]
%                             Stores the time and the power output of the 
%                             turbine at that time
%
%   OP          := Struct;    Data related to the state of the OPs
%    .pos       := [nx3] vec; [x,y,z] world coord. (can be nx2)
%    .dw        := [nx1] vec; downwind position (wake coordinates)
%    .yaw       := [nx1] vec; yaw angle (wake coord.) at the time of creat.
%    .Ct        := [nx1] vec; Ct coefficient at the time of creation
%    .t_id      := [nx1] vec; Turbine OP belongs to
%    .U         := [nx2] vec; Uninfluenced wind vector at OP position
%    .u         := [nx1] vec; Effective wind speed at OP position
%
%   T           := Struct;    All data related to the turbines
%    .pos       := [nx3] mat; x & y positions and nacelle height for all n
%                             turbines.
%    .D         := [nx1] vec; Diameter of all n turbines
%    .yaw       := [nx1] vec; Yaw setting of the n turbines    (Allocation)
%    .Ct        := [nx1] vec; Current Ct of the n turbines     (Allocation)
%    .Cp        := [nx1] vec; Current Cp of the n turbines     (Allocation)
%    .P         := [nx1] vec; Power production                 (Allocation)
% 
%   UF          := Struct;    Data connected to the (wind) field
%    .lims      := [2x2] mat; Interpolation area
%    .IR        := [mxn] mat; Maps the n measurements to the m grid points
%                             of the interpolated mesh
%    .Res       := [1x2] mat; x and y resolution of the interpolation mesh
%    .pos       := [nx2] mat; Measurement positions
%    .airDen    := double;    AirDensity
%    .alpha_z   := double;    Atmospheric stability (see above)
%    .z_h       := double;    Height of the measurement
%
%   Sim         := Struct;    Data connected to the Simulation
%    .Duration  := double;    Duration of the Simulation in seconds
%    .TimeStep  := double;    Duration of one time step
%    .TimeSteps := [1xt] vec; All time steps
%    .NoTimeSteps= int;       Number of time steps
%    .FreeSpeed := bool;      OPs traveling with free wind speed or own
%                             speed
%    .WidthFactor= double;    Multiplication factor for the field width
%    .Interaction= bool;      Whether the wakes interact with each other
%    .redInteraction = bool;  All OPs calculate their interaction (false)
%                             or only the OPs at the rotor plane (true)
% ======================================================================= %
% Add necessary local paths
main_addPaths;

%% Check for SOWFA files and load
controllerType = 'SOWFA_greedy_yaw';
if exist([file2val 'nacelleYaw.csv'], 'file') == 2
    % Get yaw angle (deg)
    yawSOWFA = importYawAngleFile([file2val 'nacelleYaw.csv']);
    yawSOWFA(:,2) = yawSOWFA(:,2)-yawSOWFA(1,2);
    
else
    error('nacelleYaw.csv file not avaiable, change link and retry')
end

if exist([file2val 'bladePitch.csv'], 'file') == 2
    try
        bladePitch = importYawAngleFile([file2val 'bladePitch.csv']);
    catch
        error(['bladePitch.csv file not correct formatted, search and '...
            'delete "3{" and "}"'])
    end
    if exist([file2val 'rotorSpeedFiltered.csv'], 'file') == 2
        tipSpeed = importYawAngleFile([file2val 'rotorSpeedFiltered.csv']);
        %  Conversion from rpm to m/s tip speed 
        tipSpeed(:,3) = tipSpeed(:,3)*pi*89.2/30;
    else
        error('rotorSpeedFiltered.csv missing!')
    end
    bladePitch(:,2) = bladePitch(:,2)-bladePitch(1,2);
    tipSpeed(:,2) = tipSpeed(:,2)-tipSpeed(1,2);
    
    load('./TurbineData/Cp_Ct_SOWFA.mat');
    cpInterp = scatteredInterpolant(...
        sowfaData.pitchArray,...
        sowfaData.tsrArray,...
        sowfaData.cpArray,'linear','nearest');
    ctInterp = scatteredInterpolant(...
        sowfaData.pitchArray,...
        sowfaData.tsrArray,...
        sowfaData.ctArray,'linear','nearest');
    controllerType = 'SOWFA_bpa_tsr_yaw';
end

%% Load Layout
%   Load the turbine configuration (position, diameter, hub height,...) the
%   power constants (Efficiency, p_p), data to connect wind speed and
%   power / thrust coefficient and the configuration of the OP-chains:
%   relative position, weights, lengths etc.
%
%   Currently implemented Layouts
%       'twoDTU10MW'    -> two turbines at 900m distance
%       'nineDTU10MW'   -> nine turbines in a 3x3 grid, 900m dist.
%       'threeDTU10MW'  -> three turbines in 1x3 grid, 5D distance
%       'fourDTU10MW'   -> 2x2 grid 
%  
%   Chain length & the number of chains can be set as extra vars, see 
%   comments in the function for additional info.
 [T,fieldLims,Pow,VCpCt,chain] = loadLayout(layout); %#ok<ASGLU>

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
[U, I, UF, Sim] = loadWindField('const',... 
    'windAngle',0,...
    'SimDuration',yawSOWFA(end,2),...
    'FreeSpeed',true,...
    'Interaction',true,...
    'posMeasFactor',2000,...
    'alpha_z',0.1,...
    'windSpeed',8,...
    'ambTurbulence',0.06);

%% Visulization
% Set to true or false, if set to false, the only output is what this
% function returns. Disabeling decreases the computational effort noticably
Vis.online = false;
Vis.Snapshots = false;
Vis.FlowField = false;
Vis.PowerOutput = true;
%% Create starting OPs and build opList
%   Creates the observation point struct (OP) and extends the chain struct.
%   Here, the distribution of the OPs in the wake is set, currently, only
%   the sunflower distribution is avaiable.
%   '2D_horizontal'
%   '2D_vertical'
%   'sunflower'
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
    T.I0 = getAmbientTurbulence(T.pos, UF.IR, I_val, UF.Res, UF.lims);
    % Set Ct/Cp and calculate the power output
    ControllerScript;
    
    %================= INSERT NEW OBSERVATION POINTS =====================%
    OP = initAtRotorPlane(OP, chain, T);
    
    %====================== INCREMENT POSITION ===========================%
    % Update wind dir and speed along with amb. turbulence intensity
    try
        OP.U = getWindVec4(OP.pos, U_abs, U_ang, UF);
    catch
        OP.U = getWindVec4(OP.pos, U_abs, U_ang, UF);
    end
    
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
    if and(Vis.FlowField,i == Sim.NoTimeSteps)
        hold off
        PostSimVis;
    end
    
    % Display the current simulation progress
    ProgressScript;
end
%% Store power output together with time line
powerHist = [Sim.TimeSteps',powerHist'];

%% Compare power plot
if Vis.PowerOutput
    % Plotting
    f = figure;
    hold on
    
    % Get SOWFA data if avaiable
    if exist([file2val 'nacelleYaw.csv'], 'file') == 2
        powSOWFA_WPS = importGenPowerFile([file2val 'generatorPower.csv']);
        labels = cell(2*nT,1);
        % =========== SOWFA data ===========
        for iT = 1:nT
            plot(...
                powSOWFA_WPS(iT:nT:end,2)-powSOWFA_WPS(iT,2),...
                powSOWFA_WPS(iT:nT:end,3)/UF.airDen,...
                '-.','LineWidth',1)
            labels{iT} = ['T' num2str(iT-1) ' SOWFA wps'];
        end
    else
        labels = cell(nT,1);
    end
    
    % ========== FLORIDyn data =========
    for iT = 1:length(T.D)
        plot(powerHist(:,1),powerHist(:,iT+1),'LineWidth',1.5)
        labels{end-nT+iT} = ['T' num2str(iT-1) ' FLORIDyn'];
    end
    
    hold off
    grid on
    xlim([0 powerHist(end,1)])
    xlabel('Time [s]')
    ylabel('Power generated [W]')
    title([num2str(nT) ' turbine case, based on SOWFA data'])
    legend(labels)
    % ==== Prep for export ==== %
    % scaling
    f.Units               = 'centimeters';
    f.Position(3)         = 16.1; % A4 line width
    % Set font & size
    try
        set(f.Children, ...
            'FontName',     'Frontpage', ...
            'FontSize',     10);
    catch
        set(f.Children, ...
            'FontName',     'Arial', ...
            'FontSize',     10);
    end
    set(gca,'LooseInset', max(get(gca,'TightInset'), 0.04))
    f.PaperPositionMode   = 'auto';
end
end
%% ===================================================================== %%
% = Reviewed: 2020.11.03 (yyyy.mm.dd)                                   = %
% === Author: Marcus Becker                                             = %
% == Contact: marcus.becker.mail@gmail.com                              = %
% ======================================================================= %