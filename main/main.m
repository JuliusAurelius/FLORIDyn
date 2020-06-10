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

% [x,y,z,d,a,yaw] // World Coordinates
turbines = [TurbinePosD, zeros(size(TurbinePosD,1),2)];


%% Create starting OPs and build opList
startOPs =  getChainStart(NumChains, TurbinePosD);
[opList, startInd_T] = assembleOPList(startOPs,chainLength);
clear startOPs TurbinePosD 

%% Start simulation
for i = 1:NoTimeSteps
    % Shift opList and insert new points
    
    % ______ DISCUSSION ______
    % If a new point is added here, it will be processed and will move
    % further. Result is that there are no OPs at the rotor plane.
    % Alternative is to first process all exsisting OPs and then shift,
    % which means that time is wasted on points which will be thrown away.
    
    % Update wind dir and speed
    U_OPs = getWindVec(opList(:,1:2));
    U_t   = getWindVec(turbines(:,1:2));
    
    %====================== CONTROLLER ===================================%
    turbines(:,5:6) = controller(turbines);
    %=====================================================================%
    
    % Get effective yaw for each turbine
    yaw_t = getEffectiveYaw(turbines(:,6), U_t);
    
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

%% DISTRIBUTION

function xyz = distibutionStrategy(opList)
% ==================== !!!!DUMMY METHOD!!!! ====================== % 
xyz = ones(size(opList,1),3);
end

%% 

function a_yaw = controller(turbines)
% ==================== !!!!DUMMY METHOD!!!! ====================== % 
    % CONTROLLER sets a and yaw (in world coordinates!) for each turbine.
    a_yaw = ones(size(turbines(:,5:6)))*[0.3, 0; 0, 0]; % TODO Placeholder
end
%%

function U = getWindVec(pos)
% GETWINDVEC returns a free wind vector (== speed and direction) for the
% position(s) given as a [x,y] vector
%
% INPUT
% NumChains     := [n x 2] vector with postions [x,y] // World coordinates
%
% OUTPUT
% u             := [n x 2] vector with the [ux, uy] velocities

% ========================= TODO ========================= 
% ///////////////////////// LINK Wind Dir  //////////

U = ones(size(pos));                                    % TODO Placeholder
end


%%

function yaw_t = getEffectiveYaw(t_orientation, U)
% GETEFFECTIVEYAW returns the effective yaw angle between the wind
% direction and the turbine orientation.
%
% INPUT
% t_orientation := [n x 1] Angle of the turbine in world coordinates
% U             := [n x 2] Wind vector [ux,uy] at the location of the
%                           turbine in world coordinates
%
% OUTPUT
% yaw_t         := [n x 1] vector with the effective yaw angles [-pi,+pi]

% ========================= TODO ========================= 
% Vec to angle
%
% get effective angle
%
yaw_t = zeros(size(t_orientation));                     % TODO Placeholder
end

%%
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

%% Allocation
OPs = zeros(NumChains*size(TurbinePosD,1),5);

% assign each OP to a turbine (first all OPs from turbine 1, then t2 etc.)
t_ind   = repmat(1:size(TurbinePosD,1),NumChains,1);
t_d     = repmat(TurbinePosD(:,end)',NumChains,1);

OPs(:,4) = t_ind(:);
OPs(:,5) = t_d(:);


% ========================= TODO ========================= 
% ///////////////////////// Strategy to create points ////
OPs(:,1:3) = ones(NumChains*size(TurbinePosD,1),3);     % TODO Placeholder
% ////////////////////////////////////////////////////////
end

%%
function [opList, startInd_T] = assembleOPList(startOPs,chainLength)
% assembleOPList creates a list of OPs with entries for the starting points 
% and the rest being 0
% 
% INPUT
% startOPs      := [n x 3] vector [x,y,z]   // World coordinates
% chainLength   := [n x 1] vector
% chainLength   := Int
% TurbinePosD   := [n x 4] vector [x,y,z,d] // World coordinates
%
% OUTPUT
% opList        := [n x vars]
% startInd_T    := [n x 2] starting Indices for all chain lengths and which 
%                   turbine they belong to.
%
% [x,y,z, Ux,Uy, r,r_t, a,yaw, t_id] // World coordinates
%% Constants
NumOfVariables  = 10;
numChains       = size(startOPs,1);
startInd_T      = zeros(numChains,2);
startInd_T(:,2) = startOPs(:,4);

%% Build Chains
if length(chainLength)==numChains
    % diverse length, for every chain there is a length.
    
    % Get starting indeces
    startInd_T(:,1) = cumsum(chainLength')'-chainLength+1;
    
    % Allocate opList
    opList = zeros(sum(chainLength), NumOfVariables);
    
else
    % Uniform length
    startInd_T(:,1) = cumsum(ones(1,numChains)*chainLength)'-chainLength+1;
    
    % Allocate opList
    opList = zeros(startInd_T(end,1), NumOfVariables);
end

opList(startInd_T(:,1),[1:3 end]) = startOPs(:,1:4);
% ==== To change last entry to diameter uncomment the following line ==== %
% opList(startInd_T(:,1),[1:3 end]) = startOPs(:,[1:3 5]);

end