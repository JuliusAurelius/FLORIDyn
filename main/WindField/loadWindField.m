function [U, I, UF, Sim] = loadWindField(fieldScenario,varargin)
% LOADWINDFIELD Creates the data necessary for the environment
%   Wind variables like speed and direction are set here, as well as air
%   density, resolution of the interpolation grid. The location of the
%   measurement points are set here, ideally they are in a rectangle.
%
% INPUT
%   fieldScenario   := String; Name of the Scenario used for the switch
%                               case below.
%                       'const': Constant wind from an constant angle
%                       '+60DegChange': 60 degree wind direction change 
%                                       after 300s for another 300s.
%
%   varargin        := String,Value: Option to change the value of the 
%                                    default variables.
% --- Var Name -|- Default -|- Explenation ------------------------------ %
% windSpeed     | 8 m/s     | Free wind speed/ starting wind speed
% windAngle     | 0 deg     | Wind direction/ starting wind direction
%               |           | 0  = direction of the x axis
%               |           | 90 = direction of the y axis
% ambTurbulence | 0.06 = 6% | Ambient turbulence intensity
% posMeas       | [0,0; ... | Position of the measurements of the wind
%               | 3000,0;...| speed, angle etc., used for interpolation
%               | 0,3000;...|
%               | 3000,3000]|
% uf_res        | [60,60]   | Grid resolution of the field interpolation,
%               |           | first in x direction, then y direction
% alpha_z       | 0         | factor for atmospheric stability, for values
%               |           | >0 the wind speed closer to the ground is
%               |           | reduced. Diabeled for 0.
%               |           | alpha < 0.2 unstable conditions (turbulent)
%               |           | alpha > 0.2 stable conditions (laminar)
% airDen        |1.225kg/m^3| Air density, for SOWFA at 1.225, can be
%               |           | disabled by setting to 1.
% interpMethod  | 'natural' | Method used for field interpolation. other 
%               |           | Options: 'nearest', 'linear'
% SimDuration   | 1000s     | Duration of the Simulation
% TimeStep      | 4s        | Duration of one time step
% FreeSpeed     | true      | Determines if the OPs travel at free speed or
%               |           | at their own effective wind speed.
% WidthFactor   | 6         | Multiplication factor for the sig_y and sig_z
%               |           | of the gaussian function describing the
%               |           | field. 6 -> the OPs get distributed on 6*sig
% ======================================================================= %
% OUTPUT
%   U           := Struct;    All data related to the wind
%    .abs       := [txn] mat; Absolute value of the wind vector at the n
%                             measurement points for t time steps. If t=1,
%                             the wind speed is constant.
%    .ang       := [txn] mat; Same as .abs, but for the angle of the vector
%    .alpha_z   := double;    Atmospheric stability (see above)
%    .pos       := [nx2] mat; Measurement positions
%    .airDen    := double;    AirDensity
%
%   I           := Struct;    All data connected to the ambient turbulence
%    .val       := [txn] mat; Same as U.abs, but for the turbulence
%                             intensity
%    .pos       := [nx2] mat; Measurement positions (same as wind!)
%
%   UF          := Struct;    Data connected to the (wind) field
%    .lims      := [2x2] mat; Interpolation area
%    .IR        := [mxn] mat; Maps the n measurements to the m grid points
%                             of the interpolated mesh
%    .Res       := [1x2] mat; x and y resolution of the interpolation mesh
%
%   Sim
%    .Duration  := double;    Duration of the Simulation in seconds
%    .TimeStep  := double;    Duration of one time step
%    .TimeSteps := [1xt] vec; All time steps
%    .NoTimeSteps= int;       Number of time steps
%    .FreeSpeed := bool;      OPs traveling with free wind speed or own
%                             speed
%    .WidthFactor= double;    Multiplication factor for the field width
% ======================================================================= %
% = Reviewed: 2020.09.27 (yyyy.mm.dd)                                   = %
% === Author: Marcus Becker                                             = %
% == Contact: marcus.becker.mail@gmail.com                              = %
% ======================================================================= %

%% Default variables
% Wind field data
windSpeed       = 8;        % m/s
windAngle       = 0;        % Degree, will be converted in rad
ambTurbulence   = .06;      % in percent
posMeas         = [0,0;3000,0;0,3000;3000,3000];
uf_res          = [60,60];  % resolution across the field [x,y]
alpha_z         = 0;        % factor for height decrease due to 
                            %   atmospheric stability
                            %     0 = a disabled
                            %   0.2 > a unstable conditions (turbulent)
                            %   0.2 < a stable conditions (laminar)
airDen          = 1.225;    % Air density kg/m^3 (SOWFA)
                            % airDen  = 1.1716; %kg/m^3
interpMethod    = 'natural';% Interpolation method for the wind field
% Simulation data
SimDuration     = 1000;     % in s
TimeStep        = 4;        % in s
FreeSpeed       = true;
WidthFactor     = 6;
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
            stringVar=varargin{i+1}; %#ok<NASGU>
            eval([varargin{i} '= stringVar;']);
            clear stringVar
        end
    end
end

%% Derived variables
measPoints  = size(posMeas,1);
timeSteps   = 0:TimeStep:SimDuration;
NoTimeSteps = length(timeSteps);

%% Simulation constants
Sim.Duration    = SimDuration;
Sim.TimeStep    = TimeStep;
Sim.TimeSteps   = timeSteps;
Sim.NoTimeSteps = NoTimeSteps;
Sim.FreeSpeed   = FreeSpeed;
Sim.WidthFactor = WidthFactor;

%% Wind field
UF.lims = ...
    [max(posMeas(:,1))-min(posMeas(:,1)),max(posMeas(:,2))-min(posMeas(:,2));...
    min(posMeas(:,1)),min(posMeas(:,2))];

[ufieldx,ufieldy] = meshgrid(...
    linspace(min(posMeas(:,1)),max(posMeas(:,1)),uf_res(1)),...
    linspace(min(posMeas(:,2)),max(posMeas(:,2)),uf_res(2)));

UF.IR = createIRMatrix(posMeas,...
    [fliplr(ufieldx(:)')',fliplr(ufieldy(:)')'],interpMethod);
UF.Res = uf_res;

%%
switch fieldScenario
    case 'const'
        % Constant wind along the x axis
        % Wind
        U.abs = ones(1,measPoints)*windSpeed;
        U.ang = ones(1,measPoints)*windAngle/180*pi;
        U.alpha_z = alpha_z;
        % Constant ambient turbulence
        I.val = ones(1,measPoints)*ambTurbulence;
        
        U.pos = posMeas;
        I.pos = posMeas;
    case '+60DegChange'
        % +60 Deg Change after 300s over the next 300s.
        % Two DTU 10MW Turbines 
        U.abs = ones(NoTimeSteps,measPoints).*windSpeed;
        U.ang = ones(size(U.abs)).*windAngle;
        startI = round(300/TimeStep);
        changeAng = linspace(0,60/180*pi,startI);
        
        if 2*startI>NoTimeSteps
            error(['simulation is too short, set SimDuration'...
                ' at least to ' num2str(2*startI*TimeStep) 's.'] ...
                )
        end
        
        U.ang(startI+1:2*startI,:) = U.ang(startI+1:2*startI,:) + changeAng';
        U.ang(2*startI+1:end,:) = U.ang(2*startI+1:end,:) + changeAng(end);
        U.ang = mod(U.ang,2*pi);
        U.alpha_z = alpha_z;
        % Constant ambient turbulence
        I.val = ones(1,measPoints)*ambTurbulence;
        
        U.pos = posMeas;
        I.pos = posMeas;
    otherwise
        error('Unknown wind conditions, no simulation started')
end

U.airDen = airDen;
end