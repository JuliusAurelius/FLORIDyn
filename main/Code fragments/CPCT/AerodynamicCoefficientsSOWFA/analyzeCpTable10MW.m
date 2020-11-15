clear all; close all; clc

% Add libraries
%addpath('C:\Users\daanvanderhoek\surfdrive\PhD\Software development\SOWFA_tools-master\readTurbineOutput')
%addpath('C:\Users\daanvanderhoek\surfdrive\PhD\Software development\export_fig')

% Main directory
% mainPath = 'W:\OpenFOAM\daanvanderhoek-2.4.0\simulationCases\2020_Thesis_Marcus\1turb_runs'; %_pitch0_pitch5_pitch10_pitch15';

% Simulation properties
U = 7.0; % Freestream wind speed
H = 119.0; % Turbine hub height
R = 178.3 / 2.0; % Rotor radius (m)
A = pi * R^2; % Rotor swept surface area
dt = 0.20; % Timestep
changeFrequency = 250; % How often pitch angle is changed [s]

% % Get all cases
% subdirPaths = dir([mainPath filesep 'k*']);
% extrcIdStep = (changeFrequency/dt);
% 
% % Create empty variables
% sowfaData  = struct('kArray',[],...
%                    'pitchArray',[],...
%                   'tsrArray',[],...
%                   'cpArray',[],...
%                   'ctArray',[]);
    
%% Calculate aerodynamic performance values from SOWFA data
% for fi = 1:length(subdirPaths)
%     disp(['Loading data from simulation case ' num2str(fi) '/' num2str(length(subdirPaths)) '.']);
%     filepath = [subdirPaths(fi).folder filesep subdirPaths(fi).name filesep 'postProcessing/turbineOutput/0/'];
%     
%     try
%         pitch = [0.0:2.0:26.0]'; % Fixed timeseries
%         [time,rotorAxialForce] = readOOPTdata([filepath 'rotorAxialForce']);
%         [timew,rotSpeedF] = readOOPTdata([filepath 'rotorSpeedFiltered']);
%         [time,power] = readOOPTdata([filepath 'generatorPower']);
%         power = power ./ 1.225; % Correction
%         tsr = rotSpeedF * (2*pi/60) .* (R / U);
%                 
%         plotPowerTimeseries = false;
%         if plotPowerTimeseries
%             figure()
%             subplot(2,1,1)
%             plot(time,power);
%             ylabel('Power (W)')
%             xlim([0 3500])
%             title(subdirPaths(fi).name)
%             subplot(2,1,2)
%             plot(timew,tsr);
%             xlabel('Time (s)')
%             ylabel('TSR (-)')
%             xlim([0 3500])
%             drawnow()
%         end
%         
%         % Extract steady-state values
%         pitchSS = [];
%         tsrSS = [];
%         powerSS = [];
%         rotorAxialForceSS = [];
%         
%         for ii = 1:floor(length(tsr)/extrcIdStep)
%             powerStd50s = std(power((ii*extrcIdStep-250):(ii*extrcIdStep)));
%             powerMean50s = mean(power((ii*extrcIdStep-250):(ii*extrcIdStep)));
%             if ((tsr(ii*extrcIdStep) > 0) && (abs(powerMean50s) < 1e-6)) || ... % Positive rotation but no power
%                ((tsr(ii*extrcIdStep) > 0) && (powerStd50s/powerMean50s < 0.01)); % Less than 1% st. dev.
%             
%                 pitchSS = [pitchSS; pitch(ii)];
%                 tsrSS = [tsrSS; tsr(ii*extrcIdStep)];
%                 powerSS = [powerSS; power(ii*extrcIdStep)];
%                 rotorAxialForceSS = [rotorAxialForceSS; rotorAxialForce(ii*extrcIdStep)];
%             else
%                 disp(['Discarding ' subdirPaths(fi).name ' and pitch = ' num2str(pitch(ii)) ' deg from dataset (no steady-state).'])
%             end
%         end
% 
%         % Calculate derivatives
%         cp = powerSS ./ (0.5 * 1.225 * A * U^3); % Includes efficiency terms
%         ct = rotorAxialForceSS ./ (0.5 * 1.225 * A * U^2);
% 
%         % Write to outData
%         sowfaData.kArray = [sowfaData.kArray; str2num(subdirPaths(fi).name(2:end))*ones(size(cp))];
%         sowfaData.pitchArray = [sowfaData.pitchArray; pitchSS];
%         sowfaData.tsrArray = [sowfaData.tsrArray; tsrSS];
%         sowfaData.cpArray = [sowfaData.cpArray; cp];
%         sowfaData.ctArray = [sowfaData.ctArray; ct];
%     catch
%         disp(['  Could not load the data for ' subdirPaths(fi).name '.'])
%     end
% end

%% Load data from FAST
CpCtCq = import10MwCpCtCqfile();
bemData.pitch = str2num(CpCtCq(5,1).Variables);
bemData.tsr   = str2num(CpCtCq(7,1).Variables)';
for ii = 1:48
    bemData.cp(ii,:) = str2num(CpCtCq(12 + ii,1).Variables);
    bemData.ct(ii,:) = str2num(CpCtCq(64 + ii,1).Variables);
    bemData.cq(ii,:) = str2num(CpCtCq(116+ ii,1).Variables);
end

[X,Y] = ndgrid(bemData.pitch',bemData.tsr);
cpInterpolant = griddedInterpolant(X,Y,bemData.cp');
ctInterpolant = griddedInterpolant(X,Y,bemData.ct');

R = 178.3/2;
V_rat = 11.4;
Omg_cutin = 6;
Omg_rat = 9.6;
P_rat = 10.6e6;

V = 4:25;
theta_opt = 0;
i_theta_opt = find(bemData.pitch==theta_opt);
[~,i_lambda_opt] = max(bemData.cp(:,i_theta_opt));
lambda_opt = bemData.tsr(i_lambda_opt);

for i = 1:length(V)
    theta(i) = theta_opt;
    lambda(i) = lambda_opt; 
    Omg(i) = lambda_opt*V(i)/R*30/pi;
    cp(i) = cpInterpolant(theta(i),lambda(i));
    P(i) = 0.5*1.225*pi*R^2*cp(i)*V(i)^3;
    if Omg(i) < Omg_cutin
        Omg(i) = Omg_cutin;
        lambda(i) = Omg(i)/30*pi*R/V(i);
    elseif Omg(i) > Omg_rat
        Omg(i) = Omg_rat;
        lambda(i) = Omg(i)/30*pi*R/V(i);
        P(i) = 0.5*1.225*pi*R^2*cpInterpolant(theta(i),lambda(i))*V(i)^3;
        if P(i) > P_rat
           cp(i) = P_rat/(0.5*1.225*pi*R^2*V(i)^3);
           theta(i) =  fmincon((@(x)abs(cpInterpolant(x,lambda(i))-cp(i))),0,[],[],[],[],theta(i-1),max(bemData.pitch));
        end 
    end
    ct(i) = ctInterpolant(theta(i),lambda(i));
    
end

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

% 10 MW specifications
Paero = 0.5*1.225*pi*R^2.*cp.*V.^3;
Thrust = 0.5*1.225*pi*R^2.*ct.*V.^2;
            
%% Create operating curves with SOWFA data
% load data
load('Cp_Ct_SOWFA.mat')

sowfaData.cpInterp = scatteredInterpolant(sowfaData.pitchArray,sowfaData.tsrArray,sowfaData.cpArray,'linear','none');
sowfaData.ctInterp = scatteredInterpolant(sowfaData.pitchArray,sowfaData.tsrArray,sowfaData.ctArray,'linear','none');

sowfaData.V = 4:15;
for i = 1:length(sowfaData.V)
    sowfaData.theta(i) = theta_opt;
    sowfaData.lambda(i) = lambda_opt; 
    sowfaData.Omg(i) = lambda_opt*sowfaData.V(i)/R*30/pi;
    sowfaData.cp(i) = sowfaData.cpInterp(sowfaData.theta(i),sowfaData.lambda(i));
    sowfaData.P(i) = 0.5*1.225*pi*R^2*sowfaData.cp(i)*sowfaData.V(i)^3;
    if sowfaData.Omg(i) < Omg_cutin
        sowfaData.Omg(i) = Omg_cutin;
        sowfaData.lambda(i) = sowfaData.Omg(i)/30*pi*R/sowfaData.V(i);
    elseif sowfaData.Omg(i) > Omg_rat
        sowfaData.Omg(i) = Omg_rat;
        sowfaData.lambda(i) = sowfaData.Omg(i)/30*pi*R/sowfaData.V(i);
        sowfaData.P(i) = 0.5*1.225*pi*R^2*sowfaData.cpInterp(sowfaData.theta(i),sowfaData.lambda(i))*sowfaData.V(i)^3;
        if sowfaData.P(i) > P_rat
           sowfaData.cp(i) = P_rat/(0.5*1.225*pi*R^2*sowfaData.V(i)^3);
           sowfaData.theta(i) =  fmincon((@(x)abs(sowfaData.cpInterp(x,sowfaData.lambda(i))-sowfaData.cp(i))),0,[],[],[],[],sowfaData.theta(i-1),max(sowfaData.pitchArray));
        end 
    end
    sowfaData.ct(i) = sowfaData.ctInterp(sowfaData.theta(i),sowfaData.lambda(i));
    
end
sowfaData.Paero = 0.5*1.225*pi*R^2.*sowfaData.cp.*sowfaData.V.^3;
sowfaData.Thrust = 0.5*1.225*pi*R^2.*sowfaData.ct.*sowfaData.V.^2;


% Compare results
figure; plot(V,lambda); hold on; plot(sowfaData.V,sowfaData.lambda); xlabel('Wind speed [m/s]'); ylabel('TSR [-]'); legend('FAST','SOWFA')
figure; plot(V,theta);  hold on; plot(sowfaData.V,sowfaData.theta); xlabel('Wind speed [m/s]'); ylabel('Pitch angle [deg]'); legend('FAST','SOWFA')
figure; plot(V,cp);  hold on; plot(sowfaData.V,sowfaData.cp); xlabel('Wind speed [m/s]'); ylabel('Cp [-]'); legend('FAST','SOWFA')
figure; plot(V,ct);  hold on; plot(sowfaData.V,sowfaData.ct); xlabel('Wind speed [m/s]'); ylabel('Ct [-]'); legend('FAST','SOWFA')
figure; plot(V,Paero);  hold on; plot(sowfaData.V,sowfaData.Paero); xlabel('Wind speed [m/s]'); ylabel('Power [-]'); legend('FAST','SOWFA')
figure; plot(V,Thrust);  hold on; plot(sowfaData.V,sowfaData.Thrust); xlabel('Wind speed [m/s]'); ylabel('Thrust [-]'); legend('FAST','SOWFA')

%% Compare BEM data with SOWFA data
% % tsrScaling = 1.07; % Assign a correction factor
% % cpScaling = 0.95*1.0062; % Assign a correction factor
% 
% % sowfaData.tsrArrayManipulated = sowfaData.tsrArray(:)*tsrScaling .* (1+0.02*(sowfaData.tsrArray(:)>9).*(sowfaData.tsrArray(:)-9));
% % sowfaData.pitchArrayManipulated = sowfaData.pitchArray(:);
% % sowfaData.cpArrayManipulated = sowfaData.cpArray(:)*cpScaling  .* (1.01-0.0004*(sowfaData.pitchArray(:)-5).^2) .* (1+0.02*(sowfaData.pitchArray(:)>7.5).*(sowfaData.pitchArray(:)-7.5));
% 
% for plotPitch = unique(sowfaData.pitchArray)'
%     % plotPitch = 0.0;  % Plot for 0.0 deg
%     extractIds = find(abs(sowfaData.pitchArray - plotPitch) < 10*eps);
%     if length(extractIds) <= 0
%         error(['Pitch angle of ' num2str(plotPitch) ' deg not found in SOWFA dataset.'])
%     end
%     plotCp = sowfaData.cpArray(extractIds);
%     plotCt = sowfaData.ctArray(extractIds);
%     plotTSR = sowfaData.tsrArray(extractIds);
% 
%     figure()
%     plot(bemData.tsr,cpInterpolant(plotPitch*ones(size(bemData.tsr)),bemData.tsr),'k--');
%     hold on
%     plot(plotTSR,plotCp,'rx');
%     
% %     manipulatedTSR = plotTSR * tsrScaling .* (1+0.02*(plotTSR>9).*(plotTSR-9)); % Correction for pitch=0
% %     manipulatedCp =  plotCp  * cpScaling  .* (1.01-0.0004*(plotPitch-5)^2); % Correction for pitch <= 5
% %     manipulatedCp =  manipulatedCp  .* (1+0.02*(plotPitch>7.5).*(plotPitch-7.5)); % Correction for pitch >= 7.5
% %     plot(sowfaData.tsrArrayManipulated(sowfaData.pitchArrayManipulated==plotPitch),sowfaData.cpArrayManipulated(sowfaData.pitchArrayManipulated==plotPitch),'bo'); % Plot corrected curve
%     legend({'BEM (FAST)','SOWFA'})%,'SOWFA (corrected)'})
%     title(['Pitch = ' num2str(plotPitch) ' deg'])
%     xlabel('Tip-speed ratio (-)')
%     ylabel('Cp (-)')
%     xlim([0 16])
%     ylim([0 0.6])
%     grid on
% end

%% Plot surfaces
% % figure()
% % contourf(Y',X',bemData.cp,0:0.01:0.6,'LineStyle','none')
% % xlabel('Tip-speed ratio (-)')
% % ylabel('Pitch (deg)')
% % zlim([0 0.6])
% % title('Cp table (BEM)')
% % clb=colorbar('Limits',[0 0.6])
% % hold on
% % plot(sowfaData.tsrArray(:),sowfaData.pitchArray(:),'k.');
% 
% % 
% sowfaInterpolantCp = scatteredInterpolant(sowfaData.tsrArray,sowfaData.pitchArray,sowfaData.cpArray,'linear','none');
% % sowfaInterpolantCpManipulated = scatteredInterpolant(sowfaData.tsrArrayManipulated,sowfaData.pitchArrayManipulated,sowfaData.cpArrayManipulated,'linear','nearest');
% 
% figure('Position',[588.2000 349.8000 813.6000 235.2000])
% subplot(1,2,1);
% ctzlim = [0.6];
% % grid on
% Z = sowfaInterpolantCp(Y',X');
% contourf(Y',X',Z,0.01:0.01:ctzlim,'LineStyle','none','HandleVisibility','off')
% xlabel('Tip-speed ratio; $\lambda$ (-)','Interpreter','latex')
% ylabel('Pitch; $\beta$ (deg)','Interpreter','latex')
%  zlim([0.00 ctzlim])
% set(gca,'CLim',[-0.1 ctzlim])
% clb=colorbar('Limits',[0 ctzlim],'TickLabelInterpreter','latex')
% hold on 
% title('Power coefficient curve; $C_{\mathrm{P}} \left( \lambda, \beta \right) $','Interpreter','latex')
% text(7.1,0.85,'$C_{\textrm{P}}^{\textrm{opt}}$','Interpreter','latex','FontSize',10,'HandleVisibility','off')
% plot([8.5 8.5],[0 12],'k--','HandleVisibility','off') % Vertical line
% plot([7.6 8.5],[0.08 0.08],'k--','HandleVisibility','off') % Horizontal line
% scatter(8.5,12,'filled','MarkerFaceColor','k','HandleVisibility','off')
% text(8.2,13.5,'$C_{\textrm{P}} = 0.0$','Interpreter','latex','FontSize',10,'HandleVisibility','off')
% text(8.6,6,{'$\lambda^{\textrm{max}}$'},'Interpreter','latex','Rotation',0,'FontSize',10,'HandleVisibility','off')
% % Zoom in on covered area
% xlim([5.9 10.0]); ylim([0 18])
% scatter(7.6,0.1,'filled','MarkerFaceColor','w','MarkerEdgeColor','k') % optimal point
% % legend({'Position of $C_{\textrm{P}}^{\textrm{opt}}$'},'interpreter','latex')
% set(gca,'TickLabelInterpreter','latex')
% set(gcf,'color','white')
% % export_fig('cpCurve.pdf')
% % figure()
% % contourf(Y',X',sowfaInterpolantCpManipulated(Y',X'),0:0.01:0.6,'LineStyle','none')
% % xlabel('Tip-speed ratio (-)')
% % ylabel('Pitch (deg)')
% % zlim([0 0.6])
% % title('Cp table (SOWFA corrected)')
% % clb=colorbar('Limits',[0 0.6])
% 
% 
% % Plot Ct figure
% % figure()
% subplot(1,2,2);
% % grid on
% ctzlim = [1.1];
% sowfaInterpolantCt = scatteredInterpolant(sowfaData.tsrArray,sowfaData.pitchArray,sowfaData.ctArray,'linear','none');
% Z = sowfaInterpolantCt(Y',X');
% contourf(Y',X',Z,0.01:0.01:ctzlim,'LineStyle','none','HandleVisibility','off')
% title('Thrust coefficient curve; $C_{\mathrm{T}} \left( \lambda, \beta \right) $','Interpreter','latex')
% xlabel('Tip-speed ratio; $\lambda$ (-)','Interpreter','latex')
% ylabel('Pitch; $\beta$ (deg)','Interpreter','latex')
% % set(gca,'YTickLabel',[])
%  zlim([0.00 ctzlim])
% set(gca,'CLim',[-0.1 ctzlim])
% clb=colorbar('Limits',[0 ctzlim],'TickLabelInterpreter','latex')
% hold on 
% % text(7.1,0.85,'$C_{\textrm{P}}^{\textrm{opt}}$','Interpreter','latex','FontSize',10,'HandleVisibility','off')
% plot([8.5 8.5],[0 12],'k--','HandleVisibility','off') % Vertical line
% plot([7.6 8.5],[0.08 0.08],'k--','HandleVisibility','off') % Horizontal line
% scatter(8.5,12,'filled','MarkerFaceColor','k','HandleVisibility','off')
% % text(8.2,13.5,'$C_{\textrm{P}} = 0.0$','Interpreter','latex','FontSize',10,'HandleVisibility','off')
% % text(8.6,6,{'$\lambda^{\textrm{max}}$'},'Interpreter','latex','Rotation',0,'FontSize',10,'HandleVisibility','off')
% % Zoom in on covered area
% xlim([5.9 10.0]); ylim([0 18])
% scatter(7.6,0.1,'filled','MarkerFaceColor','w','MarkerEdgeColor','k') % optimal point
% % legend({'Position of $C_{\textrm{P}}^{\textrm{opt}}$'},'interpreter','latex')
% set(gca,'TickLabelInterpreter','latex')
% set(gcf,'color','white')
% pt=patch([6 10 10 6],[19 10.5 19 19],[-0.1 -0.1 -0.1 -0.1])
% pt.FaceColor = 'w';
% pt.EdgeColor = 'w';
% % export_fig('cpCtCurve.pdf')

%% Plot coverage
% indxs = find(abs(sowfaData.pitchArray-0.0)<10*eps);
% figure()
% plot(sowfaData.tsrArray(indxs),sowfaData.kArray(indxs),'k.')
% xlabel('TSR (-)')
% ylabel('k factor (-)')
% ylim([0 11])
% grid minor


%% Create an interpolant in the right format
% cpInterpolant = scatteredInterpolant(sowfaData.tsrArray,sowfaData.pitchArray,sowfaData.cpArray,'linear','nearest'); % 10MW
% save('cpInterpolant10MW_SOWFA.mat','cpInterpolant');


%% PLOT Ct Cp table
f = figure;
hold on
plot(sowfaData.V,sowfaData.cp,'LineWidth',2);
plot(sowfaData.V,sowfaData.ct,'--','LineWidth',2);
xlabel('Wind speed [m/s]')
xlim([4 15])
grid on
ylabel('C_P and C_T [-]')
legend('C_P','C_T')
%title('C_p and C_t coefficient based on the wind speed')
hold off

% ==== Prep for export ==== %
% scaling
f.Units               = 'centimeters';
f.Position(3)         = 16.1; % line width

% Set font & size
set(f.Children, ...
    'FontName',     'Frontpage', ...
    'FontSize',     10);

set(gca,'LooseInset', max(get(gca,'TightInset'), 0.04))

% Export
f.PaperPositionMode   = 'auto';
%print('TitleGoesHere', '-dpng', '-r600')
%%
ct=sowfaData.ct;
ct(1) = ct(2);
VCpCt=[sowfaData.V',sowfaData.cp',ct'];
%% pa
f = figure; 
box on;
surf(X,Y,max(bemData.cp',0),'EdgeColor','none')
axis([min(bemData.pitch) max(bemData.pitch) min(bemData.tsr) max(bemData.tsr) 0 0.6])
view([0,90])
xlabel('Pitch angle [°]')
ylabel('Tip-speed ratio [-]')
c = colorbar;
c.Label.String = 'C_P';
%title('Interpolated C_P table')
% ==== Prep for export ==== %
% scaling
f.Units               = 'centimeters';
f.Position(3)         = 16.1/2; % line width

% Set font & size
set(f.Children, ...
    'FontName',     'Frontpage', ...
    'FontSize',     10);

set(gca,'LooseInset', max(get(gca,'TightInset'), 0.11))

% Export
f.PaperPositionMode   = 'auto';
%%
f = figure;
box on;
surf(X,Y,max(bemData.ct',0),'EdgeColor','none')
axis([min(bemData.pitch) max(bemData.pitch) min(bemData.tsr) max(bemData.tsr) 0 1.5])
view([0,90])
xlabel('Pitch angle [°]')
ylabel('Tip-speed ratio [-]')
c = colorbar;
c.Label.String = 'C_T';
%title('Interpolated C_t table')
% ==== Prep for export ==== %
% scaling
f.Units               = 'centimeters';
f.Position(3)         = 16.1/2; % line width

% Set font & size
set(f.Children, ...
    'FontName',     'Frontpage', ...
    'FontSize',     10);

set(gca,'LooseInset', max(get(gca,'TightInset'), 0.11))

% Export
f.PaperPositionMode   = 'auto';
%colormap jet