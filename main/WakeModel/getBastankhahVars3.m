function [sig_y, sig_z, C_T, x_0, delta, pc_y, pc_z] = getBastankhahVars3(OP, D)
% getCW returns the crosswind position of an OP based on the dw position
%
%INPUT
% OP Data
%   OP.dw       := [n x 1] vec; downwind position
%   OP.ayaw     := [n x 2] vec; axial induction factor and yaw (wake coord.)
%   OP.t_id     := [n x 1] vec; Turbine op belongs to
%   OP.I        := [n x 1] vec; Ambient turbulence intensity
%
% Turbine Data
%   tl_D        := [n x 1] vec; Turbine diameter
%
% SOURCES
% [1] Experimental and theoretical study of wind turbine wakes in yawed
%     conditions - M. Bastankhah and F. Porté-Agel
% [2] Design and analysis of a spatially heterogeneous wake - A. Farrell,
%     J. King et al.

%% Calc C_T
%a = OP.ayaw(:,1);
yaw = OP.yaw;

% Could be replaced by look-up-table
% [1] Eq.6.1 
%C_T = 4*a.*sqrt(1-a.*(2*cos(yaw)-a));
% [1] Eq.6.2
%C_T = 4*a.*(1-a.*cos(yaw));
C_T = OP.Ct;
%% Calc x_0 (Core length)
alpha = 2.32;
beta = 0.154;
% [1] Eq. 7.3
x_0 = (cos(yaw).*(1+sqrt(1-C_T))./...
    (sqrt(2)*(alpha*OP.I+beta*(1-sqrt(1-C_T))))).*D;

%% Calc k_z and k_y based on I
k_a = 0.38371;
k_b = 0.003678;

%[2] Eq.8
k_y = k_a*OP.I + k_b;
k_z = k_y;

%% Get field width y
% [1] Eq. 7.2
% To fit the field width, the value linearly increases from 0 to max for dw
% positions before x_0
zs = zeros(size(OP.dw));
sig_y = ...
    max([OP.dw-x_0,zs],[],2)   .* k_y +...
    min([OP.dw./x_0,zs+1],[],2).* cos(yaw) .* D/sqrt(8);

%% Get field width z
% [1] Eq. 7.2
sig_z = ...
    max([OP.dw-x_0,zs],[],2)    .* k_z +...
    min([OP.dw./x_0,zs+1],[],2) .* D/sqrt(8);

%% Calc Theta
%[1] Eq. 6.12
Theta = 0.3*yaw./cos(yaw).*(1-sqrt(1-C_T.*cos(yaw)));

%% Calc Delta / Deflection
%[1] Eq. 7.4 (multiplied with D and the second part disabled for dw<x_0)
%   Part 1 covering the linear near field and constant for the far field
delta_nfw  = Theta.*min([OP.dw,x_0],[],2);

%   Part 2, smooth angle for the far field, disabled for the near field.
delta_fw_1 = Theta/14.7.*sqrt(cos(yaw)./(k_y.*k_z.*C_T)).*(2.9+1.3*sqrt(1-C_T)-C_T);
delta_fw_2 = log(...
    (1.6+sqrt(C_T)).*...
    (1.6.*sqrt((8*sig_y.*sig_z)./(D.^2.*cos(yaw)))-sqrt(C_T))./(...
    (1.6-sqrt(C_T)).*...
    (1.6.*sqrt((8*sig_y.*sig_z)./(D.^2.*cos(yaw)))+sqrt(C_T))...
    ));

% Combine deflection parts
delta = delta_nfw + ...
    (sign(OP.dw-x_0)/2+0.5).*...
    delta_fw_1.*delta_fw_2.*D;

%% Potential core
% Potential core at rotor plane
%   Ratio u_r/u_0 [1] Eq.6.4 & 6.7
u_r_0 = (C_T.*cos(yaw))./(...
    2*(1-sqrt(1-C_T.*cos(yaw))).*sqrt(1-C_T));

%   Ellypitcal boundaries [1] P.530, L.7f
pc_y = D.*cos(yaw).*sqrt(u_r_0).*max([1-OP.dw./x_0,zs],[],2);
pc_z = D.*sqrt(u_r_0).*max([1-OP.dw./x_0,zs],[],2);
end