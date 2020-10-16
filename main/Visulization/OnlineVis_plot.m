
if i>1
    delete(p)
    delete(q)
end

%% Plot the OPs
f = figure(1);
clf;
hold on
u_l = min(sqrt(sum(OP.u.^2,2)));
%ff = sqrt(sum(OP.u.^2,2))>(u_l*1.2)*0;
% if Dim==2
%     u_max = 20;
%     slow = sqrt(sum(OP.u.^2,2))<u_max;
%     p = scatter3(OP_pos_old(slow,1),OP_pos_old(slow,2),sqrt(sum(OP.u(slow,:).^2,2)),...
%         ones(size(OP.t_id(slow)))*40,sqrt(sum(OP.u(slow,:).^2,2)),...
%         'filled');
% else
n_th = 4;
p = scatter3(...
    OP_pos_old(1:n_th:end,1),...
    OP_pos_old(1:n_th:end,2),...
    OP_pos_old(1:n_th:end,3),...
    30-sqrt(sum(OP.u(1:n_th:end,:).^2,2)),...
    sqrt(sum(OP.u(1:n_th:end,:).^2,2)),...
    'filled');
%     p = scatter3(OP_pos_old(:,1),OP_pos_old(:,2),OP_pos_old(:,3),...
%         20-sqrt(sum(OP.u.^2,2)),sqrt(sum(OP.u.^2,2)),...%ones(size(OP.t_id(:)))*20,sqrt(sum(OP.u.^2,2)),...
%         'filled');
% end
Uq = getWindVec3([UF.ufieldx(:),UF.ufieldy(:)],UF.IR, U_abs, U_ang, UF.Res, UF.lims);
q = quiver(UF.ufieldx(:),UF.ufieldy(:),Uq(:,1),Uq(:,2),'Color',[0.5,0.5,0.5]);


c = colorbar;
c.Label.String ='Windspeed [m/s]';
c.Limits = [0,10];
xlabel('West-East [m]')
ylabel('South-North [m]')
xlim(fLim_x);
ylim(fLim_y);
% if Dim == 3
    zlabel('Height [m]')
    zlim([-300,500]);
% end
grid on
%% Plot the rotors
for i_T = 1:length(T.D)
    if i>1
        delete(rotors{i_T});
    end
    
    %Plot circular Rotor
    phi = linspace(0,2*pi);
    r = T.D(i_T)/2;
    yR = r*cos(phi);
    zR = r*sin(phi);
    
    cR = [...
        -sin(T.yaw(i_T)),0;...
        cos(T.yaw(i_T)),0;
        0,1]*[yR;zR];
    
    cR = cR'+T.pos(i_T,:);
    plot3(cR(:,1),cR(:,2),cR(:,3),'k','LineWidth',3);
%     % Get start and end of the turbine rotor
%     rot_pos = ...
%         [cos(T.yaw(i_T)), -sin(T.yaw(i_T));...
%         sin(T.yaw(i_T)), cos(T.yaw(i_T))] * ...
%         [0,0;T.D(i_T)/2,-T.D(i_T)/2];
%     rot_pos = rot_pos + T.pos(i_T,1:2)';
%     rotors{i_T} = plot3(rot_pos(1,:),rot_pos(2,:),[20,20],'k','LineWidth',3);
end

hold off
%% Plot the Power Output
% subplot(2,1,2)
% plot(Sim.TimeSteps,powerHist(1,:),'LineWidth',2);
% hold on
% for ii = 2:length(T.D)
%     plot(Sim.TimeSteps,powerHist(ii,:),'LineWidth',2);
% end
% title('Power Output')
% ylabel('Power output in W')
% xlabel('Time [s]')
% xlim([0,Sim.TimeSteps(end)])
% ylim([0 inf])
% grid on
% hold off

pause(0.1)

% Turbine Data
%   tl_pos      := [n x 3] vec; [x,y,z] world coord. (can be nx2)
%   tl_D        := [n x 1] vec; Turbine diameter
%   tl_ayaw     := [n x 2] vec; axial induction factor and yaw (world coord.)
%   tl_U        := [n x 2] vec; Wind vector [Ux,Uy] (world coord.)