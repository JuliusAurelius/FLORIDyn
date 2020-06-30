function chainList = shiftChainList(chainList)
%   Move the pointer to the next index of the chain, in a manner that
%   it is pointing to the oldest OP, which will now be replaced.
%
% INPUT
% chainList := [n x 4] matrix [offset from start ind to old OP, 
%                   starting ind, chain length, turbine ind]
%
% OUTPUT
% chainList := [n x 4] matrix [offset from start ind to current OP, 
%                   starting ind, chain length, turbine ind]

chainList(:,1) = mod(chainList(:,1) + 1, chainList(:,3));
end