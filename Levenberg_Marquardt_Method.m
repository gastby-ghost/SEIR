function [x_optimization,f_optimization] = Levenberg_Marquardt_Method(f,x0,beta,mu,v,var_x,epsilon)
format long;
%   f：目标函数
%   x0：初始点
%   beta：参数
%   mu：阻尼参数
%   v：放大系数
%   var_x：自变量向量
%   epsilon：精度
%   x_optimization：目标函数取最小值时的自变量值
%   f_optimization：目标函数的最小值
if nargin == 6
    epsilon = 1.0e-2;
end
S = transpose(f)*f;
k = length(f);
n = length(x0);
x0 = transpose(x0);
var_x = transpose(var_x);
grad_f = jacobian(f,var_x);
xk = x0;
dx = 1;
while norm(dx) > epsilon
    fxk = zeros(k,1);
    for i=1:k
        fxk(i,1) = subs(f(i),var_x,xk);   %   【2】
    end
    Sxk = subs(S,var_x,xk);
    grad_fxk = subs(grad_f,var_x,xk);     %   【3】
    grad_Sxk = transpose(grad_fxk)*fxk;   %   【4】
    Q = transpose(grad_fxk)*grad_fxk;       %   【5】
    while 1
        I = eye(size(Q));
        dx = double(-(Q + mu*I)\grad_Sxk);  
        xk_next = xk + dx;                  %   【6】    
        for i=1:k
            fxk_next(i,1) = subs(f(i),var_x,xk_next);
        end
        Sxk_next = subs(S,var_x,xk_next);
        if norm(dx) <= epsilon
            break;
        end
        if Sxk_next >= Sxk + beta*transpose(grad_Sxk)*dx    %   【7】
            mu = v*mu;
            continue;
        else
            mu = mu/v;
            break;
        end
    end
    xk = xk_next;       %   【8】
end
x_optimization = xk;
f_optimization = subs(S,var_x,x_optimization);
format short;