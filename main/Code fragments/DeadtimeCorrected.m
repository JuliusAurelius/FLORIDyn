% Plotting
f = figure;
hold on
labels = cell(3,1);
% =========== SOWFA data ===========
for iT = 2
    plot(...
        powSOWFA_WPS(iT:nT:end,2)-powSOWFA_WPS(iT,2),...
        powSOWFA_WPS(iT:nT:end,3)/UF.airDen,...
        '-.','LineWidth',1)
    labels{1} = ['T' num2str(iT-1) ' SOWFA wps'];
end

% ========== FLORIDyn data =========
for iT = 2
    plot(powerHist(:,1),powerHist(:,iT+1),'LineWidth',1.5)
    labels{2} = ['T' num2str(iT-1) ' FLORIDyn'];
end

for iT = 2
    plot(powerHist(:,1)+50,powerHist(:,iT+1),':','LineWidth',1.5)
    labels{3} = ['T' num2str(iT-1) ' FLORIDyn + 50s'];
end
% % Plot second FLORIDyn results
% for iT = 1:length(T.D)
%     plot(powerHist(:,1),powerHist(:,iT+1),'--','LineWidth',1.5)
%     labels{iT} = ['T' num2str(iT-1) ' FLORIDyn'];
% end

% % //// EXTRA YAW  ////
% % Yaw T0
% plot([200,200],[-.3,.3]*10^6+powerHist(51,2),'k','LineWidth',1)
% plot([500,500],[-.3,.3]*10^6+powerHist(126,2),'k','LineWidth',1)
% plot([800,800],[-.3,.3]*10^6+powerHist(201,2),'k','LineWidth',1)
% % Yaw T1
% plot([350,350],[-.3,.3]*10^6+powerHist(89,3),'k','LineWidth',1)
% plot([650,650],[-.3,.3]*10^6+powerHist(164,3),'k','LineWidth',1)
% plot([950,950],[-.3,.3]*10^6+powerHist(239,3),'k','LineWidth',1)
% % 
% legend(...
%     'T0 SOWFA wps','T1 SOWFA wps','T2 SOWFA wps',...
%     'T0 FLORIDyn','T1 FLORIDyn','T2 FLORIDyn')
% % //// EXTRA OVER ////

hold off

grid on
xlim([50 600])
xlabel('Time [s]')
ylabel('Power generated [W]')
title('Blade pitch angle change, dead-time corrected')
legend(labels)
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