t9 = [...
    90 10 153.7850;
    72 8 133.8658;
    54 6 82.7716;
    36 4 65.3863;
    28 2 34.4197];

t4 = [...
    40 10 27.3552;
    32 8 23.4535;
    24 6 15.3325;
    16 4 12.0081;
    8 2 6.4949];

t3 = [
    30 10 14.7421;
    27 9 13.7795;
    24 8 12.5982;
    21 7 11.7102;
    18 6 8.4376;
    15 5 7.6552;
    12 4 6.4963;
    9 3 4.7061;
    6 2 3.7291];

t2 = [
    20 10 6.1271;
    18 9 5.7326;
    16 8 5.2116;
    14 7 4.8093;
    12 6 3.7036;
    10 5 3.3446;
    8 4 2.8820;
    6 3 2.1228;
    4 2 1.7664];

%% Plot
f = figure;
hold on
semilogy(t9(:,1),t9(:,3),'LineWidth',2)
semilogy(t4(:,1),t4(:,3),'LineWidth',2)
semilogy(t3(:,1),t3(:,3),'LineWidth',2)
semilogy(t2(:,1),t2(:,3),'LineWidth',2)
hold off
grid on
xlabel('Total number of OPs')
ylabel('Time [s]')
title('251 simulation steps for different numbers of turbines')
legend('9 turbines','4 turbines','3 turbines','2 turbines')
f.Units               = 'centimeters';
f.Position(3)         = 16.1; % line width
set(f.Children, ...
    'FontName',     'Frontpage', ...
    'FontSize',     10);
set(gca,'LooseInset', max(get(gca,'TightInset'), 0.04))
f.PaperPositionMode   = 'auto';
%% 
f = figure;
hold on
semilogy(t9(:,2),t9(:,3),'LineWidth',2)
semilogy(t4(:,2),t4(:,3),'LineWidth',2)
semilogy(t3(:,2),t3(:,3),'LineWidth',2)
semilogy(t2(:,2),t2(:,3),'LineWidth',2)
hold off
grid on
xlabel('Number of OPs per turbine')
ylabel('Time [s]')
title('251 simulation steps for different numbers of turbines')
legend('9 turbines','4 turbines','3 turbines','2 turbines')

f.Units               = 'centimeters';
f.Position(3)         = 16.1; % line width
set(f.Children, ...
    'FontName',     'Frontpage', ...
    'FontSize',     10);
set(gca,'LooseInset', max(get(gca,'TightInset'), 0.04))
f.PaperPositionMode   = 'auto';

%% Plot
f = figure;
semilogy(t9(:,1),t9(:,3),t4(:,1),t4(:,3),t3(:,1),t3(:,3),t2(:,1),t2(:,3))
grid on
xlabel('Total number of OPs')
ylabel('Time [s]')
title('251 simulation steps for different numbers of turbines')
legend('9 turbines','4 turbines','3 turbines','2 turbines')

f.Units               = 'centimeters';
f.Position(3)         = 16.1; % line width
set(f.Children, ...
    'FontName',     'Frontpage', ...
    'FontSize',     10);
set(gca,'LooseInset', max(get(gca,'TightInset'), 0.04))
f.PaperPositionMode   = 'auto';
%% Plot
f = figure;
semilogy(t9(:,2),t9(:,3)/251,t4(:,2),t4(:,3)/251,t3(:,2),t3(:,3)/251,t2(:,2),t2(:,3)/251)
grid on
xlabel('Number of OPs per turbine')
ylabel('Time step duration [s]')
title('251 simulation steps for different numbers of turbines')
legend('9 turbines','4 turbines','3 turbines','2 turbines')

f.Units               = 'centimeters';
f.Position(3)         = 16.1; % line width
set(f.Children, ...
    'FontName',     'Frontpage', ...
    'FontSize',     10);
set(gca,'LooseInset', max(get(gca,'TightInset'), 0.04))
f.PaperPositionMode   = 'auto';