function tl_ayaw = controller(tl_pos,tl_D,tl_ayaw,tl_U)
% ==================== !!!!DUMMY METHOD!!!! ====================== % 
    % CONTROLLER sets a and yaw (in world coordinates!) for each turbine.
    yaw = atan2(tl_U(:,2),tl_U(:,1));
    tl_ayaw = [ones(size(tl_D))*0.3, yaw]; % TODO Placeholder
end