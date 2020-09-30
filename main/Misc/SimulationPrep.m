%% Simulation preparation

% Online visulization script (1/2)
if onlineVis
    OnlineVis_Start;
end

% Check if field variables are changing over Simulation time
UangVar = size(U.ang,1)>1;
UabsVar = size(U.abs,1)>1;
IVar    = size(I.val,1)>1;
U_ang   = U.ang(1,:);
U_abs   = U.abs(1,:);
I_val   = I.val(1,:);

% Preparing the console output
fprintf(' ============ FLORIDyn Progress ============ \n');
fprintf(['  Number of turbines  : ' num2str(length(T.D)) '\n']);
dispstat('','init')

% Preallocate the power history
powerHist = zeros(length(T.D),Sim.NoTimeSteps);

% Set free wind speed as starting wind speed for the turbines
T.U = getWindVec4(T.pos, U_abs, U_ang, UF);
T.u = sqrt(T.U(:,1).^2+T.U(:,2).^2);
i = 1; % Maybe needed for Controlle Script
% Set the C_t coefficient for all OPs (otherwise NaNs occur)
ControllerScript;
OP.Ct = T.Ct(OP.t_id);

%% ===================================================================== %%
% = Reviewed: 2020.09.30 (yyyy.mm.dd)                                   = %
% === Author: Marcus Becker                                             = %
% == Contact: marcus.becker.mail@gmail.com                              = %
% ======================================================================= %