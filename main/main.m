function [opList, chainList, turbineList] = main()

addpath('./WindField')
addpath('./Controller')
addpath('./ObservationPoints')
addpath('./WakeModel')

%% Test Variables
NumChains       = 20;
NumTurbines     = 2;

% Uniform chain length or individual chainlength
%chainLength     = randi(5,NumChains*NumTurbines,1)+1;
chainLength = 10;   

timeStep        = 5;   % in s
SimDuration     = 100; % in s

%% Derived Variables
timeSteps   = 0:timeStep:SimDuration;
NoTimeSteps = length(timeSteps);

% Create the list of turbines with their properties
[tl_pos,tl_D,tl_ayaw,tl_U] = assembleTurbineList(NumTurbines);               % TODO should call layout

turbineList = [tl_pos,tl_D,tl_ayaw,tl_U];
%% Create starting OPs and build opList
[op_pos, op_dw, op_r, op_U, op_ayaw, op_t_id, chainList, cl_dstr] =...
    assembleOPList(NumChains,chainLength,tl_D);

opList = [op_pos, op_dw, op_r, op_U, op_ayaw, op_t_id];
%% Start simulation

for i = 1:NoTimeSteps
    % Insert new points
    [op_pos, op_dw, op_r, op_ayaw, cl_dstr] = ...
        initAtRotorPlane(...
        op_pos, op_dw, op_ayaw, op_r, op_t_id, chainList,...
        cl_dstr, tl_pos, tl_D, tl_ayaw, tl_U, 'sunflower');
    
    % _____________________ Increment ____________________________________%
    % Update wind dir and speed
    U_OPs   = getWindVec(op_pos);                                           % TO DELETE
    op_U    = getWindVec(op_pos);
    tl_U    = getWindVec(tl_pos);
    %====================== CONTROLLER ===================================%
    tl_ayaw = controller(tl_pos,tl_D,tl_ayaw,tl_U);
    %=====================================================================%
    
    % Get r-> u=U*r (NOT u=U(1-r)!!!)
    opList(:,7) = getR(opList(:,[4:6 11:12 13]),turbineList(:,[3:4 6:8]));  % TO CHANGE
    %op_r(:,1) = getR(op_dw,op_ayaw,op_t_id,chainList,cl_dstr,tl_D)
    
    % Get r_f, foreign influence / wake interaction u=U*r*r_f
    r_f = getR_f(opList(:,[1:7 11:13]),turbineList(:,1:3));                 % TO CHANGE
    opList(:,7) = opList(:,7).*r_f;
    op_r(:,1) = op_r(:,1).*r_f;     %NEW
    
    % Set 'uninfluenced' Windspeed for all OPs U = U_free*r_t
    opList(:,9:10) = U_OPs.*opList(:,8);                                    % TO DELETE
    
    % Calculate effective windspeed and down wind step d_dw=U*r_g*r_t*t
    dw_step = opList(:,9:10).*opList(:,7)*timeStep;                         % TO DELETE
    dw_step = op_U.*op_r(:,1).*op_r(:,2)*timeStep;     %NEW
    
    %   ... in world coordinates
    opList(:,1:2)   = opList(:,1:2) + dw_step;                              % TO DELETE
    op_pos(:,1:2) = op_pos(:,1:2) + dw_step;     %NEW
    %   ... in wake coordinates
    opList(:,4)     = opList(:,4) + sqrt(dw_step(:,1).^2 + dw_step(:,2).^2);% TO DELETE
    op_dw = op_dw + sqrt(dw_step(:,1).^2 + dw_step(:,2).^2);     %NEW
    
    
    % Based on new down wind pos, calculate new crosswind pos (y & z dir)
    %opList(:,1:3) = distibutionStrategy(opList,chainList,'circle');
    % FUNCTION TO IMPLEMENT
    % get cw out of relative distribution and dw position 
    %   -> Used here to update y_w and z_w and maybe by getR
    
    % Prepare next time step
    % set r_t = r_f for the chain starting points
    ind = chainList(:,1) + chainList(:,2);
    opList(ind,8) = r_f(ind); % TO DELETE
    op_r(ind,2) = r_f(ind);     %NEW
    % Increment the index of the chain starting entry
    chainList = shiftChainList(chainList);
    
end

% OP List
% [world     wake             world  world       ]
% [x,y,z, x_w,y_w,z_w, r,r_t, Ux,Uy, a,yaw, t_ind]
% [1,2,3,   4,5,6,      7,8,   9,10, 11,12,   13 ]

% Turbine list
% [world        world   world  ]
% [x,y,z,   D,  a,yaw,  Ux,Uy P]
% [1,2,3,   4,   5,6     7,8  9]

% Chain List
% [                         ]
% [offset start length t_ind]
% [   1     2     3      4  ]

%% PLOT
% Wake coordinates
%scatter3(opList(:,4),opList(:,5),opList(:,6),opList(:,13)*10);

% World coordinates
figure(1)
subplot(3,1,1)

scatter3(opList(:,1),opList(:,2),opList(:,3),...
    opList(:,13)*20,sqrt(sum(opList(:,9:10).^2,2))+opList(:,10)*0.5,...
    'filled');
axis equal
colormap lines
title('Proof of concept: wind speed and direction change, two turbines')
xlabel('east - west [m]')
ylabel('south - north [m]')
zlabel('height [m]')

subplot(3,1,2)
t1 = opList(:,13) == 1;
scatter3(opList(t1,4),opList(t1,5),opList(t1,6),...
    opList(t1,13)*20,sqrt(sum(opList(t1,9:10).^2,2))+opList(t1,10)*0.5,...
    'filled');
axis equal
colormap lines
title('Turbine 1 observation points in wake coordinates, speed change')
xlabel('downwind [m]')
ylabel('crosswind_y [m]')
zlabel('crosswind_z [m]')

subplot(3,1,3)
t2 = opList(:,13) == 2;
scatter3(opList(t2,4),opList(t2,5),opList(t2,6),...
    opList(t2,13)*20,sqrt(sum(opList(t2,9:10).^2,2))+opList(t2,10)*0.5,...
    'filled');
axis equal
colormap lines
title('Turbine 2 observation points in wake coordinates, direction change')
xlabel('downwind [m]')
ylabel('crosswind_y [m]')
zlabel('crosswind_z [m]')
end

%% TICKETS split_OPList - branch
% [x] Split the opList in multiple sub matrices (pos, dw, r, U, a,yaw t_ind)
% [ ] Implement splitted opList list
% [x] Split turbineList
% [ ] Implement splitted turbine list
% [x] Split chainList [not needed]
% [ ] Reduce the number of variables: delete y_w and z_w
% [~] Introduce \sig_y \sig_z factors to the chain matrix - new way of
%       locating the chains in the wake (in progress)
% [ ] Note at which points changes have to be made in order to get 2D/3D
%       running
% [ ] Implement flower distrobution
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
% [ ] Set yaw in opList to wake coord.!
% [ ] Visulization / Video
% [ ] Power Output
% [ ] Get one version of r_f working
% [ ] 2D implementation?
% [ ] How many coordinates are really needed?