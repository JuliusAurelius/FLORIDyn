function [] = main()

addpath('./WindField')
addpath('./Controller')
addpath('./ObservationPoints')
addpath('./WakeModel')

%% Test Variables
NumChains       = 60;
NumTurbines     = 1;

% Uniform chain length or individual chainlength
%chainLength     = randi(20,NumChains*NumTurbines,1)+1;
chainLength = 80;   

timeStep        = 5;   % in s
SimDuration     = 1000; % in s

Dim = 3;

%% Derived Variables
timeSteps   = 0:timeStep:SimDuration;
NoTimeSteps = length(timeSteps);

% Create the list of turbines with their properties
[tl_pos,tl_D,tl_ayaw,tl_U] = assembleTurbineList(NumTurbines,'Dim',Dim);               % TODO should call layout

%% Create starting OPs and build opList
[op_pos, op_dw, op_r, op_U, op_ayaw, op_t_id, chainList, cl_dstr] =...
    assembleOPList(NumChains,chainLength,tl_D,'sunflower',Dim);

%% Start simulation

for i = 1:NoTimeSteps
    % Update Turbine data to get controller input
    tl_U    = getWindVec(tl_pos);
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
    op_U    = getWindVec(op_pos);
    
    
    % Get r-> u=U*r (NOT u=U(1-r)!!!)
    op_r(:,1) = getR(op_dw, op_ayaw, op_t_id, tl_D, chainList, cl_dstr);
    
    % Get r_f, foreign influence / wake interaction u=U*r*r_f
    r_f = getR_f(...
        op_pos, op_dw, op_r, op_ayaw, op_t_id, chainList, cl_dstr, tl_pos, tl_D);
    op_r(:,1) = op_r(:,1).*r_f;
    
    % Calculate effective windspeed and down wind step d_dw=U*r_g*r_t*t
    dw_step = op_U.*op_r(:,1).*op_r(:,2)*timeStep;
    
    %   ... in world coordinates
    op_pos(:,1:2) = op_pos(:,1:2) + dw_step;
    %   ... in wake coordinates
    op_dw = op_dw + sqrt(dw_step(:,1).^2 + dw_step(:,2).^2);
    
    % FUNCTION TO IMPLEMENT
    % get cw out of relative distribution and dw position 
    %   -> Used here to update y_w and z_w and maybe by getR
    
    % Prepare next time step
    % set r_t = r_f for the chain starting points
    ind = chainList(:,1) + chainList(:,2);
    op_r(ind,2) = r_f(ind);
    % Increment the index of the chain starting entry
    chainList = shiftChainList(chainList);
    
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

%% PLOT

% World coordinates
figure(1)
if size(op_pos,2) == 3 % Dimentions
    scatter3(op_pos(:,1),op_pos(:,2),op_pos(:,3),...
    ones(size(op_t_id))*10,sqrt(sum((op_U.*op_r(:,1)).^2,2)),...
    'filled');
    zlabel('height [m]')
else
    scatter(op_pos(:,1),op_pos(:,2),...
    ones(size(op_t_id))*20,sqrt(sum((op_U.*op_r(:,1)).^2,2))+op_U(:,2)*0.5,...
    'filled');
end

axis equal
colormap parula
c = colorbar;
c.Label.String = 'Windspeed in m/s';
%title(['Proof of concept: wind speed and direction change, ' num2str(length(tl_D)) ' turbines'])
title(['Proof of concept: Simple wake model, 60 chains with 80 observation points'])
xlabel('east - west [m]')
ylabel('south - north [m]')
grid on
end

%% TICKETS
% [x] Include all 3 linked lists: OP[... t_id], chain[OP_entry, start_ind,
%       length, t_id], turbines[...] (chain currently missing)
% [x] Implement shifting the pointers
% [~] Implement the effective yaw calculation
% [x] Which Information is needed to place new initial OPs?
% [x] Add [word_coord. wake_coord. ...] system to OP list
% [ ] Refine getR(), working alpha version (Park Model?) / define Interface
% [x] Refactor code: Move functions to own files.
% [ ] Calc / Set Chainlength (?)
% [x] Set yaw in opList to wake coord.!
% [ ] Visulization / Video
% [ ] Power Output
% [ ] Get one version of r_f working
% [x] 2D implementation