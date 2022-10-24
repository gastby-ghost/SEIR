syms t;
f = [t^2+t-1;2*t^2-3];
[x_optimization,f_optimization] = Levenberg_Marquardt_Method(f,5,0.4,2,1.5,(t));
x_optimization = double(x_optimization);
f_optimization = double(f_optimization);
x_optimization
f_optimization

t = -2:0.01:2;
St = (t.^2 + t - 1).^2 + (2.*t.^2 - 3).^2;
figure(1)
plot(t,St);