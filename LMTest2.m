t=[1 2 4 5 8]';
y=[3.2939 4.2699 7.1749 9.3008 20.259]';
syms p_1 p_2;
f=p_1*exp(p_2*t)-y;
[x_optimization,f_optimization] = Levenberg_Marquardt_Method(f,[0,0],0.4,2,1.5,[p_1,p_2]);
x_optimization
f_optimization