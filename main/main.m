function main()
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

%% Reduction methods

function r = getR(OPs)
% getR calculates the reduction factor of the wind velocity to get the
% effective windspeed based on the eq. u = U*r
%
% INPUT
% OPs           := [n x 5] vector [x,y,z,a,yaw] in World coordinates
%
% OUTPUT
% r             := [n x 1] vector reduction factor
%

% ==================== !!!!DUMMY METHOD!!!! ====================== % 
% ================= should link to wake models =================== %

r = zeros(size(OPs,1),1);
end

function r = getR_f(OPs)
% getR_f calculates the reduction influence of other OPs/wakes and
% multiplies it to the natural wake reduction
%
% INPUT
% OPs           := [n x 4] vector [x,y,z,r] in World coordinates
%
% OUTPUT
% r             := [n x 1] vector reduction factor
%

% ==================== !!!!DUMMY METHOD!!!! ====================== % 
% ================= should link to wake models =================== %

r = OPs(:,4).*zeros(size(OPs,1),1);
end


%% CONTROLLER

function a_yaw = controller(turbines)
% ==================== !!!!DUMMY METHOD!!!! ====================== % 
    % CONTROLLER sets a and yaw (in world coordinates!) for each turbine.
    a_yaw = ones(size(turbines(:,5:6)))*[0.3, 0; 0, 0]; % TODO Placeholder
end

%% WIND FIELD DIRECTION AND VELOCITY

function U = getWindVec(pos)
% GETWINDVEC returns a free wind vector (== speed and direction) for the
% position(s) given as a [x,y] vector
%
% INPUT
% NumChains     := [n x 3] vector with postions [x,y,z]// World coordinates
%
% OUTPUT
% u             := [n x 2] vector with the [ux, uy] velocities

% ========================= TODO ========================= 
% ///////////////////////// LINK Wind Dir  //////////

U = ones(size(pos,1),2);                                 % TODO Placeholder
end

%% OP Methods
% Initialize 
function xyz = distibutionStrategy(opList)
% ==================== !!!!DUMMY METHOD!!!! ====================== % 
xyz = ones(size(opList,1),3);
end

% Create chain starting OPs
function OPs = getChainStart(NumChains, TurbinePosD)
% getChainStart creates starting points of the chains based on the number
% of chains and the turbines
%
% INPUT
% NumChains     := Int
% TurbinePosD   := [nx4] vector, [x,y,z,d] // World coordinates & in m
%
% OUTPUT
% OPs           := [(n*m)x5] m Chain starts [x,y,z,t_id, d] per turbine

% Allocation
OPs = zeros(NumChains*size(TurbinePosD,1),6);

% assign each OP to a turbine (first all OPs from turbine 1, then t2 etc.)
t_ind   = repmat(1:size(TurbinePosD,1),NumChains,1);
t_d     = repmat(TurbinePosD(:,end)',NumChains,1);
c_ind   = repmat((1:NumChains)',size(TurbinePosD,1),1);

OPs(:,4) = t_ind(:);    % Turbine index
OPs(:,5) = t_d(:);      % Turbine diameter
OPs(:,6) = c_ind;       % Chain index


% ========================= TODO ========================= 
% ///////////////////////// Strategy to create points ////
OPs(:,1:3) = ones(NumChains*size(TurbinePosD,1),3);     % TODO Placeholder
% ////////////////////////////////////////////////////////
end

% Create the OP matrix
function [opList, chainList] = assembleOPList(startOPs,chainLength)
% assembleOPList creates a list of OPs with entries for the starting points 
% and the rest being 0
% 
% INPUT
% startOPs      := [n x 6] vector [x,y,z,t_id,D,c_id]  // World coordinates
% chainLength   := [n x 1] vector
% chainLength   := Int
%
% OUTPUT
% opList        := [n x vars]
% chainList     := [n x 4] matrix [offset from start ind to current OP, 
%                   starting ind, chain length, turbine ind]
%
% startInd_T    := [n x 2] starting Indices for all chain lengths and which 
%                   turbine they belong to.
%
% [x,y,z, Ux,Uy, r,r_t, a,yaw, t_id] // World coordinates
% ==== Constants ==== %
NumOfVariables  = 10;
numChains       = size(startOPs,1);
chainList      = zeros(numChains,4);
chainList(:,4) = startOPs(:,4);

% ==== Build Chains ==== %
if length(chainLength)==numChains
    % diverse length, for every chain there is a length.
    
    % Get starting indeces
    chainList(:,1) = cumsum(chainLength')'-chainLength+1;
    
    % Allocate opList
    opList = zeros(sum(chainLength), NumOfVariables);
    
else
    % Uniform length
    chainList(:,1) = cumsum(ones(1,numChains)*chainLength)'-chainLength+1;
    
    % Allocate opList
    opList = zeros(chainList(end,1), NumOfVariables);
end

% Starting index = first OP index
chainList(:,2) = chainList(:,1);
chainList(:,3) = chainLength;

% Insert the starting OPs in the opList
opList(chainList(:,1),[1:3 end]) = startOPs(:,1:4);
% ==== To change last entry to diameter uncomment the following line ==== %
% opList(startInd_T(:,1),[1:3 end]) = startOPs(:,[1:3 5]);

end

%% Utility methods

function yaw_t = getEffectiveYaw(t_orientation, U)
% GETEFFECTIVEYAW returns the effective yaw angle between the wind
% direction and the turbine orientation.
%
% INPUT
% t_orientation := [n x 1] Angle of the turbine in world coordinates
%                   looking WITH the wind (backwards)
% U             := [n x 2] Wind vector [ux,uy] at the location of the
%                           turbine in world coordinates
%
% OUTPUT
% yaw_t         := [n x 1] vector with the effective yaw angles [-pi,+pi]

% ========================= TODO ========================= 
% Vec to angle
%
% get effective angle
ang_wind = atan2(U(:,1),U(:,2));
yaw_t = mod((ang_wind-t_orientation) + pi/2,pi)-pi/2;

% needs checking!!!
%   -> equivalent to angdiff?
%   -> right sign?
%   -> right values?
% Eq. based on
% https://stackoverflow.com/questions/1878907/the-smallest-difference-between-2-angles
end


function chainList = shiftChainList(chainList)
%   Move the pointer to the next index of the chain, in a manner that
%   it is pointing to the oldest OP, which will now be replaced.
%
% INPUT
% chainList := [n x 4] matrix [offset from start ind to old OP, 
%                   starting ind, chain length, turbine ind]
%
% OUTPUT
% chainList := [n x 4] matrix [offset from start ind to current OP, 
%                   starting ind, chain length, turbine ind]

chainList(:,1) = mod(chainList(:,1) + 1, chainList(:,3));
end


%% TICKETS
% [x] Include all 3 linked lists: OP[... t_id], chain[OP_entry, start_ind,
%       length, t_id], turbines[...] (chain currently missing)
% [x] Implement shifting the pointers
% [~] Implement the effective yaw calculation
% [ ] Which Information is needed to place new initial OPs?
% [ ] Add [word_coord. wake_coord. ...] system to OP list
% [ ] Refine getR(), working alpha version (Park Model?) / define Interface
% [ ] Refactor code: Move functions to own files.