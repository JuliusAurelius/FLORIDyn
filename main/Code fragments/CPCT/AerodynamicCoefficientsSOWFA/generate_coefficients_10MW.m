clear all; clc; close all;

%% Load 10MW Cp and Ct coefficients from FAST
% import data
CpCtCq = import10MwCpCtCqfile();                    % Aerodynamic coefficients
bemData.pitch = str2num(CpCtCq(5,1).Variables);     % Pitch angles
bemData.tsr   = str2num(CpCtCq(7,1).Variables)';    % Tip-speed ratio
% extract coefficients
for ii = 1:48
    bemData.cp(ii,:) = str2num(CpCtCq(12 + ii,1).Variables);
    bemData.ct(ii,:) = str2num(CpCtCq(64 + ii,1).Variables);
    bemData.cq(ii,:) = str2num(CpCtCq(116+ ii,1).Variables);
end

% Create interpolant
[X,Y] = ndgrid(bemData.pitch',bemData.tsr);
cpInterpolant = griddedInterpolant(X,Y,bemData.cp');
ctInterpolant = griddedInterpolant(X,Y,bemData.ct');

% Specify turbine data
turb.R = 178.3/2;                                   % Rotor radius [m]
turb.V = 4:0.5:25;                                      % Wind speed range [m/s]
turb.Vrat = 11.4;                                   % Rated wind speed [m/s] 
turb.Omg_cutin = 6;                                 % Cut-in rotor speed [rpm]
turb.Omg_rat = 9.6;                                 % Rated rotor speed [rpm]
turb.P_rat = 10.6e6;                                % Rated power [W]
turb.theta_opt = 0;                                 % Optimal pitch angle [deg]
idx_theta = find(bemData.pitch==turb.theta_opt);    % Pitch angle index
[~,idx_lambda] = max(bemData.cp(:,idx_theta));      % find optimal TSR 
turb.lambda_opt = bemData.tsr(idx_lambda);          % Optimal TSR [-]

% Find optimal settings for each wind speed
for i = 1:length(turb.V)
    turb.theta(i) = turb.theta_opt;                                     % Start with optimal pitch angle
    turb.lambda(i) = turb.lambda_opt;                                   % Start with optimal TSR        
    turb.Omg(i) = turb.lambda_opt*turb.V(i)/turb.R*30/pi;               % Compute rotor speed
    turb.cp(i) = cpInterpolant(turb.theta(i),turb.lambda(i));           % Find power coefficient
    turb.Paero(i) = 0.5*1.225*pi*turb.R^2*turb.cp(i)*turb.V(i)^3;       % Compute aerodynamic power
    % Check if rotor speed is below cut-in rotor speed
    if turb.Omg(i) < turb.Omg_cutin
        turb.Omg(i) = turb.Omg_cutin;                                   % Correct to cut-in rotor speed
        turb.lambda(i) = turb.Omg(i)/30*pi*turb.R/turb.V(i);            % Compute corresponding tsr
        turb.cp(i) = cpInterpolant(turb.theta(i),turb.lambda(i));       % Find new power coefficient
        turb.Paero(i) = 0.5*1.225*pi*turb.R^2*turb.cp(i)*turb.V(i)^3;   % Compute corrected aerodynamic power
    % Check if rotor speed is above rated rotor speed
    elseif turb.Omg(i) > turb.Omg_rat
        turb.Omg(i) = turb.Omg_rat;                                     % Correct to rated rotor speed    
        turb.lambda(i) = turb.Omg(i)/30*pi*turb.R/turb.V(i);            % Compute corresponding tsr
        turb.cp(i) = cpInterpolant(turb.theta(i),turb.lambda(i));       % Find new power coefficient
        turb.Paero(i) = 0.5*1.225*pi*turb.R^2*turb.cp(i)*turb.V(i)^3;   % Compute corrected aerodynamic power
        % Check if aerodynamic power is greater than rated power
        if turb.Paero(i) > turb.P_rat
           turb.cp(i) = turb.P_rat/(0.5*1.225*pi*turb.R^2*turb.V(i)^3);                             % Compute new power coefficient
           turb.Paero(i) = 0.5*1.225*pi*turb.R^2*turb.cp(i)*turb.V(i)^3;                            % Compute corrected aerodynamic power
           turb.theta(i) =  fmincon((@(x)abs(cpInterpolant(x,turb.lambda(i))-turb.cp(i))),0,...     % Find pitch angle to achieve new cp    
                                    [],[],[],[],turb.theta(i-1),max(bemData.pitch));
        end
    % Check if aerodynamic power is greater than rated power   
    elseif turb.Paero(i) > turb.P_rat
       turb.cp(i) = turb.P_rat/(0.5*1.225*pi*turb.R^2*turb.V(i)^3);                             % Compute new power coefficient
       turb.Paero(i) = 0.5*1.225*pi*turb.R^2*turb.cp(i)*turb.V(i)^3;                            % Compute corrected aerodynamic power
       turb.theta(i) =  fmincon((@(x)abs(cpInterpolant(x,turb.lambda(i))-turb.cp(i))),0,...     % Find pitch angle to achieve new cp    
                                [],[],[],[],turb.theta(i-1),max(bemData.pitch));
    end
    turb.ct(i) = ctInterpolant(turb.theta(i),turb.lambda(i));           % Find thrust coefficient
    turb.Thrust(i) = 0.5*1.225*pi*turb.R^2.*turb.ct(i).*turb.V(i).^2;   % Compute thrust force
end

%% Plot results
% Plot Cp and Ct data from FAST
figure; 
subplot(1,2,1); box on;
surf(X,Y,max(bemData.cp',0),'EdgeColor','none')
axis([min(bemData.pitch) max(bemData.pitch) min(bemData.tsr) max(bemData.tsr) 0 0.6])
view([0,90])
xlabel('Pitch angle [deg]','Interpreter','latex')
ylabel('Tip-speed ratio [-]','Interpreter','latex')
colorbar; 
subplot(1,2,2); box on;
surf(X,Y,max(bemData.ct',0),'EdgeColor','none')
axis([min(bemData.pitch) max(bemData.pitch) min(bemData.tsr) max(bemData.tsr) 0 1.5])
view([0,90])
xlabel('Pitch angle [deg]','Interpreter','latex')
ylabel('Tip-speed ratio [-]','Interpreter','latex')
colorbar; 
colormap jet

% Plot settings vs. wind speed
figure; box on;
plot(turb.V, turb.lambda,'k','LineWidth',1)
xlabel('Wind speed [m/s]','Interpreter','latex')
ylabel('Tip-speed ratio [-]','Interpreter','latex')
xlim([4 25])

figure; box on; 
plot(turb.V, turb.theta,'k','LineWidth',1)
xlabel('Wind speed [m/s]','Interpreter','latex')
ylabel('Pitch angle [deg]','Interpreter','latex')
xlim([4 25])

figure; box on; 
plot(turb.V, turb.cp,'k','LineWidth',1)
xlabel('Wind speed [m/s]','Interpreter','latex')
ylabel('$C_p$ [-]','Interpreter','latex')
xlim([4 25])

figure; box on;
plot(turb.V, turb.ct,'k','LineWidth',1)
xlabel('Wind speed [m/s]','Interpreter','latex')
ylabel('$C_t$ [-]','Interpreter','latex')
xlim([4 25])

figure; box on; 
plot(turb.V, turb.Paero*1e-6,'k','LineWidth',1)
xlabel('Wind speed [m/s]','Interpreter','latex')
ylabel('$P_{aero}$ [MW]','Interpreter','latex')
xlim([4 25])

figure; box on;  
plot(turb.V, turb.Thrust*1e-3,'k','LineWidth',1)
xlabel('Wind speed [m/s]','Interpreter','latex')
ylabel('$F_{thrust}$ [kN]','Interpreter','latex')
xlim([4 25])

