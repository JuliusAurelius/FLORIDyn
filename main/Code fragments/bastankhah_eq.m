%% Build bastankhah as one equation
%% set symbolic variables
syms x y z a yaw d I z_h u_free  % Changing
syms alpha beta k_y k_z % Constants
%%
%C_T
C_T = 4*a*(1-a*cos(yaw));

% Potential core
x_0 = cos(yaw)*(1+sqrt(1-C_T))/(sqrt(2)*(alpha*I+beta*(1-sqrt(1-C_T))));

% Far field width
sig_y = (k_y*(x-x_0)/d + cos(yaw)/sqrt(8))*d;
sig_z = (k_z*(x-x_0)/d + 1/sqrt(8))*d;

% Angle theta
theta = 0.3*yaw/cos(yaw)*(1-sqrt(1-C_T*cos(yaw)));

% Deflection
%   help parts
h01 = 1.6*sqrt(8*sig_y*sig_z/(d^2*cos(yaw)));
delta = (theta*x_0/d+theta/14.7*sqrt(cos(yaw)/(k_z*k_y*C_T))...
    *(2.9+1.3*sqrt(1-C_T)-C_T)*log(...
    ((1.6+sqrt(C_T))*(h01-sqrt(C_T)))/...
    ((1.6-sqrt(C_T))*(h01+sqrt(C_T)))))*d;

% Reduction far wake
r = (1-sqrt(1-(C_T*cos(yaw)/(8*(sig_y*sig_z/d^2)))))*...
    exp(-0.5*((y-delta)/sig_y)^2)*...
    exp(-0.5*((z-z_h)/sig_z)^2);

% Far wake wind speed
u_f = (1-r)*u_free;

%u_f = simplify(u_f);
%latex(u_f)
%{
'u_{\mathrm{free}}\,\left({\mathrm{e}}^{-\frac{{\left(y+d\,\left(\frac{\mathrm{yaw}\,\ln\left(\frac{\left(2\,\sqrt{-a\,\left(a\,\cos\left(\mathrm{yaw}\right)-1\right)}-\frac{16\,\sqrt{2}\,\sqrt{\frac{\left(\frac{\sqrt{2}\,\cos\left(\mathrm{yaw}\right)}{4}+\frac{k_{y}\,\left(x-\frac{\sqrt{2}\,\cos\left(\mathrm{yaw}\right)\,\left(\sqrt{4\,a\,\left(a\,\cos\left(\mathrm{yaw}\right)-1\right)+1}+1\right)}{2\,\left(I\,\alpha -\beta \,\left(\sqrt{4\,a\,\left(a\,\cos\left(\mathrm{yaw}\right)-1\right)+1}-1\right)\right)}\right)}{d}\right)\,\left(\frac{\sqrt{2}}{4}+\frac{k_{z}\,\left(x-\frac{\sqrt{2}\,\cos\left(\mathrm{yaw}\right)\,\left(\sqrt{4\,a\,\left(a\,\cos\left(\mathrm{yaw}\right)-1\right)+1}+1\right)}{2\,\left(I\,\alpha -\beta \,\left(\sqrt{4\,a\,\left(a\,\cos\left(\mathrm{yaw}\right)-1\right)+1}-1\right)\right)}\right)}{d}\right)}{\cos\left(\mathrm{yaw}\right)}}}{5}\right)\,\left(2\,\sqrt{-a\,\left(a\,\cos\left(\mathrm{yaw}\right)-1\right)}+\frac{8}{5}\right)}{\left(2\,\sqrt{-a\,\left(a\,\cos\left(\mathrm{yaw}\right)-1\right)}+\frac{16\,\sqrt{2}\,\sqrt{\frac{\left(\frac{\sqrt{2}\,\cos\left(\mathrm{yaw}\right)}{4}+\frac{k_{y}\,\left(x-\frac{\sqrt{2}\,\cos\left(\mathrm{yaw}\right)\,\left(\sqrt{4\,a\,\left(a\,\cos\left(\mathrm{yaw}\right)-1\right)+1}+1\right)}{2\,\left(I\,\alpha -\beta \,\left(\sqrt{4\,a\,\left(a\,\cos\left(\mathrm{yaw}\right)-1\right)+1}-1\right)\right)}\right)}{d}\right)\,\left(\frac{\sqrt{2}}{4}+\frac{k_{z}\,\left(x-\frac{\sqrt{2}\,\cos\left(\mathrm{yaw}\right)\,\left(\sqrt{4\,a\,\left(a\,\cos\left(\mathrm{yaw}\right)-1\right)+1}+1\right)}{2\,\left(I\,\alpha -\beta \,\left(\sqrt{4\,a\,\left(a\,\cos\left(\mathrm{yaw}\right)-1\right)+1}-1\right)\right)}\right)}{d}\right)}{\cos\left(\mathrm{yaw}\right)}}}{5}\right)\,\left(2\,\sqrt{-a\,\left(a\,\cos\left(\mathrm{yaw}\right)-1\right)}-\frac{8}{5}\right)}\right)\,\left(\sqrt{4\,a\,\cos\left(\mathrm{yaw}\right)\,\left(a\,\cos\left(\mathrm{yaw}\right)-1\right)+1}-1\right)\,\left(\frac{13\,\sqrt{4\,a\,\left(a\,\cos\left(\mathrm{yaw}\right)-1\right)+1}}{10}+4\,a\,\left(a\,\cos\left(\mathrm{yaw}\right)-1\right)+\frac{29}{10}\right)\,\sqrt{-\frac{\cos\left(\mathrm{yaw}\right)}{4\,a\,k_{y}\,k_{z}\,\left(a\,\cos\left(\mathrm{yaw}\right)-1\right)}}}{49\,\cos\left(\mathrm{yaw}\right)}+\frac{3\,\sqrt{2}\,\mathrm{yaw}\,\left(\sqrt{4\,a\,\cos\left(\mathrm{yaw}\right)\,\left(a\,\cos\left(\mathrm{yaw}\right)-1\right)+1}-1\right)\,\left(\sqrt{4\,a\,\left(a\,\cos\left(\mathrm{yaw}\right)-1\right)+1}+1\right)}{20\,d\,\left(I\,\alpha -\beta \,\left(\sqrt{4\,a\,\left(a\,\cos\left(\mathrm{yaw}\right)-1\right)+1}-1\right)\right)}\right)\right)}^2}{2\,d^2\,{\left(\frac{\sqrt{2}\,\cos\left(\mathrm{yaw}\right)}{4}+\frac{k_{y}\,\left(x-\frac{\sqrt{2}\,\cos\left(\mathrm{yaw}\right)\,\left(\sqrt{4\,a\,\left(a\,\cos\left(\mathrm{yaw}\right)-1\right)+1}+1\right)}{2\,\left(I\,\alpha -\beta \,\left(\sqrt{4\,a\,\left(a\,\cos\left(\mathrm{yaw}\right)-1\right)+1}-1\right)\right)}\right)}{d}\right)}^2}}\,{\mathrm{e}}^{-\frac{{\left(z-z_{h}\right)}^2}{2\,d^2\,{\left(\frac{\sqrt{2}}{4}+\frac{k_{z}\,\left(x-\frac{\sqrt{2}\,\cos\left(\mathrm{yaw}\right)\,\left(\sqrt{4\,a\,\left(a\,\cos\left(\mathrm{yaw}\right)-1\right)+1}+1\right)}{2\,\left(I\,\alpha -\beta \,\left(\sqrt{4\,a\,\left(a\,\cos\left(\mathrm{yaw}\right)-1\right)+1}-1\right)\right)}\right)}{d}\right)}^2}}\,\left(\sqrt{\frac{a\,\cos\left(\mathrm{yaw}\right)\,\left(a\,\cos\left(\mathrm{yaw}\right)-1\right)}{2\,\left(\frac{\sqrt{2}\,\cos\left(\mathrm{yaw}\right)}{4}+\frac{k_{y}\,\left(x-\frac{\sqrt{2}\,\cos\left(\mathrm{yaw}\right)\,\left(\sqrt{4\,a\,\left(a\,\cos\left(\mathrm{yaw}\right)-1\right)+1}+1\right)}{2\,\left(I\,\alpha -\beta \,\left(\sqrt{4\,a\,\left(a\,\cos\left(\mathrm{yaw}\right)-1\right)+1}-1\right)\right)}\right)}{d}\right)\,\left(\frac{\sqrt{2}}{4}+\frac{k_{z}\,\left(x-\frac{\sqrt{2}\,\cos\left(\mathrm{yaw}\right)\,\left(\sqrt{4\,a\,\left(a\,\cos\left(\mathrm{yaw}\right)-1\right)+1}+1\right)}{2\,\left(I\,\alpha -\beta \,\left(\sqrt{4\,a\,\left(a\,\cos\left(\mathrm{yaw}\right)-1\right)+1}-1\right)\right)}\right)}{d}\right)}+1}-1\right)+1\right)'
%}