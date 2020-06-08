function initChains()
%% Test Variables
NumChains   = 6;
TurbinePosD  = [magic(3),ones(3,1)];
chainLength = randi(5,NumChains*size(TurbinePosD,1),1)+1;
%chainLength = 5;
timeStep = 5;   % in s
%% Create starting OPs and build opList
startOPs =  getChainStart(NumChains, TurbinePosD);
[opList, startInd_T] = assembleOPList(startOPs,chainLength);
clear startOPs

%% Start simulation



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
OPs(:,1:3) = ones(NumChains*size(TurbinePosD,1),3);
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
% To change last entry to diameter uncomment the following line
% opList(startInd_T(:,1),[1:3 end]) = startOPs(:,[1:3 5]);

end