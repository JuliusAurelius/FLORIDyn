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