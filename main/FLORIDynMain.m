function [powerHist,OP,T,UF,Sim] = FLORIDynMain(layout)
%% FLORIDyn main function 
% Native FLORIDyn main function
%
% Example: 
% [powerHist,OP,T,UF,Sim] = ...
%       FLORIDynMainSOWFA('twoDTU10MW')
%
% ======================================================================= %
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
Control.Type = 'FLORIDyn_greedy';
Control.init = true;
%% Load Layout
%   Load the turbine configuration (position, diameter, hub height,...) the
%   power constants (Efficiency, p_p), data to connect wind speed and
%   power / thrust coefficient and the configuration of the OP-chains:
%   relative position, weights, lengths etc.
%
%   Currently implemented Layouts
%       'oneDTU10MW'    -> one turbine at 
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
    'SimDuration',1000,...
    'FreeSpeed',true,...
    'Interaction',true,...
    'posMeasFactor',2000,...
    'alpha_z',0.1,...
    'windSpeed',8,...
    'ambTurbulence',0.06);

%% Visulization
% Set to true or false
%   .online: Scattered OPs in the wake with quiver wind field plot
%   .Snapshots: Saves the Scattered OP plots, requires online to be true
%   .FlowField: Plots the flow field at the end of the simulation
%   .PowerOutput: Plots the generated power at the end of the simulation
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
    ProgressScript;
end
%% Store power output together with time line
powerHist = [Sim.TimeSteps',powerHist'];

%% Power plot
if Vis.PowerOutput
    labels = cell(nT,1);
    
    % Plotting
    f = figure;
    hold on
    % ========== FLORIDyn data =========
    for iT = 1:length(T.D)
        plot(powerHist(:,1),powerHist(:,iT+1),'LineWidth',2)
        labels{end-nT+iT} = ['T' num2str(iT-1) ' FLORIDyn'];
    end
    hold off
    
    grid on
    xlim([0 powerHist(end,1)])
    xlabel('Time [s]')
    ylabel('Power generated [W]')
    title('Two turbine case, un-yawed')
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