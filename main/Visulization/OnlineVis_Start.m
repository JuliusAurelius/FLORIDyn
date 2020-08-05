% Start Online visulization
% Step (1/3)

figure(1)
pos = [...
    -100,100;...
    1000,100;...
    -100,2000;...
    1000,2000];
if Dim == 2
    scatter(pos(:,1),pos(:,2),50,[1,0,0;1,0,0;1,0,0;1,0,0],'filled')
else
    scatter3(pos(:,1),pos(:,2),[300,300,300,300],50,[1,0,0;1,0,0;1,0,0;1,0,0],'filled')
end
hold on
axis equal
c = colorbar;
c.Label.String ='Windspeed [m/s]';
c.Limits = [0,10];
xlabel('West-East [m]')
ylabel('South-North [m]')
xlim([-300,2100]);
ylim([-100,2100]);
if Dim == 3
    zlabel('Height [m]')
    zlim([-300,500]);
end
grid on
clear pos

Uq = getWindVec2([ufieldx(:),ufieldy(:)],IR,U_x(1,:),U_y(1,:),uf_n,uf_lims);
q = quiver(ufieldx(:),ufieldy(:),Uq(:,1),Uq(:,2));