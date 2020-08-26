
if i>1
    delete(p)
    delete(q)
end

%% Plot the OPs
subplot(2,1,1)
hold on
u_l = min(sqrt(sum(op_u.^2,2)));
%ff = sqrt(sum(op_u.^2,2))>(u_l*1.2)*0;
if Dim==2
    u_max = 20;
    slow = sqrt(sum(op_u.^2,2))<u_max;
    p = scatter3(op_pos_old(slow,1),op_pos_old(slow,2),sqrt(sum(op_u(slow,:).^2,2)),...
        ones(size(op_t_id(slow)))*40,sqrt(sum(op_u(slow,:).^2,2)),...
        'filled');
else
    p = scatter3(op_pos_old(:,1),op_pos_old(:,2),op_pos_old(:,3),...
        ones(size(op_t_id(:)))*20,sqrt(sum(op_u.^2,2)),...
        'filled');
end
Uq = getWindVec3([ufieldx(:),ufieldy(:)],IR, U_abs(i,:), U_ang(i,:), uf_n, uf_lims);
q = quiver(ufieldx(:),ufieldy(:),Uq(:,1),Uq(:,2),'Color',[0.5,0.5,0.5]);


c = colorbar;
c.Label.String ='Windspeed [m/s]';
c.Limits = [0,13];
xlabel('West-East [m]')
ylabel('South-North [m]')
xlim(fLim_x);
ylim(fLim_y);
if Dim == 3
    zlabel('Height [m]')
    zlim([-300,500]);
end
grid on

%% Plot the rotors
for i_T = 1:length(tl_D)
    if i>1
        delete(rotors{i_T});
    end
    % Get start and end of the turbine rotor
    rot_pos = ...
        [cos(tl_ayaw(i_T,2)), -sin(tl_ayaw(i_T,2));...
        sin(tl_ayaw(i_T,2)), cos(tl_ayaw(i_T,2))] * ...
        [0,0;tl_D(i_T)/2,-tl_D(i_T)/2];
    rot_pos = rot_pos + tl_pos(i_T,1:2)';
    rotors{i_T} = plot3(rot_pos(1,:),rot_pos(2,:),[20,20],'k','LineWidth',3);
end

%% Plot the Power Output
subplot(2,1,2)
plot(powerHist(1,:),'LineWidth',2);
hold on
for ii = 2:NumTurbines
    plot(powerHist(ii,:),'LineWidth',2);
end
title('Power Output')
ylabel('Power output in W')
xlabel('time step')
xlim([0,NoTimeSteps])
grid on
hold off

pause(0.1)

% Turbine Data
%   tl_pos      := [n x 3] vec; [x,y,z] world coord. (can be nx2)
%   tl_D        := [n x 1] vec; Turbine diameter
%   tl_ayaw     := [n x 2] vec; axial induction factor and yaw (world coord.)
%   tl_U        := [n x 2] vec; Wind vector [Ux,Uy] (world coord.)