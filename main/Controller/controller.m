function a_yaw = controller(turbines)
% ==================== !!!!DUMMY METHOD!!!! ====================== % 
    % CONTROLLER sets a and yaw (in world coordinates!) for each turbine.
    yaw = atan2(turbines(:,8),turbines(:,7));
    a_yaw = [ones(size(turbines,1),1)*0.3, yaw]; % TODO Placeholder
end