function [op_pos, op_dw, op_r, op_U, op_ayaw, op_t_id, chainList, cl_dstr] = assembleOPList(NumChains,chainLength,tl_D,distr_method)
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

Dim = 3;             %<--- 2D / 3D change

% ==== Constants ==== %
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
op_pos  = zeros(len_OPs,Dim);
op_dw   = zeros(len_OPs,1);
op_r    = zeros(len_OPs,2);
op_U    = zeros(len_OPs,2);
op_ayaw = zeros(len_OPs,2);
op_t_id = assignTIDs(chainList,len_OPs);

cl_dstr = zeros(NumChainsTot,Dim-1);
switch distr_method
    case 'sunflower'
        % Distribute the n chains with r = sqrt(n) approach. The angle
        % between two chains still has to be determined.
        % In chain list, the relative coordinates have to be set 
        % [-.5,0.5] 
        if Dim == 3
            % 3 Dimentional field: 2D rotor plane
            [y,z] = sunflower(NumChains, 2);
            
            cl_dstr(:,1) = repmat(y,NumTurb,1).*0.5;
            cl_dstr(:,2) = repmat(z,NumTurb,1).*0.5;
        else
            % 2 Dimentional field: 1D rotor plane
            y = linspace(-0.5,5,NumChains)';
            cl_dstr(:) = repmat(y,NumTurb,1).*0.5;
        end
end

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

function [y,z] = sunflower(n, alpha)   %  example: n=500, alpha=2
% SUNFLOWER distributes n points in a sunflower pattern 
%   Uses altered code from stack overflow:
% https://stackoverflow.com/questions/28567166/uniformly-distribute-x-points-inside-a-circle#28572551
%
% INPUT
% n     := Int, Number of points to be placed
% alpha := Int, weight of points on the rim (musn't be above sqrt(n)!)
%           -> Check?!

    b   = round(alpha*sqrt(n));      % number of boundary points
    gr  = (sqrt(5)+1)/2;             % golden ratio
    k   = 1:n;
    r   = ones(1,n);
    
    r(1:n-b) = sqrt(k(1:n-b)-1/2)/sqrt(n-(b+1)/2);
    theta = 2*pi*k/gr^2;
    
    y = (r.*cos(theta))';
    z = (r.*sin(theta))';
end