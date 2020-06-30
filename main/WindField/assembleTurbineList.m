function turbineList = assembleTurbineList(layout)
%assembleTurbineList creates list of turbines with their properties
%   Sets the number, position, height and diameter, but also stores the yaw
%   and axial induction factor of the controller, along with the current
%   Power output
%
% INPUT
%   layout  := to be defined (probably name or id)
%
%======================== Structure ======================================%
% Turbine list
% [world        world   world  ]
% [x,y,z,   D,  a,yaw,  Ux,Uy P]
% [1,2,3,   4,   5,6     7,8  9]
%=========================================================================%
TurbinePosD = [magic(3),ones(3,1)];
turbineList = [TurbinePosD, zeros(size(TurbinePosD,1),3)];
end

