%% Wind field
hmax = 2; % amplitude of the signal
b = 80; % ~the width of the signal in m

a = (1.25*b);
% Source signal
so = @(x) sin(x*2*pi/b);
% weight amplitude of signal
w1 = @(x) cos(x*2*pi/a)*0.5 + 0.5;
% select only mexican hats
w2 = @(x) sign(sin(((x-0.5*a)*2*pi)/(2*a)))*0.5+0.5;
% select only positive ones
w3 = @(x) sign(sin(((x-0.5*a)*2*pi)/(4*a)))*0.5+0.5;

MH_sig =@(x) hmax*so(x).*w1(x).*w2(x).*w3(x);

% Distance has to satisfy Niquist theorem, here 6 times higher frequency is
% used than fastest signal.
distM = b/60;

windDir = 90/180*pi;

D = 178.4;  % Turbine Diameter [m]
nh = 119;   % Nacelle height [m]
dw = 5*D;   % Down wind spcing between the turbines
cw = 3*D;   % Cross wind spacing
dwOff = 2*D;% Offset for the wind field dw direction
cwOff = 3*D;% Offset for the wind field cw direction

numM = ceil((dw+2*dwOff)/distM);
dw_m = linspace(dw+2*dwOff,0,numM)';
cw_m = ones(size(dw_m))*(2*cw+2*cwOff);
posMeas = [dw_m,cw_m*0;dw_m,cw_m];

t = 0; % Time
v = 8; % Velocity of the signal
meas = MH_sig(posMeas(:,1)+v*t);

%% Layout
% Turbine grid
D = 178.4;  % Turbine Diameter [m]
nh = 8;%119;   % Nacelle height [m]
dw = 5*D;   % Down wind spcing between the turbines
cw = 3*D;   % Cross wind spacing
dwOff = 2*D;% Offset for the wind field dw direction
cwOff = 3*D;% Offset for the wind field cw direction
T.pos =[...
    cwOff+0*D dwOff+5*D nh D;... % Top left
    cwOff+0*D dwOff+0*D nh D;... % Bottom left
    cwOff+3*D dwOff+5*D nh D;... % Top center
    cwOff+3*D dwOff+0*D nh D;... % Bottom center
    cwOff+6*D dwOff+5*D nh D;... % Top right
    cwOff+6*D dwOff+0*D nh D... % Bottom right
    ];
T.D = ones(6,1)*D;
T.yaw = ones(6,1)*90/180*pi;
%% Plot
figure(1)
for t = 0:4:1000
    mesh([cw_m*0,cw_m],[dw_m,dw_m],[MH_sig(dw_m+v*t),MH_sig(dw_m+v*t)]+8,...
        'FaceColor','flat')
    hold on
    
    for i_T = 1:length(T.D)
        %Plot circular Rotor
        phi = linspace(0,2*pi);
        r = 1;
        yR = r*cos(phi);
        zR = r*sin(phi);
        yR = yR*D;
        zR = zR*3;
        
        cR = [...
            -sin(T.yaw(i_T)),0;...
            cos(T.yaw(i_T)),0;
            0,1]*[yR;zR];
        
        cR = cR'+T.pos(i_T,1:3);
        plot3(cR(:,1),cR(:,2),cR(:,3),'k','LineWidth',2);
        plot3(...
            [T.pos(i_T,1),T.pos(i_T,1)],...
            [T.pos(i_T,2),T.pos(i_T,2)],...
            [0,T.pos(i_T,3)],...
            'k','LineWidth',1.5);
    end
    
    xlabel('Crosswind  [m]')
    ylabel('Downwind [m]')
    zlabel('Wind speed [m/s]')
    xlim([0,2*cw+2*cwOff])
    ylim([0,dw+2*dwOff])
    zlim([0,12]);
    hold off
    pause(0.1)
end
