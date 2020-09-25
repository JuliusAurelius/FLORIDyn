function [U, I] = loadWindField(fieldScenario,varargin)

windSpeed       = 8;        % m/s
windAngle       = 0;        % Degree, will be converted in rad
ambTurbulence   = .06;      % in percent
SimDuration     = 1000;     % in s
timeStep        = 4;        % in s
posMeas         = [0,0;3000,0;0,3000;3000,3000];
alpha_z         = 0;        % factor for height decrease due to 
                            %   atmospheric stability
                            %     0 = a disabled
                            %   0.2 > a unstable conditions (turbulent)
                            %   0.2 < a stable conditions (laminar)
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
measPoints  = size(posMeas,1);
timeSteps   = 0:timeStep:SimDuration;
NoTimeSteps = length(timeSteps);
%%
switch fieldScenario
    case 'const'
        % Constant wind along the x axis
        % Wind
        U.abs = ones(measPoints,1)*windSpeed;
        U.ang = ones(measPoints,1)*windAngle/180*pi;
        U.alpha_z = alpha_z;
        % Constant ambient turbulence
        I.val = ones(measPoints,1)*ambTurbulence;
        
        U.pos = posMeas;
        I.pos = posMeas;
    case '+60DegChange'
        % +60 Deg Change after 300s over the next 300s.
        % Two DTU 10MW Turbines 
        U.abs = ones(NoTimeSteps,measPoints).*windSpeed;
        U.ang = ones(size(U.abs)).*windAngle;
        startI = round(300/timeStep);
        changeAng = linspace(0,60/180*pi,startI);
        
        if 2*startI>NoTimeSteps
            error(['simulation is too short, set SimDuration'...
                ' at least to ' num2str(2*startI*timeStep) 's.'] ...
                )
        end
        
        U.ang(startI+1:2*startI,:) = U.ang(startI+1:2*startI,:) + changeAng';
        U.ang(2*startI+1:end,:) = U.ang(2*startI+1:end,:) + changeAng(end);
        U.ang = mod(U.ang,2*pi);
        U.alpha_z = alpha_z;
        % Constant ambient turbulence
        I.val = ones(measPoints,1)*ambTurbulence;
        
        U.pos = posMeas;
        I.pos = posMeas;
    otherwise
        error('Unknown wind conditions, no simulation started')
end
end