%% Controller script
% Modifies T to set C_p and C_t which is then used to calculate the power
% and the wake. If a switch to the axial induction factor is desired, it
% should be implemented here.

% Read yaw of SOWFA Sim
yawT1 = interp1(yawSOWFA(1:nT:end,2),yawSOWFA(1:nT:end,3),Sim.TimeSteps(i));
yawT2 = interp1(yawSOWFA(2:nT:end,2),yawSOWFA(2:nT:end,3),Sim.TimeSteps(i));
if nT==3
    yawT3 = interp1(...
        yawSOWFA(3:nT:end,2),yawSOWFA(3:nT:end,3),Sim.TimeSteps(i));
end

% Calculate Ct and Cp based on the wind speed
%    Ct is restricted at 1, otherwise complex numbers appear in the FLORIS
%    equations
T.Cp    = interp1(VCpCt(:,1),VCpCt(:,2),T.u);
T.Ct    = min(interp1(VCpCt(:,1),VCpCt(:,3),T.u),0.98);

bp1 = max(interp1(bladePitch(1:nT:end,2),bladePitch(1:nT:end,3),Sim.TimeSteps(i)),0);
bp2 = max(interp1(bladePitch(2:nT:end,2),bladePitch(2:nT:end,3),Sim.TimeSteps(i)),0);
bp3 = max(interp1(bladePitch(3:nT:end,2),bladePitch(3:nT:end,3),Sim.TimeSteps(i)),0);

tsr1 = interp1(tipSpeed(1:nT:end,2),tipSpeed(1:nT:end,3),Sim.TimeSteps(i))/T.u(1);
tsr2 = interp1(tipSpeed(1:nT:end,2),tipSpeed(1:nT:end,3),Sim.TimeSteps(i))/T.u(1);
tsr3 = interp1(tipSpeed(1:nT:end,2),tipSpeed(1:nT:end,3),Sim.TimeSteps(i))/T.u(1);

Cp1 = cpInterp(bp1,tsr1);
Cp2 = cpInterp(bp2,tsr2);
Cp3 = cpInterp(bp3,tsr3);

Ct1 = ctInterp(bp1,tsr1);
Ct2 = ctInterp(bp2,tsr2);
Ct3 = ctInterp(bp3,tsr3);

T.Cp = [Cp1;Cp2;Cp3];
T.Ct = [Ct1;Ct2;Ct3];

if nT==3
    yaw = [yawT1;yawT2;yawT3];
else
    yaw = [yawT1;yawT2];
end

yaw = (270*ones(size(yaw))-yaw)/180*pi;

% Calculate Ct and Cp based on the axial induction factor
% a = interp1(VCpCt(:,1),VCpCt(:,4),T.u);
% T.Cp    = 4*a.*(1-a).^2;
% T.Ct    = 4*a.*(1-a.*cos(yaw));

% Set Yaw relative to the wind angle and add offset
T.yaw   = atan2(T.U(:,2),T.U(:,1));
T.yaw   = T.yaw + yaw;

%% Calculate Power Output
% 1/2*airdensity*AreaRotor*C_P*U_eff^3*cos(yaw)^p_p
% T.P = 0.5*UF.airDen*(T.D/2).^2.*pi.*T.Cp.*T.u.^3.* Pow.eta.*...
%     cos(T.yaw-atan2(T.U(:,2),T.U(:,1))).^Pow.p_p;

PT1_T = 4; %s
P_new = 0.5*UF.airDen*(T.D/2).^2.*pi.*T.Cp.*T.u.^3.* Pow.eta.*...
     cos(T.yaw-atan2(T.U(:,2),T.U(:,1))).^Pow.p_p;

T.P = T.P + Sim.TimeStep/PT1_T*(P_new-T.P);
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