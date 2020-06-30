function main()

addpath('./WindField')
addpath('./Controller')
addpath('./ObservationPoints')
addpath('./WakeModel')

%% Test Variables
NumChains       = 6;
TurbinePosD     = [magic(3),ones(3,1)];
chainLength     = randi(5,NumChains*size(TurbinePosD,1),1)+1;
%chainLength = 5;

timeStep        = 5;   % in s
SimDuration     = 100; % in s


%% Derived Variables
timeSteps   = 0:timeStep:SimDuration;
NoTimeSteps = length(timeSteps);

% [x,y,z,D,a,yaw,P] // World Coordinates
turbineList = [TurbinePosD, zeros(size(TurbinePosD,1),3)];


%% Create starting OPs and build opList
startOPs =  getChainStart(NumChains, TurbinePosD);
[opList, chainList] = assembleOPList(startOPs,chainLength);
clear startOPs TurbinePosD 

%% Start simulation

for i = 1:NoTimeSteps
    % Increment the index of the chain starting entry
    chainList = shiftChainList(chainList);
    
    % Insert new points
    %   At the pointer entry, insert the new OPs at the rotor plane of the
    %   turbines -> distribution strategy
    % TO GET the index, use ind = chainList(:,1) + chainList(:,2);
    
    
    % _____________________ Increment ____________________________________%
    % Update wind dir and speed
    U_OPs = getWindVec(opList(:,1:3));
    U_t   = getWindVec(turbineList(:,1:3));
    
    %====================== CONTROLLER ===================================%
    turbineList(:,5:6) = controller(turbineList);
    %=====================================================================%
    
    % Get effective yaw for each turbine
    yaw_t = getEffectiveYaw(turbineList(:,6), U_t);
    
    % Set 'uninfluenced' Windspeed for all OPs U = U_free*r_t
    opList(:,4:5) = U_OPs.*opList(:,7);
    
    % Get r-> u=U*r (NOT u=U(1-r)!!!)
    opList(:,6) = getR(opList(:,[1:3 8:9])); % TODO which values are needed
    
    % Get r_f, foreign influence / wake interaction u=U*r*r_f
    opList(:,6) = getR_f(opList(:,[1:3 6]));
    
    % Calculate effective windspeed and down wind step d_dw=U*r_g*t
    opList(:,1:2) = opList(:,4:5).*opList(:,6)*timeStep;
    
    % Based on new down wind pos, calculate new crosswind pos (y & z dir)
    opList(:,1:3) = distibutionStrategy(opList);
    
end


% [x,y,z, Ux,Uy, r,r_t, a,yaw, t_id] // World coordinates

end

%% TICKETS
% [x] Include all 3 linked lists: OP[... t_id], chain[OP_entry, start_ind,
%       length, t_id], turbines[...] (chain currently missing)
% [x] Implement shifting the pointers
% [~] Implement the effective yaw calculation
% [ ] Which Information is needed to place new initial OPs?
% [ ] Add [word_coord. wake_coord. ...] system to OP list
% [ ] Refine getR(), working alpha version (Park Model?) / define Interface
% [x] Refactor code: Move functions to own files.