function [OP, chain] = assembleOPList(chain,T,distr_method)
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


% chain.NumChains,chain.Length

% ==== Constants ==== %
Dim             = 3; % Since the model is defined in 3D
NumTurb         = length(T.D);
NumChainsTot    = chain.NumChains*NumTurb; % Total number of chains across all t.
chainList       = zeros(NumChainsTot,5);
chainList(:,4)  = reshape(repmat(1:NumTurb,chain.NumChains,1),NumChainsTot,1);

% ==== Build Chains ==== %
if length(chain.Length)==NumChainsTot
    % diverse length, for every chain there is a length.
    
    % Get starting indeces
    chainList(:,2) = cumsum(chain.Length')'-chain.Length+1;
else
    % Starting points
    chainList(:,2) = cumsum(ones(1,NumChainsTot)*chain.Length(1))'...
        -chain.Length(1)+1;
end

% Store chain length
chainList(:,3) = chain.Length;
    
% Allocate opList
len_OPs = sum(chainList(:,3));

%(pos, dw, r, U, a,yaw t_ind)
op_pos  = zeros(len_OPs,Dim);
op_dw   = zeros(len_OPs,1);
op_r    = zeros(len_OPs,2);
op_U    = zeros(len_OPs,2);
op_yaw  = zeros(len_OPs,1);
op_Ct   = zeros(len_OPs,1);        %Otherwise the first points are init. wrong
op_t_id = assignTIDs(chainList,len_OPs);

op_pos(:,1:2) = T.pos(op_t_id,1:2);

cl_dstr = zeros(NumChainsTot,Dim-1);

% Relative area the OPs are representing
cl_relA = zeros(NumChainsTot,1);

switch distr_method
    case 'sunflower'
        % Distribute the n chains with r = sqrt(n) approach. The angle
        % between two chains still has to be determined.
        % In chain list, the relative coordinates have to be set 
        % [-.5,0.5] 
        if Dim == 3
            % 3 Dimentional field: 2D rotor plane
            [y,z,repArea] = sunflower(chain.NumChains, 2);
            
            cl_dstr(:,1) = repmat(y,NumTurb,1).*0.5;
            cl_dstr(:,2) = repmat(z,NumTurb,1).*0.5;
            cl_relA = repmat(repArea,NumTurb,1);
        else
            % 2 Dimentional field: 1D rotor plane
            y = linspace(-0.5,.5,chain.NumChains)';
            cl_dstr(:) = repmat(y,NumTurb,1);
            
            
            % Calculate the represened Area by the observation point
            % assuming a circular rotor plane with r=0.5.
            
            % A(d) calculates the area given by a circular segment with the
            % distance d to the circle center
            A =@(d) 0.25*acos(d/0.5)-d.*0.5.*sqrt(1-d.^2/0.25);
            
            % repArea contains the area from the center to the outside
            
            %d = zeros(floor(chain.NumChains/2),1);
            if mod(chain.NumChains,2)==0
                % Even
                d = 1/chain.NumChains*(0:(chain.NumChains-1)/2);
                repArea = A(d);
                repArea(1:end-1) = repArea(1:end-1)-repArea(2:end);
                
                % Combine halves and normalize
                repArea_all = [repArea(end:-1:1),repArea];
                repArea_all = repArea_all/sum(repArea_all);
                cl_relA = repmat(repArea_all',NumTurb,1);
            else
                % Uneven
                d = [0,1/(chain.NumChains-1)*(0.5:(chain.NumChains-1)/2)];
                repArea = A(d);
                repArea(1:end-1) = repArea(1:end-1)-repArea(2:end);
                
                % Center area is split in two
                repArea(1) = repArea(1)*2;
                
                % Combine halves and normalize
                repArea_all = [repArea(end:-1:2),repArea];
                repArea_all = repArea_all/sum(repArea_all);
                cl_relA = repmat(repArea_all',NumTurb,1);
            end
            
        end
end
chainList(:,5) = cl_relA;

OP.pos  = op_pos;
OP.dw   = op_dw;
OP.r    = op_r;
OP.U    = op_U;
OP.yaw  = op_yaw;
OP.Ct   = op_Ct;
OP.t_id = op_t_id;

chain.List = chainList;
chain.dstr = cl_dstr;
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
% [ off, start_id, length, t_id, relArea]