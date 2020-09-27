function [T,fieldLims,Pow,VCtCp,chain] = loadLayout(layout, varargin)
% LOADLAYOUT Creates and loads the data necessary for the wind farm layout
%   Here, the layout of the wind farm, its dimentions and the data of the
%   turbines are set. The different layouts are chosen by a switch case.
%   The switch case might overwrite data which can be set in variargin, so
%   be aware to check for that.
%   In the current version of the code, chains can have different lengths,
%   but it is not possible to change the length during the simulation.
% ======================================================================= %
% INPUT
%   layout      := String; Name of the Scenario used for the switch case.
%                           'nineDTU10MW_Maatren':
%                               9 turbines in a 3x3 grid
%                           'twoDTU10MW_Maarten':
%                               2 turbines behind each other
%
%   varargin    := String,Value: Option to change the value of the 
%                                    default variables.
% --- Var Name -|- Default -|- Explenation ------------------------------ %
% ChainLength   | 200 OPs   | Number of Observation points in a chain
% NumChains     | 100       | Number of chains per wind turbine
% ======================================================================= %
% OUTPUT
%   T           := Struct;    All data related to the turbines
%    .pos       := [nx3] mat; x & y positions and nacelle height for all n
%                             turbines.
%    .D         := [nx1] vec; Diameter of all n turbines
%    .yaw       := [nx1] vec; Yaw setting of the n turbines    (Allocation)
%    .Ct        := [nx1] vec; Current Ct of the n turbines     (Allocation)
%    .Cp        := [nx1] vec; Current Cp of the n turbines     (Allocation)
%
%   fieldLims   := [2x2] mat; limits of the wind farm area (must not be the
%                             same as the wind field!)
%
%   Pow         := Struct;    All data related to the power calculation
%    .eta       := double;    Efficiency of the used turbine
%    .p_p       := double;    cos(yaw) exponent for power calculation 
%
%   VCtCp       := [nx3];     Wind speed to Ct & Cp mapping
%                               (Only used by controller script)
%
%   chain       := Struct;    Data related to the OP management / chains
%    .NumChains := int;       Number of Chains per turbine
%    .Length    := int/[nx1]; Length of the Chains - either uniform for all
%                             chains or individually set for every chain.
% ======================================================================= %
% = Reviewed: 2020.09.27 (yyyy.mm.dd)                                   = %
% === Author: Marcus Becker                                             = %
% == Contact: marcus.becker.mail@gmail.com                              = %
% ======================================================================= %
%% Default variables
% Observation Point data
ChainLength     = 200;      % OPs per chain
NumChains       = 100;       % Chains per turbine

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

%%
switch layout
    case 'nineDTU10MW_Maatren'
        % Nine DTU 10MW turbines in a 3x3 grid positioned with 900m
        % distance. 
        T_Pos = [...
            600  600  119 178.4;...     % T0
            1500 600  119 178.4;...     % T1
            2400 600  119 178.4;...     % T2
            600  1500 119 178.4;...     % T3
            1500 1500 119 178.4;...     % T4
            2400 1500 119 178.4;...     % T5
            600  2400 119 178.4;...     % T6
            1500 2400 119 178.4;...     % T7
            2400 2400 119 178.4;...     % T8
            ]; 
        
        fieldLims = [0 0; 3000 3000];
        
        Pow.eta     = 1.08;     %Def. DTU 10MW
        Pow.p_p     = 1.50;     %Def. DTU 10MW
        
        % Get VCtCp
        load('./TurbineData/VCtCp_10MW.mat');
    case 'twoDTU10MW_Maarten'
        % Two DTU 10MW Turbines 
        T_Pos = [400 500 119 178.4;...
            1300 500 119 178.4];
        
        fieldLims = [0 0; 2000 1000];
        
        Pow.eta     = 1.08;     %Def. DTU 10MW
        Pow.p_p     = 1.50;     %Def. DTU 10MW
        
        % Get VCtCp
        load('./TurbineData/VCtCp_10MW.mat');
        
        ChainLength = [ones(NumChains,1)*120;ones(NumChains,1)*10];   
    otherwise
        error('Unknown scenario, no simulation started')
end
T.pos  = T_Pos(:,1:3); % 1:Dim
T.D    = T_Pos(:,end);
T.yaw  = zeros(length(T.D),1);
T.Ct   = zeros(length(T.D),1);
T.Cp   = zeros(length(T.D),1);
%% Store chain configuration
chain.NumChains = NumChains;
chain.Length    = ChainLength;
end

