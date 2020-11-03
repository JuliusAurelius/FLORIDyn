file2val = '/ValidationData/csv/3T_pos_y_';
powSOWFA_WPS = importGenPowerFile([file2val 'generatorPower.csv']);
nT = 3;

f = figure(1);

hold on
for iT = 1:nT
    plot(...
        powSOWFA_WPS(iT:nT:end,2)-powSOWFA_WPS(iT,2),...
        movmean(powSOWFA_WPS(iT:nT:end,3)/1.225,1),...
        '-.','LineWidth',1)
    labels{iT} = ['T' num2str(iT-1) ' SOWFA wps'];
end
%M = movmean(A,[2 0]);

hold off

grid on
xlim([0 powSOWFA_WPS(end,2)-powSOWFA_WPS(iT,2)])
xlabel('Time [s]')
ylabel('Power generated [W]')
title('Three turbine case, changing blade pitch angle')
%legend(labels)
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