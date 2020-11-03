path = '/ValidationData/csv/';

torque = importGenPowerFile([path '2T_00_torque_generatorPower.csv']);
norm = importGenPowerFile([path '2T_00_wps_generatorPower.csv']);

torque(:,2) = torque(:,2)-torque(1,2);
norm(:,2)   = norm(:,2)-norm(1,2);

torque(:,3) = torque(:,3)/1.225;
norm(:,3)   = norm(:,3)/1.225;

avTorque = mean(torque(3001:2:end,3));
avNorm   = mean(norm(1201:2:end,3));
%%
figure
plot(torque(1:2:end,2),torque(1:2:end,3))
hold on
plot(norm(1:2:end,2),norm(1:2:end,3))
plot([300,1000],[avTorque,avTorque],'--')
plot([300,1000],[avNorm,avNorm],'--')
hold off
legend('Data from torque paper * 1.225','Other data','Av. Trq 4.23MW','Av. Other 5.16MW')