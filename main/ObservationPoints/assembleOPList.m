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
% OP List
% [world     wake             world  world       ]
% [x,y,z, x_w,y_w,z_w, r,r_t, Ux,Uy, a,yaw, t_ind]
% [1,2,3,   4,5,6,      7,8,   9,10, 11,12,   13 ]
%
% ==== Constants ==== %
NumOfVariables  = 13;
numChains       = size(startOPs,1);
chainList       = zeros(numChains,4);
chainList(:,4)  = startOPs(:,4);

% ==== Build Chains ==== %
if length(chainLength)==numChains
    % diverse length, for every chain there is a length.
    
    % Get starting indeces
    chainList(:,2) = cumsum(chainLength')'-chainLength+1;
    
    % Allocate opList
    opList = zeros(sum(chainLength), NumOfVariables);
    
else
    % Uniform length
    chainList(:,2) = cumsum(ones(1,numChains)*chainLength)'-chainLength+1;
    
    % Allocate opList
    opList = zeros(chainList(end,1), NumOfVariables);
end

chainList(:,3) = chainLength;


opList = assignTIDs(chainList,opList);




% Insert the starting OPs in the opList
opList(chainList(:,2),[1:3 end]) = startOPs(:,1:4);
% ==== To change last entry to diameter uncomment the following line ==== %
% opList(startInd_T(:,1),[1:3 end]) = startOPs(:,[1:3 5]);

end

% OP List
% [world     wake             world  world       ]
% [x,y,z, x_w,y_w,z_w, r,r_t, Ux,Uy, a,yaw, t_ind]
% [1,2,3,   4,5,6,      7,8,   9,10, 11,12,   13 ]

% Chain List
% [                         ]
% [offset start length t_ind]
% [   1     2     3      4  ]

function opList = assignTIDs(chainList,opList)
% ASSIGNTIDS writes t_id entries of opList
%   IMPROVEMENT: Returns vector with the t_ids fitting assembeled
ind_op = 1;
ind_ch = 1;
while ind_op<=size(opList,1)
    if(ind_op == sum(chainList(ind_ch,[2 3])))
        ind_ch = ind_ch + 1;
    end
    
    opList(ind_op,13) = chainList(ind_ch,4);
    
    ind_op = ind_op+1;
end
end