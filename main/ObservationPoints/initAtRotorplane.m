function [op_pos, op_dw, op_r, op_ayaw, cl_dstr] = initAtRotorPlane(op_pos, op_dw, op_ayaw, op_r, op_t_id, chainList, cl_dstr, tl_pos, tl_D, tl_ayaw, tl_U, method)
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

Dim = 3;    %<- Switch between dimentions

% Get the number of chains, assumed to be constant
numChains = sum(chainList(:,4)==1);
numTurbines   = size(tl_pos,1);

% Get indeces of the starting observation points
ind = chainList(:,1) + chainList(:,2);

% Assign a and yaw values of the turbines, together with coordinates
%                   opList(ind,[1:3 11:12]) = turbineList(opList(ind,13),[1:3 5:6]);
op_pos(ind,:)   = tl_pos(op_t_id(ind),:);
op_ayaw(ind,:)  = tl_ayaw(op_t_id(ind),:);

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
        if Dim == 3
            % 3 Dimentional field: 2D rotor plane
            [y,z] = sunflower(numChains, 2);
            
            cl_dstr(:,1) = repmat(y,numTurbines,1).*0.5;
            cl_dstr(:,2) = repmat(z,numTurbines,1).*0.5;
        else
            % 2 Dimentional field: 1D rotor plane
            y = linspace(-0.5,5,numChains)';
            cl_dstr(:) = repmat(y,numTurbines,1).*0.5;
        end
        
        % Spread points across the rotor plane at wind angle, NOT yaw angle
        % -> plane is always perpenducular to the wind dir, yaw is only
        % used for the model
        
        ang_U = atan2(tl_U(:,2),tl_U(:,1));
        % x_w = D*(-sin(phi))*distribution_cw_y + t_x_w
        op_pos(ind,1) = -tl_D(op_t_id(ind)).*sin(ang_U(op_t_id(ind))).*cl_dstr(:,1) +...
            tl_pos(op_t_id(ind),1);
        % y_w = D*(cos(phi))*distribution_cw_y + t_x_w
        op_pos(ind,2) = tl_D(op_t_id(ind)).*cos(ang_U(op_t_id(ind))).*cl_dstr(:,1) +...
            tl_pos(op_t_id(ind),2);
        
        if Dim == 3
            % z_w = D*distribution_cw_z + t_z
            op_pos(ind,3) = tl_D(op_t_id(ind)).*cl_dstr(:,2) +...
            tl_pos(op_t_id(ind),3);
        end
        
    otherwise
        print('Invalid option, using sunflower')
        [op_pos, op_dw, op_r, op_ayaw, cl_dstr] = ...
            initAtRotorPlane(...
            op_pos, op_ayaw, op_r, op_t_id, chainList, ...
            cl_dstr, tl_pos, tl_D, tl_ayaw, tl_U, 'sunflower');
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