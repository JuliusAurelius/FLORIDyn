function [op_pos, op_dw, op_u, u_t]=makeStep(op_pos, op_dw, op_ayaw, op_t_id, op_U, chainList, cl_dstr, tl_pos, tl_D, timeStep)
% MAKESTEP calculates all values necessary to propagate the wind field.
%   It calculates the crosswind position of the OPs, the reduction and the
%   foreign influence. With that information the downwind step can be
%   calculated.
%   With the new downwind position comes a new crosswind position. The
%   function returns the vector describing the down- and crosswind movement
%   of all observation points. It also extracts the wind speed at the rotor
%   planes.
% INPUT
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
%   tl_pos      := [m x 3] vec; [x,y,z] world coord. (can be nx2)
%   tl_D        := [m x 1] vec; Turbine diameter
%
% OUTPUT
% op_pos        := [n x 3] vec; [x,y,z] world coord. (can be nx2)
% op_dw         := [n x 1] vec; downwind position
% u_t           := [m x 1] vec; Effective wind speeds at the turbines
%
% SOURCES
% [1] Experimental and theoretical study of wind turbine wakes in yawed
%     conditions - M. Bastankhah and F. Porté-Agel
% [2] Design and analysis of a spatially heterogeneous wake - A. Farrell,
%     J. King et al.
%% Init Variables
op_r = zeros(length(op_dw),1);
op_I = ones(size(op_r))*0.2;               % NEEDS TO BE IMPLEMENTED AS STATE
op_D = tl_D(op_t_id);

% Get variables from the Bastankhah model
[sig_y, sig_z, C_T, Theta, k_y, k_z, x_0] = getBastankhahVars(...
    op_dw, op_ayaw, op_I, op_D);

% For better readability
yaw = op_ayaw(:,2);

%[1] Eq. 7.4
delta = Theta.*x_0./op_D+...            
    Theta/14.7.*sqrt(cos(yaw)./(k_y.*k_z.*C_T)).*...
    (2.9+1.3*sqrt(1-C_T)-C_T).*log(...
    ((1.6+sqrt(C_T)).*...
    (1.6*sqrt((8*sig_y.*sig_z)./(op_D.^2.*cos(yaw))))-sqrt(C_T))./...
    ((1.6-sqrt(C_T)).*...
    (1.6*sqrt((8*sig_y.*sig_z)./(op_D.^2.*cos(yaw))))+sqrt(C_T))...
    );
delta = delta.*op_D;
%% Calculate the crosswind position
op_c = getChainIDforOP(chainList);
threeDim = 1;

if size(op_pos,2)==2
    threeDim = 0;
end
cw_y = 6*sig_y .* cl_dstr(op_c,1)+delta*1;
if threeDim ==1
    cw_z = 6*sig_z .* cl_dstr(op_c,2);
else
    cw_z = zeros(size(cw_y));
end

%% Get the reduction factor
% nearWake / far wake border
nw = (op_dw-x_0)<0;
fw = ~nw;
% far wake
%[1] Eq. 7.1
op_r(fw) = ...
    (1-sqrt(...
    1-C_T(fw).*cos(yaw(fw))./(8*(sig_y(fw).*sig_z(fw)./op_D(fw).^2)))).*...
    exp(-0.5*((cw_y(fw)-delta(fw))./sig_y(fw)).^2).*...
    exp(-0.5*((cw_z(fw))./sig_z(fw)).^2);

% Near wake
% cw position needs to be calculated new since [1] Eq. 7.2 is only valid
% for OPs after the potential core

% sig_y0 and sig_z0
sig_y0 = cos(yaw(nw)).*op_D(nw)/sqrt(8);
sig_z0 = op_D(nw)/sqrt(8);

nw_width_y = (op_D(nw)+(6*sig_y0-op_D(nw)).*op_dw(nw)./x_0(nw));
nw_width_z = (op_D(nw)+(6*sig_z0-op_D(nw)).*op_dw(nw)./x_0(nw));

cw_y(nw) = nw_width_y.*cl_dstr(op_c(nw),1) + delta(nw);
if threeDim ==1
    cw_z(nw) = nw_width_z.*cl_dstr(op_c(nw),2);
end

% Potential core border
phi_pc = atan2(cw_z(nw),cw_y(nw));
r_pc = sqrt(...
    (cos(phi_pc).*op_D(nw)/2).^2 + ...
    (sin(phi_pc).*op_D(nw)/2).^2) .* (1-op_dw(nw)./x_0(nw));
% within potential core with wake center line offset
nw_c = or(sqrt((cw_y(nw)-delta(nw)).^2 + cw_z(nw).^2) < r_pc,op_dw(nw)==0); 
%   stretch to fit whole array and not just selection
nw_c_tall = false(size(nw));
nw_c_tall(nw) = nw_c;

%   Not in the core
nw_nc = and(nw,~nw_c_tall);

% ==================== DEBUGGING PLOTTING =============================== %
p = false;
if p
    figure();
    scatter(op_dw(nw),cw_y(nw)-delta(nw_c_tall));
    hold on
    plot(op_dw(nw),r_pc)
    plot(op_dw(nw),-r_pc)
    plot(op_dw(nw),nw_width_y/2)
    plot(op_dw(nw),-nw_width_y/2)
    scatter(op_dw(nw_c_tall),cw_y(nw_c_tall)-delta(nw_c_tall),'filled')
    title('Near field Bastankhah')
    xlabel('Downwind')
    ylabel('Crosswind')
end
% ======================================================================= %


% width of the transition zone
%   Change here from the paper:
%       [1] suggests to only use sig_y0, but to ensure a smooth transition,
%       sig_z0 has to be calculated as well, since they are only equal for
%       yaw = 0.
s = sqrt(...
    (cos(phi_pc(~nw_c)).*sig_y0(~nw_c)).^2 + ...
    (sin(phi_pc(~nw_c)).*sig_z0(~nw_c)).^2) .* (op_dw(nw_nc)./x_0(nw_nc));
% Issue: s is at the rotor plane 0, points outside of the potential core
% calculate their reduction with [1] Eq.6.13, which divides by s -> NaN

%[1] Eq. 6.13 sqrt(1-C_T) = 1-C_0
%   Altered the equation to work like [1] Eq. 7.1 and give the ratio to the
%   speed drop, rater than the ratio to the effective wind speed
% Core with constant speed
op_r(nw_c_tall) = 1-sqrt(1-C_T(nw_c_tall));
% Outside of the core with recovering speed and wake center line offset
C_0 = 1-sqrt(1-C_T(nw_nc));
op_r(nw_nc) = C_0.*...
    exp(-(...
    sqrt((cw_y(nw_nc)-delta(nw_nc)).^2 + cw_z(nw_nc).^2)...
    -r_pc(~nw_c)).^2./(2*s.^2));
%% Get the foreign influence
% Go through all turbines and use their points in scattered interpolant
r_f = ones(size(op_r)); % == prod((1-r)(1-r)...)

for t = 1:length(tl_D)
    % extract points which belong to the turbine and which are potentially
    % influenced
    t_points = op_t_id == t;
    
    F = scatteredInterpolant(...
        op_pos(t_points,1),...
        op_pos(t_points,2),...
        op_r(t_points),'nearest','none');
    
    r_f_tmp = F(op_pos(~t_points,1:2));
    if isempty(r_f_tmp)
        break;
    end
    r_f_tmp(isnan(r_f_tmp)) = 0;
    r_f(~t_points) = r_f(~t_points).*(1-r_f_tmp);

    % Debug testing
%     figure
%     scatter3(op_pos(~t_points,1),op_pos(~t_points,2),r_f_tmp,40,r_f_tmp,'filled')
%     hold on
%     ind = chainList((chainList(:,4)==1),1) + chainList((chainList(:,4)==1),2);
%     plot(op_pos(ind,1),op_pos(ind,2),'k','LineWidth',2)
%     grid on
end

%% Calculate the downwind step
% Windspeed at every OP WITHOUT own wake (needed for turbine windspeed)
op_u = r_f.*op_U;

% Calculate downwind step and add it to the real world coordinates and
% downwind position
dw_step = (1-op_r).*op_u*timeStep;
op_pos(:,1:2) = op_pos(:,1:2) + dw_step;
op_dw = op_dw + sqrt(dw_step(:,1).^2 + dw_step(:,2).^2);
%% Calculate the new crosswind position
% Get new wake widths
[sig_y, sig_z, C_T, Theta, k_y, k_z, x_0] = getBastankhahVars(...
    op_dw, op_ayaw, op_I, op_D);

delta = Theta.*x_0./op_D+...            
    Theta/14.7.*sqrt(cos(yaw)./(k_y.*k_z.*C_T)).*...
    (2.9+1.3*sqrt(1-C_T)-C_T).*log(...
    ((1.6+sqrt(C_T)).*...
    (1.6*sqrt((8*sig_y.*sig_z)./(op_D.^2.*cos(yaw))))-sqrt(C_T))./...
    ((1.6-sqrt(C_T)).*...
    (1.6*sqrt((8*sig_y.*sig_z)./(op_D.^2.*cos(yaw))))+sqrt(C_T))...
    );
delta = delta.*op_D;

% Apply ratio to get crosswind position
cw_y_new = 6*sig_y .* cl_dstr(op_c,1) + delta*1;

% Calculate the crosswind delta
delta_cw_y = cw_y_new-cw_y;

% Get wind angle 
ang = atan2(op_U(:,2),op_U(:,1));

% Apply y-crosswind step relative to the wind angle
op_pos(:,1) = op_pos(:,1) - sin(ang).*delta_cw_y;
op_pos(:,2) = op_pos(:,2) + cos(ang).*delta_cw_y;

if size(op_pos,2)==3
    % Apply z-crosswind step
    cw_z_new = 6*sig_z .* cl_dstr(op_c,2);
    delta_cw_z = cw_z_new-cw_z;
    op_pos(:,3) = op_pos(:,3) + delta_cw_z;
end

%% Extract the windspeed at the rotorplane
% op_u has all speeds of the OPs, the speed of the first ones of the chains
% need to be weighted summed by the area they represent.
u_t = ones(size(tl_D));

%% Apply own reduction to speed vector
op_u = op_u.*(1-op_r);
end
