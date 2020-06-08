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
    % Update wind dir and speed
    U_OPs = getWindVec(opList(:,1:2));
    U_t   = getWindVec(turbines(:,1:2));
    
    % Get effective yaw for each turbine
    yaw_t = getEffectiveYaw(turbines(:,6), U_t);
    
    % Get 
    % Shift opList with new positions
    
    
    % Insert new points
    
    
end




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
% [x,y,z, ux,uy,uz, r,r_t, a,yaw, t_id] // World coordinates
%% Constants
NumOfVariables  = 11;
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