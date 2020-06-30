function r = getR_f(OPs)
% getR_f calculates the reduction influence of other OPs/wakes and
% multiplies it to the natural wake reduction
%
% INPUT
% OPs           := [n x 4] vector [x,y,z,r] in World coordinates
%
% OUTPUT
% r             := [n x 1] vector reduction factor
%

% ==================== !!!!DUMMY METHOD!!!! ====================== % 
% ================= should link to wake models =================== %

r = OPs(:,4).*zeros(size(OPs,1),1);
end