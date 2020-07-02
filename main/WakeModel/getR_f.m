function r = getR_f(opList, turbineList)
% getR_f calculates the reduction influence of other OPs/wakes and
% multiplies it to the natural wake reduction
%
% INPUT
% opList        := [n x 4] vector [x,y,z,r] in World coordinates
% turbineList   := [n x 3] vector position of turbines (World)
% OUTPUT
% r             := [n x 1] vector reduction factor
%

% ==================== !!!!DUMMY METHOD!!!! ====================== % 
% ================= should link to wake models =================== %

r = ones(size(opList,1),1);
end

% OP List
% [world     wake             world  world       ]
% [x,y,z, x_w,y_w,z_w, r, a,yaw, t_ind]
% [1,2,3,   4,5,6,     7,  8,9,    10 ]

% Turbine list
% [world]
% [x,y,z]
% [1,2,3]