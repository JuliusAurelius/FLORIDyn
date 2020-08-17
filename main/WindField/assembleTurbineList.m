function [tl_pos,tl_D,tl_ayaw,tl_U] = assembleTurbineList(layout,varargin)
%assembleTurbineList creates list of turbines with their properties
%   Sets the number, position, height and diameter, but also stores the yaw
%   and axial induction factor of the controller, along with the current
%   Power output
%
% INPUT
%   layout  := to be defined (probably name or id)
%
% OUTPUT
% Turbine Data
%   tl_pos      := [n x 3] vec; [x,y,z] world coord. (can be nx2)
%   tl_D        := [n x 1] vec; Turbine diameter
%   tl_ayaw     := [n x 2] vec; axial induction factor and yaw (world coord.)
%   tl_U        := [n x 2] vec; Wind vector [Ux,Uy] (world coord.)

Dim = 3;             %<--- 2D / 3D change

%% Code to use varargin values
% function(*normal in*,'var1','val1','var2',val2[numeric])
if nargin>1
    %varargin is used
    for i=1:2:length(varargin)
        %go through varargin which is build in pairs and assign variable
        %stored in the first entry with the value stored in the second
        %entry.
        if isnumeric(varargin{i+1})
            %Value is a number -> for 'eval' a string is needed, so convert
            %num2str
            eval([varargin{i} '=' num2str(varargin{i+1}) ';']);
        else
            %Value is a string, can be used as expected
            stringVar=varargin{i+1};
            eval([varargin{i} '= stringVar;']);
            clear stringVar
        end
    end
end
%%
T_num = 6;
D=160;

T_Pos = [...
                500 0 90 D;... % tmp change
                500 4*D 90 D;...
                500 8*D 90 D;...
                0 6*D 90 D;...
                3*D 12*D 90 D;...
                0 12*D 90 D];
T_D = ones(T_num,1)*D;

tl_pos  = T_Pos(1:layout,1:Dim);
tl_D    = T_D(1:layout,:);
tl_ayaw = zeros(layout,2);
tl_U    = ones(layout,2);

end

%% NEEDS TO BE FILLED WITH PROPER WINDFARMS