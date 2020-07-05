function [op_pos, op_dw, op_r, op_ayaw, cl_dstr] = initAtRotorplane(op_pos, op_ayaw, op_r, op_t_id, chainList, cl_dstr, tl_pos, tl_D, tl_ayaw,method)
%INITATROTORPLANE creates points at the rotor plane, based on a pattern
%method
%   At the pointer entry, insert the new OPs at the rotor plane of the
%   turbines

%% OP List
% OP List
% [world     wake             world  world       ]
% [x,y,z, x_w,y_w,z_w, r,r_t, Ux,Uy, a,yaw, t_ind]
% [1,2,3,   4,5,6,      7,8,   9,10, 11,12,   13 ]
% [op_pos, op_dw, op_r, op_U, op_ayaw, op_t_id];
% reads:  op_pos, op_dw, , op_ayaw, op_r, op_t_id
% writes: op_pos, op_dw, op_r, op_ayaw

%% turbineList
% Turbine list
% [world        world   world  ]
% [x,y,z,   D,  a,yaw,  Ux,Uy P]
% [1,2,3,   4,   5,6     7,8  9]

% [tl_pos,tl_D,tl_ayaw,tl_U]
% reads : tl_pos, tl_D, tl_ayaw, 

%% chainList

% Chain List
% [                         ]
% [offset start length t_ind] cl_dstr (distibution)
% [   1     2     3      4  ]
%%
% Get the number of chains, assumed to be constant
numChains = sum(chainList(:,4)==1);
numTurbines   = size(tl_pos,1);

% Get indeces of the starting observation points
ind = chainList(:,1) + chainList(:,2);

% Assign a and yaw values of the turbines, together with coordinates
%                   opList(ind,[1:3 11:12]) = turbineList(opList(ind,13),[1:3 5:6]);
op_pos(ind,:)   = tl_pos(op_t_id);
op_ayaw(ind,:)  = tl_ayaw;

% Set r_t to 1 (no influence) will be overwritten at the end of the
% simulation step.
%                   opList(ind,8) = 1;
op_r(ind,2) = 1;

% Set x_w to 0 (at the rotor plane)
%                   opList(ind,4) = 0;
op_dw(ind) = 0;

% Entries not changed here: r,Ux,Uy,a,yaw & t_id. All these will be
% overwritten or are constant (t_id).

switch method
    case 'sunflower'
        % Distribute the n chains with r = sqrt(n) approach. The angle
        % between two chains still has to be determined.
        % In chain list, the relative coordinates have to be set 
        % [-.5,0.5] 
        
        % Links to the subject:
        % https://demonstrations.wolfram.com/SunflowerSeedArrangements/
        % https://stackoverflow.com/questions/28567166/uniformly-distribute-x-points-inside-a-circle#28572551
        
        % Set constant c
        c = 1;
        
        % get radii and phis
        radii = zeros(numChains,1); %for one turbine
        phis  = zeros(numChains,1);
        
        % scale radii to size max(r) = 0.5
        % TODO
        
        % convert radii and phi to cl_dstr entries [-.5,0.5] (2D/3D !)
        % TODO
        
        %===================== OLD CODE BELOW ============================%
        
        % Distribute the chains: one center, slightly less than half on
        % half the rotor, rest on the outer rim of the rotor.
        cDist = [1, floor((numChains-1)/2),0];
        cDist(3) = numChains - sum(cDist);
        
        % equations to place points on a circle
        op_y_w =@(r,phi) r.*sin(phi);
        op_z_w =@(r,phi) r.*cos(phi);
        R = @(phi) [cos(phi),-sin(phi),0;sin(phi),cos(phi),0;0,0,1];
        
        % ratio to get radius from diameter for chain groups
        d_factor = [0; ones(cDist(2),1)*0.25;ones(cDist(3),1)*0.5];
        radius = repmat(d_factor,numTurbines,1);
        D = reshape(repmat(turbineList(:,4)',numChains,1),...
            numTurbines*numChains,1);
        
        % Get the angles for each chain at one turbine
        phi = [0, 2*pi/cDist(2):2*pi/cDist(2):2*pi, ...
            2*pi/cDist(3):2*pi/cDist(3):2*pi]';
        
        phi_all = repmat(phi,numTurbines,1);
        
        % Distribute points in the wake coordinate system
        opList(ind,5) = op_y_w(radius.*D, phi_all);
        opList(ind,6) = op_z_w(radius.*D, phi_all);
        
        
        
        % Yaw angle to map points to world
        yaw_t = reshape(repmat(turbineList(:,6)',numChains,1),...
            numTurbines*numChains,1);
        
        for i = 1:length(yaw_t) % MAKE NICER! HAS TOB BE POSSIBLE TO SOLVE WITHOUT FOR
            opList(ind(i),1:3) = opList(ind(i),1:3) + (R(yaw_t(i))*(opList(ind(i),4:6)'))';
        end
        %======================= OLD CODE END ============================%
    otherwise
        print('Invalid option, using circle')
        opList = initAtRotorplane(opList,chainList,'sunflower');
end







end

