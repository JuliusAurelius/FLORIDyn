%% Controller script
% Modifies T to set C_p and C_t which is then used to calculate the power
% and the wake. If a switch to the axial induction factor is desired, it
% should be implemented here.

yaw = zeros(size(T.yaw));
switch controllerType
    case 'SOWFA_greedy_yaw'
        % Read yaw of SOWFA Sim (deg)
        for iT = 1:nT
            yaw(iT) = interp1(...
                yawSOWFA(iT:nT:end,2),yawSOWFA(iT:nT:end,3),Sim.TimeSteps(i));
        end
        
        % Yaw conversion SOWFA to FLORIDyn
        yaw = (270*ones(size(yaw))-yaw)/180*pi;
        
        % Calculate Ct and Cp based on the wind speed
        %    Ct is restricted at 1, otherwise complex numbers appear in the FLORIS
        %    equations
        T.Cp    = interp1(VCpCt(:,1),VCpCt(:,2),T.u);
        T.Ct    = min(interp1(VCpCt(:,1),VCpCt(:,3),T.u),0.89);
    case 'SOWFA_bpa_tsr_yaw'
        % Read yaw of SOWFA Sim (deg)
        for iT = 1:nT
            yaw(iT) = interp1(...
                yawSOWFA(iT:nT:end,2),yawSOWFA(iT:nT:end,3),Sim.TimeSteps(i));
        end
        
        % Yaw conversion SOWFA to FLORIDyn
        yaw = (270*ones(size(yaw))-yaw)/180*pi;
        
        % Ct / Cp calculation based on the blade pitch and tip speed ratio
        for iT = 1:nT
            bpa = max(interp1(bladePitch(iT:nT:end,2),bladePitch(iT:nT:end,3),Sim.TimeSteps(i)),0);
            tsr = interp1(tipSpeed(iT:nT:end,2),tipSpeed(iT:nT:end,3),Sim.TimeSteps(i))/T.u(1);
            T.Cp(iT) = cpInterp(bpa,tsr);
            T.Ct(iT) = ctInterp(bpa,tsr);
        end
    case 'FLORIDyn_greedy'
        % Calculate Ct and Cp based on the wind speed
        %    Ct is restricted at 1, otherwise complex numbers appear in the FLORIS
        %    equations
        T.Cp    = interp1(VCpCt(:,1),VCpCt(:,2),T.u);
        T.Ct    = min(interp1(VCpCt(:,1),VCpCt(:,3),T.u),0.89);
        
        % Normal yaw (yaw is defined clockwise)
        yaw = (-yaw)/180*pi;
end

% Set Yaw relative to the wind angle and add offset
T.yaw   = atan2(T.U(:,2),T.U(:,1));
T.yaw   = T.yaw + yaw;

T.Ct = min(T.Ct,ones(size(T.Ct))*0.89);
%% Calculate Power Output
% 1/2*airdensity*AreaRotor*C_P*U_eff^3*cos(yaw)^p_p
T.P = 0.5*UF.airDen*(T.D/2).^2.*pi.*T.Cp.*T.u.^3.* Pow.eta.*...
    cos(T.yaw-atan2(T.U(:,2),T.U(:,1))).^Pow.p_p;

powerHist(:,i)= T.P;

%% ===================================================================== %%
% = Reviewed: 2020.11.03 (yyyy.mm.dd)                                   = %
% === Author: Marcus Becker                                             = %
% == Contact: marcus.becker.mail@gmail.com                              = %
% ======================================================================= %