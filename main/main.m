function main()

addpath('./WindField')
addpath('./Controller')
addpath('./ObservationPoints')
addpath('./WakeModel')

%% Test Variables
NumChains       = 6;
NumTurbines     = 3;

% Uniform chain length or individual chainlength
chainLength     = randi(5,NumChains*NumTurbines,1)+1;
%chainLength = 5;   

timeStep        = 5;   % in s
SimDuration     = 100; % in s

%% Derived Variables
timeSteps   = 0:timeStep:SimDuration;
NoTimeSteps = length(timeSteps);

% Create the list of turbines with their properties
turbineList = assembleTurbineList(NumTurbines);               % TODO should call layout


%% Create starting OPs and build opList
startOPs =  getChainStart(NumChains, turbineList(:,1:4));
[opList, chainList] = assembleOPList(startOPs,chainLength);
clear startOPs 

%% Start simulation

for i = 1:NoTimeSteps
    % Insert new points
    opList = initAtRotorplane(opList,chainList,turbineList,'circle');
    
    % _____________________ Increment ____________________________________%
    % Update wind dir and speed
    U_OPs = getWindVec(opList(:,1:3));
    turbineList(:,7:8) = getWindVec(turbineList(:,1:3));
    
    %====================== CONTROLLER ===================================%
    turbineList(:,5:6) = controller(turbineList);
    %=====================================================================%
    
    % Set 'uninfluenced' Windspeed for all OPs U = U_free*r_t
    opList(:,9:10) = U_OPs.*opList(:,8);
    
    % Get r-> u=U*r (NOT u=U(1-r)!!!)
    opList(:,7) = getR(opList(:,[4:6 11:12 13]),turbineList(:,[3:4 6:8]));
    
    % Get r_f, foreign influence / wake interaction u=U*r*r_f
    opList(:,7) = getR_f(opList(:,[1:3 7]));
    
    % Calculate effective windspeed and down wind step d_dw=U*r_g*t
    dw_step = opList(:,9:10).*opList(:,7)*timeStep;
    %   ... in world coordinates
    opList(:,1:2)   = dw_step;
    %   ... in wake coordinates
    opList(:,4)     = sqrt(dw_step(:,1).^2 + dw_step(:,2).^2);
    
    % Based on new down wind pos, calculate new crosswind pos (y & z dir)
    opList(:,1:3) = distibutionStrategy(opList,chainList,'circle');
    
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


end

%% TICKETS
% [x] Include all 3 linked lists: OP[... t_id], chain[OP_entry, start_ind,
%       length, t_id], turbines[...] (chain currently missing)
% [x] Implement shifting the pointers
% [~] Implement the effective yaw calculation
% [ ] Which Information is needed to place new initial OPs?
% [x] Add [word_coord. wake_coord. ...] system to OP list
% [ ] Refine getR(), working alpha version (Park Model?) / define Interface
% [x] Refactor code: Move functions to own files.
% [ ] Calc / Set Chainlength (?)