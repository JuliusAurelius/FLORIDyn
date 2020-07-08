function [] = main()

addpath('./WindField')
addpath('./Controller')
addpath('./ObservationPoints')
addpath('./WakeModel')

%% Test Variables
NumChains       = 60;
NumTurbines     = 1;

% Uniform chain length or individual chainlength
%chainLength     = randi(20,NumChains*NumTurbines,1)+1;
chainLength = 80;   

timeStep        = 5;   % in s
SimDuration     = 1000; % in s

Dim = 3;

%% Derived Variables
timeSteps   = 0:timeStep:SimDuration;
NoTimeSteps = length(timeSteps);

% Create the list of turbines with their properties
[tl_pos,tl_D,tl_ayaw,tl_U] = assembleTurbineList(NumTurbines,'Dim',Dim);               % TODO should call layout

%% Create starting OPs and build opList
[op_pos, op_dw, op_r, op_U, op_ayaw, op_t_id, chainList, cl_dstr] =...
    assembleOPList(NumChains,chainLength,tl_D,'sunflower',Dim);

%% Start simulation

for i = 1:NoTimeSteps
    % Update Turbine data to get controller input
    tl_U    = getWindVec(tl_pos);
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
    op_U    = getWindVec(op_pos);
    
    
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
    cw_old = tmp_get_cw(op_dw, op_ayaw, op_t_id, tl_D, cl_dstr, chainList);
    op_dw = op_dw + sqrt(dw_step(:,1).^2 + dw_step(:,2).^2); % NOT TMP
    cw_new = tmp_get_cw(op_dw, op_ayaw, op_t_id, tl_D, cl_dstr, chainList);
    
    delta_cw = cw_new-cw_old;
    ang = atan2(op_U(:,2),op_U(:,1));
    op_pos(:,1) = op_pos(:,1) - sin(ang).*delta_cw(:,1);
    op_pos(:,2) = op_pos(:,2) + cos(ang).*delta_cw(:,1);
    if Dim == 3
        op_pos(:,3) = op_pos(:,3) + delta_cw(:,2);
    end
    % FUNCTION TO IMPLEMENT
    % get cw out of relative distribution and dw position 
    %   -> Used here to update y_w and z_w and maybe by getR
    
    % Prepare next time step
    % set r_t = r_f for the chain starting points
    ind = chainList(:,1) + chainList(:,2);
    op_r(ind,2) = r_f(ind);
    % Increment the index of the chain starting entry
    chainList = shiftChainList(chainList);
    
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

%% PLOT

% World coordinates
figure(1)
if size(op_pos,2) == 3 % Dimentions
    scatter3(op_pos(:,1),op_pos(:,2),op_pos(:,3),...
    ones(size(op_t_id))*10,sqrt(sum((op_U.*op_r(:,1)).^2,2)),...
    'filled');
    zlabel('height [m]')
else
    scatter(op_pos(:,1),op_pos(:,2),...
    ones(size(op_t_id))*20,sqrt(sum((op_U.*op_r(:,1)).^2,2))+op_U(:,2)*0.5,...
    'filled');
end

axis equal
colormap parula
c = colorbar;
c.Label.String = 'Windspeed in m/s';
%title(['Proof of concept: wind speed and direction change, ' num2str(length(tl_D)) ' turbines'])
title(['Proof of concept: Simple wake model, 60 chains with 80 observation points'])
xlabel('east - west [m]')
ylabel('south - north [m]')
grid on
end

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
% [x] Include all 3 linked lists: OP[... t_id], chain[OP_entry, start_ind,
%       length, t_id], turbines[...] (chain currently missing)
% [x] Implement shifting the pointers
% [~] Implement the effective yaw calculation
% [x] Which Information is needed to place new initial OPs?
% [x] Add [word_coord. wake_coord. ...] system to OP list
% [ ] Refine getR(), working alpha version (Park Model?) / define Interface
% [x] Refactor code: Move functions to own files.
% [ ] Calc / Set Chainlength (?)
% [x] Set yaw in opList to wake coord.!
% [ ] Visulization / Video
% [ ] Power Output
% [ ] Get one version of r_f working
% [x] 2D implementation