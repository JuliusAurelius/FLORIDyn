%Testing the FLORIS wake shape
rec = @(x,b1,b2) (sign(x-b1)-sign(x-b2))*0.5;
x = -200:0.1:200;

plot(x,rec(x,-100,100))