%% EXPORT FIGURE FOR LATEX SETTINGS
f = gcf;
% ==== Prep for export ==== %
% scaling
f.Units               = 'centimeters';
f.Position(3)         = 16.1; % line width
%f.Position(3)         = 8;

% Set font & size
set(f.Children, ...
    'FontName',     'Frontpage', ...
    'FontSize',     10);

set(gca,'LooseInset', max(get(gca,'TightInset'), 0.04))

% Export
f.PaperPositionMode   = 'auto';
print('TitleGoesHere', '-dpng', '-r600')

print('Performance_totalNumOP', '-dpng', '-r600')