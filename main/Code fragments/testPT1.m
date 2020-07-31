function testPT1()
U_sig = genU_sig(len);


end

function U = PT1(timeStep,U_sig)

deltaT  = 1;     % Hard coded fix
T       = 1;
K       = 1;

U = 1/(T/deltaT + 1)*(K*U_sig(timeStep,:) + T/deltaT*U_sig(timeStep-1,:));
end

function U_sig = genU_sig(len)

U_sig = zeros(len,2);
U_sig(:,1) = 8;

off = 00;
ang = 45;
dur = 1;
delta_phi = linspace(0,ang/180*pi,dur);

R =@(p) [cos(p), -sin(p);sin(p),cos(p)];

for i = 1:length(delta_phi)
    U_sig(off+i,:) = (R(delta_phi(i))*U_sig(off+i,:)')';
end
U_sig(off+length(delta_phi):end,1)=U_sig(off+length(delta_phi),1);
U_sig(off+length(delta_phi):end,2)=U_sig(off+length(delta_phi),2);
end