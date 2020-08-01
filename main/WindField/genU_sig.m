function [U_x,U_y,pos] = genU_sig(len)


U_free = 13;
% In Deg
phi = [110,110,60,65];
pos = [...
    -100,100;...
    1000,100;...
    -100,2000;...
    1000,2000];

numSensors = size(pos,1);



phi = phi./180*pi;
U_x = ones(len,numSensors).*U_free;
U_y = zeros(len,numSensors);

R =@(p) [cos(p), -sin(p);sin(p),cos(p)];

for i = 1:numSensors
    tmpU = R(phi(i))*[U_x(:,i),U_y(:,i)]';
    U_x(:,i) = tmpU(1,:)';
    U_y(:,i) = tmpU(2,:)';
end
end

