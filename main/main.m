function [] = main()

addpath('./WindField')
addpath('./Controller')
addpath('./ObservationPoints')
addpath('./WakeModel')
addpath('./Visulization')

%% Test Variables
NumChains       = 20;
NumTurbines     = 4;

% Uniform chain length or individual chainlength
%chainLength     = randi(20,NumChains*NumTurbines,1)+1;
chainLength = 100;   

timeStep        = 8;   % in s
SimDuration     = 3000; % in s

Dim = 2;

%% Derived Variables
timeSteps   = 0:timeStep:SimDuration;
NoTimeSteps = length(timeSteps);

% Create the list of turbines with their properties
[tl_pos,tl_D,tl_ayaw,tl_U] = assembleTurbineList(NumTurbines,'Dim',Dim);               % TODO should call layout

%% Get Wind Vector
U_sig = genU_sig(NoTimeSteps);

%% Create starting OPs and build opList
[op_pos, op_dw, op_r, op_U, op_ayaw, op_t_id, chainList, cl_dstr] =...
    assembleOPList(NumChains,chainLength,tl_D,'sunflower',Dim);

%% Start simulation
% Online visulization script (1/3)
% OnlineVis_Start;

for i = 1:NoTimeSteps
    % Online visulization script (2/3)
    % OnlineVis_deletePoints;
    
    % Update Turbine data to get controller input
    tl_U    = getWindVec(tl_pos,i,U_sig);
    %====================== CONTROLLER ===================================%
    tl_ayaw = controller(tl_pos,tl_D,tl_ayaw,tl_U);
    %=====================================================================%
    
    % Insert new points
    [op_pos, op_dw, op_r, op_ayaw] = ...
        initAtRotorPlane(...
        op_pos, op_dw, op_ayaw, op_r, op_t_id, chainList,...
        cl_dstr, tl_pos, tl_D, tl_ayaw, tl_U);
    
    % _____________________ Increment ____________________________________%
    % Update wind dir and speed
    op_U    = getWindVec(op_pos,i,U_sig);
    
    % Calculate the down and crosswind steps along with the windspeed at
    % the turbine rotor planes
    [delta_dw, delta_cw, u_t]=makeStep(...
        op_pos, op_dw, op_ayaw, op_t_id, op_U, chainList, cl_dstr, tl_pos, tl_D);
    
    
    %====================== REPLACED BY 'MAKESTEP' =======================%
    % Get r-> u=U*r (NOT u=U(1-r)!!!)
    op_r(:,1) = getR(op_dw, op_ayaw, op_t_id, tl_D, chainList, cl_dstr);
    
    % Get r_f, foreign influence / wake interaction u=U*r*r_f
    r_f = getR_f(...
        op_pos, op_dw, op_r, op_ayaw, op_t_id, chainList, cl_dstr, tl_pos, tl_D);
    op_r(:,1) = op_r(:,1).*r_f;
    
    % Calculate effective windspeed and down wind step d_dw=U*r_g*r_t*t
    dw_step = op_U.*op_r(:,1).*op_r(:,2)*timeStep;
    
    %   ... in world coordinates
    op_pos(:,1:2) = op_pos(:,1:2) + dw_step;
    %   ... in wake coordinates
    % ------------------------ tmp fix start ---------------------------- %
    % Fix to have the wake expand, previously, only down wind steps were
    % applied, but no crosswind direction. The getR function should supply
    % this information since it already calculates the crosswind position
    % of each OP. The function can then also apply the deflection.
    cw_old = tmp_get_cw(op_dw, op_ayaw, op_t_id, tl_D, cl_dstr, chainList);
    op_dw = op_dw + sqrt(dw_step(:,1).^2 + dw_step(:,2).^2); % NOT TMP
    cw_new = tmp_get_cw(op_dw, op_ayaw, op_t_id, tl_D, cl_dstr, chainList);
    
    %tmp fix for expansion
    delta_cw = cw_new-cw_old; 
    ang = atan2(op_U(:,2),op_U(:,1));
    op_pos(:,1) = op_pos(:,1) - sin(ang).*delta_cw(:,1);
    op_pos(:,2) = op_pos(:,2) + cos(ang).*delta_cw(:,1);
    if Dim == 3
        op_pos(:,3) = op_pos(:,3) + delta_cw(:,2);
    end
    % ------------------------ tmp fix END ------------------------------ %
    % FUNCTION TO IMPLEMENT
    % get cw out of relative distribution and dw position 
    %   -> Used here to update y_w and z_w and maybe by getR
    
    % Prepare next time step
    % set r_t = r_f for the chain starting points
    ind = chainList(:,1) + chainList(:,2);
    op_r(ind,2) = r_f(ind);
    %=================== REPLACED BY 'MAKESTEP' END ======================%
    
    % Apply the calculated step changes
    op_pos = applyStep(op_pos, op_U, delta_dw, delta_cw);
    
    % Increment the index of the chain starting entry
    chainList = shiftChainList(chainList);
    
    % Online visulization script (3/3)
    % OnlineVis_plot;
end
hold off

%% PLOT
%PostSimVis;
end

%% Variables

% OP Data
%   op_pos      := [n x 3] vec; [x,y,z] world coord. (can be nx2)
%   op_dw       := [n x 1] vec; downwind position
%   op_r        := [n x 2] vec; [r_own, r_turbine]
%   op_ayaw     := [n x 2] vec; axial induction factor and yaw (wake coord.)
%   op_t_id     := [n x 1] vec; Turbine op belongs to
%   op_U        := [n x 2] vec; Uninfluenced wind vector at OP position
%
% Chain Data
%   chainList   := [n x 1] vec; (see at the end of the function)
%   cl_dstr     := [n x 1] vec; Distribution relative to the wake width
%
% Turbine Data
%   tl_pos      := [n x 3] vec; [x,y,z] world coord. (can be nx2)
%   tl_D        := [n x 1] vec; Turbine diameter
%   tl_ayaw     := [n x 2] vec; axial induction factor and yaw (world coord.)
%   tl_U        := [n x 2] vec; Wind vector [Ux,Uy] (world coord.)


%% Dummy to get the crosswind pos
function cw = tmp_get_cw(op_dw, op_ayaw, op_t_id, tl_D, cl_dstr, chainList)
m_em = 1;
k_e = 0.0963;

op_D = tl_D(op_t_id);
% Step 1: Calculate the filed width at any point in the wake
% D+2*k_e*me_field
fieldWidth = op_D + 2*k_e*m_em*op_dw;

% Step 2: With the width, the crosswind position of the points can be
% calculated
op_c = getChainIDforOP(chainList);
cw = fieldWidth .* cl_dstr(op_c,:); %independet from centerline

% Add centerline. Unfortunately the architecture currently does not allow a
% wake offset, so the wake is made bigger to contain the deflection part.
% Downside of this is, that there are unneccesary points in the wake.
centerline = c_line(op_dw,op_ayaw,op_D);
cw(:,1) = cw(:,1) + ...
    2*centerline.*cl_dstr(op_c,1);
end

function op_c = getChainIDforOP(chainList)
% A for loop :(
op_c = zeros(sum(chainList(:,3)),1);
for i = 1:size(chainList,1)-1
    op_c(chainList(i,2):chainList(i+1,2)-1) = i;
end
op_c(chainList(end,2):end)=size(chainList,1);
end

function c_lin = c_line(op_dw,op_ayaw,op_D)
% CENTERLINE CALCULATION

%========= Deflection Constants==============#
k_d = 0.15;
a_d = -4.5;
xi_init = pi/180 * 1.5;

C_T = xi_init + 0.5*cos(op_ayaw(:,2)).^2.*sin(op_ayaw(:,2))*4.*...
    op_ayaw(:,1).*(1-op_ayaw(:,1));
k_x_D = 2*k_d*op_dw./op_D+1;

c_lin = C_T.*(15*k_x_D.^4+C_T.^2)./((30*k_d*k_x_D.^5)./op_D)-...
    C_T.*op_D.*(15+C_T.^2)/(30*k_d) + a_d;
end
%% TICKETS
% [ ] Get rid of temporary fix of the wake expansion
% [ ] Implement Bastankhah
% [ ] Implement a wind grid for nearest neighbour interpolation
%       [ ] Test if own interpolation (coord. -> index) is faster
% [ ] Implement wake interaction
% [ ] Disable r_T
% [ ] Calculate Power Output
% [ ] See if it can be formulated as observer or similar
% [ ] Get one version of r_f working
% [ ] Calc / Set Chainlength (?)