function tl_u = getTurbineWindSpeed(op_u,chainList, tl_D)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


% Get indeces of the starting observation points
ind = chainList(:,1) + chainList(:,2);
numT = length(tl_D);

% Get speed of first OPs in chains
all_u = sqrt(op_u(ind,1).^2 + op_u(ind,2).^2);

% Apply weights
all_u = chainList(:,5).*all_u;

% Sum for each turbines and return
tl_u = zeros(numT,1);
for i = 1:numT
    tl_u(i) = sum(all_u(chainList(:,4)==i));
end

end

