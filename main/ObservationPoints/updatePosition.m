function op_pos = updatePosition(op_pos, op_U, cw_y, cw_z, cw_y_old, cw_z_old, delta, delta_old)

% Get wind angle 
ang = atan2(op_U(:,2),op_U(:,1));

% Now also add the deflection offset
diff_cw_y = cw_y + delta - cw_y_old - delta_old;

% Apply y-crosswind step relative to the wind angle
op_pos(:,1) = op_pos(:,1) - sin(ang).*diff_cw_y;
op_pos(:,2) = op_pos(:,2) + cos(ang).*diff_cw_y;

if mod(size(op_pos,2),2)
    diff_cw_z = cw_z - cw_z_old;
    % OPs which would move into the ground are now kept above ground.
    aboveGround = cw_z>0;
    op_pos(aboveGround,3) = op_pos(aboveGround,3) + diff_cw_z(aboveGround);
end