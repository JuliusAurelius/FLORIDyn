function [T,fieldLims,Pow,VCtCp] = loadLayout(layout)

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
        
        VCtCp = load('./TurbineData/VCtCp_10MW.mat');
    case 'twoDTU10MW_Maarten'
        % Two DTU 10MW Turbines 
        T_Pos = [400 500 119 178.4;...
            1300 500 119 178.4];
        
        fieldLims = [0 0; 2000 1000];
        
        Pow.eta     = 1.08;     %Def. DTU 10MW
        Pow.p_p     = 1.50;     %Def. DTU 10MW
        
        VCtCp = load('./TurbineData/VCtCp_10MW.mat');
    otherwise
        error('Unknown scenario, no simulation started')
end
T.tl_pos  = T_Pos(:,1:Dim);
T.tl_D    = T_Pos(:,end);
T.tl_ayaw = zeros(length(tl_D),2);
end

