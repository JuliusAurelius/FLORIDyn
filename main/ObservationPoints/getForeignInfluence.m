function r_f = getForeignInfluence(op_pos, op_r, op_t_id, tl_D)
% Go through all turbines and use their points in scattered interpolant
r_f = ones(size(op_r)); % == prod((1-r)(1-r)...)

% % 1 if three dimentions, 0 if only 2
% threeDim = mod(size(op_pos,2),2);
% 
% for t = 1:length(tl_D)
%     % extract points which belong to the turbine and which are potentially
%     % influenced
%     t_points = op_t_id == t;
%     
%     % DOES NOT WORK PROPERLY WITH 3D WAKES 
%     %   (interpolation based on 2D plane)
%     if threeDim == 1
%         F = scatteredInterpolant(...
%             op_pos(t_points,1),...
%             op_pos(t_points,2),...
%             op_pos(t_points,3),...
%             op_r(t_points),'nearest','none');
%     
%         r_f_tmp = F(op_pos(~t_points,1:3));
%     else
%         F = scatteredInterpolant(...
%             op_pos(t_points,1),...
%             op_pos(t_points,2),...
%             op_r(t_points),'nearest','none');
%     
%         r_f_tmp = F(op_pos(~t_points,1:2));
%     end
%     
%     if isempty(r_f_tmp)
%         break;
%     end
%     r_f_tmp(isnan(r_f_tmp)) = 0;
%     r_f(~t_points) = r_f(~t_points).*(1-r_f_tmp);
% end
end