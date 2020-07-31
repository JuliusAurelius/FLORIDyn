function [op_pos, op_dw, op_r, op_U, op_ayaw, op_t_id, chainList, cl_dstr] = assembleOPList(NumChains,chainLength,tl_D,tl_pos,distr_method,Dim)
% assembleOPList creates a list of OPs with entries for the starting points 
% and the rest being 0
% 
% INPUT
% Chain Data
%   NumChains   := int; Number of chains per turbine
%   chainLength := int; Unfiform length for all chains
%   chainLength := [n x 1] vec; Individual length of each chain of each T
%
% Turbine Data
%   tl_pos      := [m x 3] vec; [x,y,z] world coord. (can be mx2)
%   tl_D        := [m x 1] vec; Turbine diameter
%
% distr_method  := String; Name of the strategy to distribute points across
%                   the wake cross section
%
% OUTPUT
% OP Data
%   op_pos      := [n x 3] vec; [x,y,z] world coord. (can be nx2)
%   op_dw       := [n x 1] vec; downwind position
%   op_r        := [n x 2] vec; [r_own, r_turbine]
%   op_ayaw     := [n x 2] vec; axial induction factor and yaw (wake coord.)
%   op_t_id     := [n x 1] vec; Turbine op belongs to
%   op_U        := [n x 2] vec; Uninfluenced wind vector at OP position
%
% Chain Data
%   chainList   := [n x 1] vec; (see at the end of the function)
%   cl_dstr     := [n x 1] vec; Distribution relative to the wake width
%



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
op_ayaw(:,1) = 0.33;        %Otherwise the first points are init. wrong
op_t_id = assignTIDs(chainList,len_OPs);

op_pos(:,1:2) = tl_pos(op_t_id,1:2);

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
            y = linspace(-0.5,.5,NumChains)';
            cl_dstr(:) = repmat(y,NumTurb,1);
        end
end

end

function t_id = assignTIDs(chainList,len_OPs)
% ASSIGNTIDS writes t_id entries of opList
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

% chainList
% [ off, start_id, length, t_id]