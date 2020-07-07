function [op_pos, op_dw, op_r, op_U, op_ayaw, op_t_id, chainList, cl_dstr] = assembleOPList(NumChains,chainLength,tl_D)
% assembleOPList creates a list of OPs with entries for the starting points 
% and the rest being 0
% 
% INPUT
% NumChains     := int Number of chains per turbine
% chainLength   := int or [NumChains*NumTurbines x 1] vector
% tl_D          := Int
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

Dim = 3;
% ==== Constants ==== %
NumOfVariables  = 13;
NumTurb         = length(tl_D);
NumChainsTot    = NumChains*NumTurb; % Total number of chains across all t.
chainList       = zeros(NumChainsTot,4);
chainList(:,4)  = reshape(repmat(1:NumTurb,NumChains,1),NumChainsTot,1);

% ==== Build Chains ==== %
if length(chainLength)==NumChainsTot
    % diverse length, for every chain there is a length.
    
    % Get starting indeces
    chainList(:,2) = cumsum(chainLength')'-chainLength+1;
else
    % Starting points
    chainList(:,2) = cumsum(ones(1,NumChainsTot)*chainLength(1))'...
        -chainLength(1)+1;
end

% Store chain length
    chainList(:,3) = chainLength;
    
% Allocate opList
len_OPs = sum(chainList(:,3));

%(pos, dw, r, U, a,yaw t_ind)
op_pos  = zeros(len_OPs,Dim);             %<--- 2D / 3D change
op_dw   = zeros(len_OPs,1);
op_r    = zeros(len_OPs,2);
op_U    = zeros(len_OPs,2);
op_ayaw = zeros(len_OPs,2);
op_t_id = assignTIDs(chainList,len_OPs);

cl_dstr = zeros(NumChainsTot,Dim-1);        %<--- 2D / 3D change 
% Insert the starting OPs in the opList

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

function t_id = assignTIDs(chainList,len_OPs)
% ASSIGNTIDS writes t_id entries of opList
%   IMPROVEMENT: Returns vector with the t_ids fitting assembeled
ind_op = 1;
ind_ch = 1;
t_id = zeros(len_OPs,1);
while ind_op<=len_OPs
    if(ind_op == sum(chainList(ind_ch,[2 3])))
        ind_ch = ind_ch + 1;
    end
    
    t_id(ind_op) = chainList(ind_ch,4);
    
    ind_op = ind_op+1;
end
end