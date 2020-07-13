function U_sig = genU_sig(len)

U_sig = zeros(len,2);
U_sig(:,1) = 8;

off = 60;
delta_phi = linspace(0,90/180*pi,90);

R =@(p) [cos(p), -sin(p);sin(p),cos(p)];

for i = 1:length(delta_phi)
    U_sig(off+i,:) = (R(delta_phi(i))*U_sig(off+i,:)')';
end
U_sig(off+length(delta_phi):end,1)=U_sig(off+length(delta_phi),1);
U_sig(off+length(delta_phi):end,2)=U_sig(off+length(delta_phi),2);
end

