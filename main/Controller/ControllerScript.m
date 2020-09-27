%% Controller script
% Modifies T to set C_p and C_t which is then used to calculate the power
% and the wake

% Calculate Ct and Cp based on the wind speed
T.Cp    = interp1(VCtCp(:,1),VCtCp(:,3),T.u);
T.Ct    = interp1(VCtCp(:,1),VCtCp(:,2),T.u);

% Yaw staying relative to the wind angle
T.yaw   = atan2(T.U(:,2),T.U(:,1));