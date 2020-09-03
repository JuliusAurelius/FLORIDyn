function [nw, cw_y, cw_z, core, phi_cw]=getCWPosition(op_dw, w, cl_dstr, op_c, sig_y, sig_z, pc_y, pc_z, x_0)

% Sigma of Gauss functions + Potential core
%   both values are already adapted to near/far field
width_y = w*sig_y + pc_y;
width_z = w*sig_z + pc_z;

%% Get the distribution of the OPs
cw_y = width_y.*cl_dstr(op_c,1);
threeDim = size(cl_dstr,2)-1;

if threeDim
    cw_z= width_z.*cl_dstr(op_c,2);
else
    cw_z = zeros(size(cw_y));
end

% create an radius value of the core and cw values and figure out if the
% OPs are in the core or not
phi_cw  = atan2(cw_z,cw_y);
r_cw    = sqrt(cw_y.^2+cw_z.^2);
core    = or(...
    r_cw < abs(cos(phi_cw)).*pc_y*0.5 + abs(sin(phi_cw)).*pc_z*0.5,...
    op_dw==0);

nw = op_dw<x_0;

end