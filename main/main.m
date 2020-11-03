function [powerHist,OP,T,UF,Sim] = main()
% Add necessary local paths
main_addPaths;

%% Load SOWFA yaw values


%file2val = '/ValidationData/csv/3T_pos_y_';
file2val = '/ValidationData/csv/2T_00_torque_';
%file2val = '/ValidationData/csv/3T_dyn_Ct_';
% Get yaw angle (deg)
yawSOWFA = importYawAngleFile([file2val 'nacelleYaw.csv']);
% % Blade pitch angle (deg)
% bladePitch = importYawAngleFile([file2val 'bladePitch.csv']);
% % Rotor speed (rpm)
% tipSpeed = importYawAngleFile([file2val 'rotorSpeedFiltered.csv']);
% %  Conversion from rpm to m/s tip speed 
% tipSpeed(:,3) = tipSpeed(:,3)*pi*89.2/30; 

% Fix time
yawSOWFA(:,2) = yawSOWFA(:,2)-yawSOWFA(1,2);
% bladePitch(:,2) = bladePitch(:,2)-bladePitch(1,2);
% tipSpeed(:,2) = tipSpeed(:,2)-tipSpeed(1,2);
% load('./TurbineData/Cp_Ct_SOWFA.mat');
% cpInterp = scatteredInterpolant(sowfaData.pitchArray,sowfaData.tsrArray,sowfaData.cpArray,'linear','nearest');
% ctInterp = scatteredInterpolant(sowfaData.pitchArray,sowfaData.tsrArray,sowfaData.ctArray,'linear','none');
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
 [T,fieldLims,Pow,VCpCt,chain] = loadLayout('twoDTU10MW_Maarten'); %#ok<ASGLU>

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
    'SimDuration',yawSOWFA(end,2),...%1000,...%
    'FreeSpeed',true,...
    'Interaction',true,...
    'posMeasFactor',2000,...
    'alpha_z',0.1,...
    'windSpeed',8,...
    'ambTurbulence',0.06);
Sim.reducedInteraction = true;
%% Visulization
% Set to true or false, if set to false, the only output is what this
% function returns. Disabeling decreases the computational effort noticably
onlineVis = false;

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

%% Compare power plot
% Get SOWFA data
powSOWFA_WPS = importGenPowerFile([file2val 'generatorPower.csv']);


labels = cell(2*nT,1);

% Plotting
f = figure;
hold on

% =========== SOWFA data ===========
for iT = 1:nT
    plot(...
        powSOWFA_WPS(iT:nT:end,2)-powSOWFA_WPS(iT,2),...
        powSOWFA_WPS(iT:nT:end,3)/UF.airDen,...
        '-.','LineWidth',1)
    labels{iT} = ['T' num2str(iT-1) ' SOWFA wps'];
end

% ========== FLORIDyn data =========
for iT = 1:length(T.D)
    plot(powerHist(:,1),powerHist(:,iT+1),'LineWidth',1.5)
    labels{nT+iT} = ['T' num2str(iT-1) ' FLORIDyn'];
end

% % Plot second FLORIDyn results
% for iT = 1:length(T.D)
%     plot(powerHist(:,1),powerHist(:,iT+1),'--','LineWidth',1.5)
%     labels{iT} = ['T' num2str(iT-1) ' FLORIDyn'];
% end

% % //// EXTRA YAW  ////
% % Yaw T0
% plot([200,200],[-.3,.3]*10^6+powerHist(51,2),'k','LineWidth',1)
% plot([500,500],[-.3,.3]*10^6+powerHist(126,2),'k','LineWidth',1)
% plot([800,800],[-.3,.3]*10^6+powerHist(201,2),'k','LineWidth',1)
% % Yaw T1
% plot([350,350],[-.3,.3]*10^6+powerHist(89,3),'k','LineWidth',1)
% plot([650,650],[-.3,.3]*10^6+powerHist(164,3),'k','LineWidth',1)
% plot([950,950],[-.3,.3]*10^6+powerHist(239,3),'k','LineWidth',1)
% % 
% legend(...
%     'T0 SOWFA wps','T1 SOWFA wps','T2 SOWFA wps',...
%     'T0 FLORIDyn','T1 FLORIDyn','T2 FLORIDyn')
% % //// EXTRA OVER ////

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
f.Position(3)         = 16.1; % line width

% Set font & size
set(f.Children, ...
    'FontName',     'Frontpage', ...
    'FontSize',     10);
set(gca,'LooseInset', max(get(gca,'TightInset'), 0.04))

% Export
f.PaperPositionMode   = 'auto';
end
%% ===================================================================== %%
% = Reviewed: 2020.09.30 (yyyy.mm.dd)                                   = %
% === Author: Marcus Becker                                             = %
% == Contact: marcus.becker.mail@gmail.com                              = %
% ======================================================================= %