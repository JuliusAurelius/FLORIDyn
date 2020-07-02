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
TurbinePosD = [magic(3),ones(3,1)*160];
D=160;
TurbinePosD = [...
                0 0 90 D;...
                3*D 0 90 D;...
                3*D 6*D 90 D;...
                0 6*D 90 D;...
                3*D 12*D 90 D;...
                0 12*D 90 D];
TurbinePosD = TurbinePosD(1:layout,:);
turbineList = [TurbinePosD, zeros(size(TurbinePosD,1),5)];
end

