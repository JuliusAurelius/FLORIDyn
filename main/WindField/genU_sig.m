function U_sig = genU_sig(len)

U_sig = zeros(len,2);
U_sig(:,1) = 13;

off = 00;
ang = 90;
dur = 1;
delta_phi = linspace(0,ang/180*pi,dur);

R =@(p) [cos(p), -sin(p);sin(p),cos(p)];

for i = 1:length(delta_phi)
    U_sig(off+i,:) = (R(delta_phi(i))*U_sig(off+i,:)')';
end
U_sig(off+length(delta_phi):end,1)=U_sig(off+length(delta_phi),1);
U_sig(off+length(delta_phi):end,2)=U_sig(off+length(delta_phi),2);
end

