% Start Online visulization
% Step (1/3)

% Field Limits
fLim_x = fieldLims(:,1)';
fLim_y = fieldLims(:,2)';

%% create a meshgrid for the field coordinates, used by the contour plot
res = 10;
[u_grid_x,u_grid_y] = meshgrid(fLim_x(1):res:fLim_x(2),fLim_y(1):res:fLim_y(2));
u_grid_z = zeros(size(u_grid_x));

%% Create live plot figure
figure(1)
clf
%% creating a cell array to store the rotor graphics
% since the number of rotors changes, there is not one object to delete but
% a varying number.
rotors = cell(length(tl_D),1);

%% Clean up
clear pos res