%% Find closest match of Ct Cp table with the axial induction factor

load('./TurbineData/VCpCt_10MW.mat'); % Output VCpCt

aOpt = zeros(size(VCpCt,1),1);
Ct = @(a) 4*a.*(1-a);
Cp = @(a) 4*a.*(1-a).^2;

% Smaller/equal than 1/3 & not negative
A = [3;-1];
b = [1;0];
for ind = 1:size(VCpCt,1)
    J = @(a) 5*(VCpCt(ind,2)-Cp(a))^2+(VCpCt(ind,3)-Ct(a))^2;
    aOpt(ind) = fmincon(J,0.2,A,b);
end
%% Plot

f = figure;

subplot(2,1,1)
plot(VCpCt(:,1),VCpCt(:,2),'--','LineWidth',1.5)
hold on
plot(VCpCt(:,1),VCpCt(:,3),'-.','LineWidth',1.5)
plot(VCpCt(:,1),Cp(aOpt),'--','LineWidth',1.5)
plot(VCpCt(:,1),Ct(aOpt),'-.','LineWidth',1.5)
hold off
ylabel('C_p and C_t')
xlabel('Wind speed in m/s')
title('C_p and C_t coefficient based on the wind speed')
xlim([4 25])
legend('C_p','C_t','C_p(a)','C_t(a)')
grid on

subplot(2,1,2)
plot(VCpCt(:,1),aOpt,':','LineWidth',3)
ylabel('Axial induction factor')
grid on
xlim([4 25])
xlabel('Wind speed in m/s')
title('Axial induction factor to approximate C_t and C_p')
%% Make ready for thesis
f.Units               = 'centimeters';
f.Position(3)         = 16.1; % line width

% Set font & size
set(f.Children, ...
    'FontName',     'Frontpage', ...
    'FontSize',     10);

set(gca,'LooseInset', max(get(gca,'TightInset'), 0.04))

% Export
f.PaperPositionMode   = 'auto';
%% Print
print('CpCtApproximated', '-dpng', '-r600')
