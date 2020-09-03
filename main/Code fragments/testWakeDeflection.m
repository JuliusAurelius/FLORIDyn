op_dw   = linspace(0,1000,1000)';
a       = ones(size(op_dw))*0.33;
yaw     = ones(size(op_dw))*30/180*pi;
op_I    = ones(size(op_dw))*0.06;
op_D    = ones(size(op_dw))*160;


%%

C_T = 4*a.*(1-a.*cos(yaw));

%% Calc x_0 (Core length)
alpha = 2.32;
beta = 0.154;
% [1] Eq. 7.3
x_0 = (cos(yaw).*(1+sqrt(1-C_T))./...
    (sqrt(2)*(alpha*op_I+beta*(1-sqrt(1-C_T))))).*op_D;

%% Calc k_z and k_y based on I
k_a = 0.38371;
k_b = 0.003678;

%[2] Eq.8
k_y = k_a*op_I + k_b;
k_z = k_y;

%% Get field width y
% [1] Eq. 7.2
% To fit the field width, the value linearly increases from 0 to max for dw
% positions before x_0
zs = zeros(size(op_dw));
sig_y = ...
    max([op_dw-x_0,zs],[],2)   .* k_y +...
    min([op_dw./x_0,zs+1],[],2).* cos(yaw) .* op_D/sqrt(8);

%% Get field width z
% [1] Eq. 7.2
sig_z = ...
    max([op_dw-x_0,zs],[],2)    .* k_z +...
    min([op_dw./x_0,zs+1],[],2) .* op_D/sqrt(8);

%% Calc Theta
%[1] Eq. 6.12
Theta = 0.3*yaw./cos(yaw).*(1-sqrt(1-C_T.*cos(yaw)));

%% deflection
delta_nw = Theta.*op_dw;

delta_fw1 = Theta.*x_0./op_D;
delta_fw2_1 = Theta/14.7.*sqrt(cos(yaw)./(k_y.*k_z.*C_T)).*(2.9+1.3*sqrt(1-C_T)-C_T);
delta_fw2_2 = log(...
    (1.6+sqrt(C_T)).*...
    (1.6.*sqrt((8*sig_y.*sig_z)./(op_D.^2.*cos(yaw)))-sqrt(C_T))./(...
    (1.6-sqrt(C_T)).*...
    (1.6.*sqrt((8*sig_y.*sig_z)./(op_D.^2.*cos(yaw)))+sqrt(C_T))...
    ));

delta_fw = (delta_fw1 + delta_fw2_1.*delta_fw2_2).*op_D;

nw = op_dw<x_0;

%% deflection combined
delta_fw1_c = Theta.*min([op_dw,x_0],[],2);
delta_c = delta_fw1_c + (sign(op_dw-x_0)/2+0.5).*delta_fw2_1.*delta_fw2_2.*op_D;
%%
figure(3)
plot(op_dw(nw),delta_nw(nw))
hold on
plot(op_dw(~nw),real(delta_fw(~nw)))
plot(op_dw,delta_c,'--')
hold off
grid on
axis equal