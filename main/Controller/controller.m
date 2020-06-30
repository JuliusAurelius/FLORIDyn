function a_yaw = controller(turbines)
% ==================== !!!!DUMMY METHOD!!!! ====================== % 
    % CONTROLLER sets a and yaw (in world coordinates!) for each turbine.
    a_yaw = ones(size(turbines(:,5:6)))*[0.3, 0; 0, 0]; % TODO Placeholder
end