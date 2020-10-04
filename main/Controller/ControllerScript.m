%% Controller script
% Modifies T to set C_p and C_t which is then used to calculate the power
% and the wake. If a switch to the axial induction factor is desired, it
% should be implemented here.

% Calculate Ct and Cp based on the wind speed
T.Cp    = interp1(VCtCp(:,1),VCtCp(:,3),T.u);
T.Ct    = interp1(VCtCp(:,1),VCtCp(:,2),T.u);

% Yaw staying relative to the wind angle
T.yaw   = atan2(T.U(:,2),T.U(:,1));
T.yaw(1) = T.yaw(1) +(tanh((Sim.TimeSteps(i)-300)/50)+1)*15/180*pi;

%% Calculate Power Output
% 1/2*airdensity*AreaRotor*C_P*U_eff^3*cos(yaw)^p_p
T.P = 0.5*UF.airDen*(T.D/2).^2.*pi.*T.Cp.*T.u.^3.* Pow.eta.*...
    cos(T.yaw-atan2(T.U(:,2),T.U(:,1))).^Pow.p_p;

powerHist(:,i)= T.P;

%% ===================================================================== %%
% = Reviewed: 2020.09.28 (yyyy.mm.dd)                                   = %
% === Author: Marcus Becker                                             = %
% == Contact: marcus.becker.mail@gmail.com                              = %
% ======================================================================= %

%% Other Ct equations based on the axial induction factor
% [1] Eq.6.1 
%C_T = 4*a.*sqrt(1-a.*(2*cos(yaw)-a));
% [1] Eq.6.2
%C_T = 4*a.*(1-a.*cos(yaw));
% SOURCES
% [1] Experimental and theoretical study of wind turbine wakes in yawed
%     conditions - M. Bastankhah and F. Porté-Agel