function r = getR(opList, turbineList)
% GETR calculates the reduction factor of the wind velocity to get the
% effective windspeed based on the eq. u = U*r
%
% INPUT
% opList        := [n x 9] description below
% turbineList   := [n x 3] description below
% OUTPUT
% r             := [n x 1] vector reduction factor
%

% OP List
% [world     wake      world       ]
% [x,y,z, x_w,y_w,z_w, a,yaw, t_ind]
% [1,2,3,   4,5,6,      7,8,    9  ]

% turbine list
% [world world world]
% [z, D,  yaw, Ux,Uy]
% [1, 2,   3,   4,5 ]

% Get effective yaw for each turbine
yawEff = getEffectiveYaw(turbineList(:,3), turbineList(:,4:5));


% ==================== !!!!DUMMY METHOD!!!! ====================== % 
% ================= should link to wake models =================== %

r = ones(size(opList,1),1); % (1 = no influence)
end