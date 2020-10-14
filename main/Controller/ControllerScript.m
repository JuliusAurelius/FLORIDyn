%% Controller script
% Modifies T to set C_p and C_t which is then used to calculate the power
% and the wake. If a switch to the axial induction factor is desired, it
% should be implemented here.

% Read yaw of SOWFA Sim
yawT1 = interp1(yawSOWFA(1:2:end,2),yawSOWFA(1:2:end,3),Sim.TimeSteps(i));
yawT2 = interp1(yawSOWFA(2:2:end,2),yawSOWFA(2:2:end,3),Sim.TimeSteps(i));

% Calculate Ct and Cp based on the wind speed
%    Ct is restricted at 1, otherwise complex numbers appear in the FLORIS
%    equations
T.Cp    = interp1(VCpCt(:,1),VCpCt(:,2),T.u);
T.Ct    = min(interp1(VCpCt(:,1),VCpCt(:,3),T.u),0.98);

yaw = [yawT1;yawT2];
yaw = (270*ones(size(yaw))-yaw)/180*pi;

% Calculate Ct and Cp based on the axial induction factor
% a = 1/3;
% T.Cp    = ones(size(T.Cp)).*4*a.*(1-a)^2;
% T.Ct    = ones(size(T.Cp)).*4*a.*(1-a.*cos(yaw));

% Set Yaw relative to the wind angle and add offset
T.yaw   = atan2(T.U(:,2),T.U(:,1));
T.yaw   = T.yaw + yaw;

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