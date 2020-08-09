u_l = min(sqrt(sum(op_u.^2,2)));
%ff = sqrt(sum(op_u.^2,2))>(u_l*1.2)*0;
if Dim==2
    u_max = 20;
    slow = sqrt(sum(op_u.^2,2))<u_max;
    p = scatter3(op_pos(slow,1),op_pos(slow,2),sqrt(sum(op_u(slow,:).^2,2)),...
        ones(size(op_t_id(slow)))*40,sqrt(sum(op_u(slow,:).^2,2)),...
        'filled');
else
    p = scatter3(op_pos(:,1),op_pos(:,2),op_pos(:,3),...
        ones(size(op_t_id(:)))*20,sqrt(sum(op_u.^2,2)),...
        'filled');
end

pause(0.1)