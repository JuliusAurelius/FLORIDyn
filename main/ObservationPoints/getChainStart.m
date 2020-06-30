function OPs = getChainStart(NumChains, TurbinePosD)
% getChainStart creates starting points of the chains based on the number
% of chains and the turbines
%
% INPUT
% NumChains     := Int
% TurbinePosD   := [nx4] vector, [x,y,z,d] // World coordinates & in m
%
% OUTPUT
% OPs           := [(n*m)x5] m Chain starts [x,y,z,t_id, d] per turbine

% Allocation
OPs = zeros(NumChains*size(TurbinePosD,1),6);

% assign each OP to a turbine (first all OPs from turbine 1, then t2 etc.)
t_ind   = repmat(1:size(TurbinePosD,1),NumChains,1);
t_d     = repmat(TurbinePosD(:,end)',NumChains,1);
c_ind   = repmat((1:NumChains)',size(TurbinePosD,1),1);

OPs(:,4) = t_ind(:);    % Turbine index
OPs(:,5) = t_d(:);      % Turbine diameter
OPs(:,6) = c_ind;       % Chain index


% ========================= TODO ========================= 
% ///////////////////////// Strategy to create points ////
OPs(:,1:3) = ones(NumChains*size(TurbinePosD,1),3);     % TODO Placeholder
% ////////////////////////////////////////////////////////
end