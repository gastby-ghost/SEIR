%读取表格数据
Diagnose = DiagnoseRead('Diagnose.xlsx','ods_sjkfds_zsj_daily_confirmed_',[2, 78]);
Flow = FlowRead('Flow.xlsx','Sheet1',2,29);
%生成考虑的时间段
t=datetime(2020,1,1):datetime(2020,3,28);
IActual=zeros(1,length(t));
IActual_sum=zeros(1,length(t));
In=zeros(1,length(t));
Out=zeros(1,length(t));
%初步读取数据
for i=1:length(t)
    if find(Diagnose.Time==t(i))
        IActual(i)=Diagnose.New_confirmed(Diagnose.Time==t(i));
        IActual_sum(i)=Diagnose.Cumulative(Diagnose.Time==t(i));
    end
    if find(Flow.Date==t(i))
        In(i)=Flow.Inflow(Flow.Date==t(i));
        Out(i)=Flow.Outflow(Flow.Date==t(i));
    end
    if(IActual(i)==0)
        IActual(i)=1;
    end
end
%清理数据
IActual_sum(1)=IActual(1);
for i=2:length(IActual_sum)
    if(IActual_sum(i)==0)
        IActual_sum(i)=IActual_sum(i-1);
    end
end
%时间分段
TFlag1=datetime(2020,1,30);TFlag2=datetime(2020,2,8);
%通过差分方程计算理论值--实际上是方程向量
syms beta1 beta2 beta3;
S=sym("i",[1 length(t)]);E=sym("i",[1 length(t)]);I=sym("i",[1 length(t)]);R=sym("i",[1 length(t)]);N=sym("i",[1 length(t)]);
E(1)=1;I(1)=1;R(1)=6;N(1)=13648900;S(1)=N(1);
ISum=sym("i",[1 length(t)]);
alpha=1/5.2;gamma=1/10;
%时间段1
for i=2:length(find(t<=TFlag1))
    E(i)=vpa(simplify(E(i-1)+beta1*I(i-1)-alpha*E(i-1)-Out(i-1)*E(i-1)/(S(i-1)+10000)),6);
    I(i)=vpa(simplify(I(i-1)+alpha*E(i-1)-gamma*I(i-1)),6);
    R(i)=vpa(simplify(R(i-1)+gamma*I(i-1)),6);
    N(i)=vpa(simplify(N(i-1)+In(i-1)-Out(i-1)),6);
    S(i)=vpa(N(i));
end
for i=1:length(find(t<=TFlag1))
    ISum(i)=sum(I(1:i));
end
f=power(I(1:length(find(t<=TFlag1)))-IActual(1:length(find(t<=TFlag1))),2);
[x_optimization,~] = Levenberg_Marquardt_Method(f,0.4,0.4,2,1.5,beta1);
I=subs(I,beta1,x_optimization);
ISum=subs(ISum,beta1,x_optimization);
E=subs(E,beta1,x_optimization);
R=subs(R,beta1,x_optimization);
e1=(sum(abs(I(1:length(find(t<=TFlag1)))-IActual(1:length(find(t<=TFlag1))))./IActual(1:length(find(t<=TFlag1))))...
+sum(abs(ISum(1:length(find(t<=TFlag1)))-IActual_sum(1:length(find(t<=TFlag1))))./IActual_sum(1:length(find(t<=TFlag1)))))/length(find(t<=TFlag1));
x_optimization
figure(1)
plot(t(1:length(find(t<=TFlag1))), IActual(1:length(find(t<=TFlag1))), '--or',...
t(1:length(find(t<=TFlag1))), I(1:length(find(t<=TFlag1))), '^g:');
% 按照顺序标识标识图形
legend('实际新增人数', '理论新增人数');
% 添加标题 
title('实际与模型拟合结果比较');
%时间段2
for i=length(find(t<=TFlag1))+1:length(find(t<=TFlag2))-1
    E(i)=vpa(simplify(E(i-1)+beta2*I(i-1)-alpha*E(i-1)-Out(i-1)*E(i-1)/(S(i-1)+10000)),6);
    I(i)=vpa(simplify(I(i-1)+alpha*E(i-1)-gamma*I(i-1)),6);
    R(i)=vpa(simplify(R(i-1)+gamma*I(i-1)),6);
    N(i)=vpa(simplify(N(i-1)+In(i-1)-Out(i-1)),6);
    S(i)=vpa(N(i));
end
for i=length(find(t<=TFlag1))+1:length(find(t<=TFlag2))-1
    ISum(i)=sum(I(1:i));
end
f=power(I(length(find(t<=TFlag1))+1:length(find(t<=TFlag2))-1)-IActual(length(find(t<=TFlag1))+1:length(find(t<=TFlag2))-1),2);
[x_optimization,~] = Levenberg_Marquardt_Method(f,0.6,0.4,2,1.5,beta2);
I=subs(I,beta2,x_optimization);
ISum=subs(ISum,beta2,x_optimization);
E=subs(E,beta2,x_optimization);
R=subs(R,beta2,x_optimization);
e2=(sum(abs(I(length(find(t<=TFlag1))+1:length(find(t<=TFlag2))-1)-IActual(length(find(t<=TFlag1))+1:length(find(t<=TFlag2))-1))./IActual(length(find(t<=TFlag1))+1:length(find(t<=TFlag2))-1))...
+sum(abs(ISum(length(find(t<=TFlag1))+1:length(find(t<=TFlag2))-1)-IActual_sum(length(find(t<=TFlag1))+1:length(find(t<=TFlag2))-1)./IActual_sum(length(find(t<=TFlag1))+1:length(find(t<=TFlag2))-1)))...
/(length(find(t<=TFlag2))-1+length(find(t<=TFlag1))+1))
x_optimization
%绘制图形
figure(2)
plot(t(length(find(t<=TFlag1))+1:length(find(t<=TFlag2))-1), IActual(length(find(t<=TFlag1))+1:length(find(t<=TFlag2))-1), '--or',...
t(length(find(t<=TFlag1))+1:length(find(t<=TFlag2))-1), I(length(find(t<=TFlag1))+1:length(find(t<=TFlag2))-1), '^g:');
% 按照顺序标识标识图形
legend('实际新增人数', '理论新增人数');
% 添加标题 
title('实际与模型拟合结果比较');
%时间段3
for i=length(find(t<=TFlag2)):length(t)
    E(i)=vpa(simplify(E(i-1)+beta3*I(i-1)-alpha*E(i-1)-Out(i-1)*E(i-1)/(S(i-1)+10000)),6);
    I(i)=vpa(simplify(I(i-1)+alpha*E(i-1)-gamma*I(i-1)),6);
    R(i)=vpa(simplify(R(i-1)+gamma*I(i-1)),6);
    N(i)=vpa(simplify(N(i-1)+In(i-1)-Out(i-1)),6);
    S(i)=vpa(N(i));
end
for i=length(find(t<=TFlag2)):length(t)
    ISum(i)=sum(I(1:i));
end
f=power(I(length(find(t<=TFlag2)):length(t))-IActual(length(find(t<=TFlag2)):length(t)),2);
%+power(ISum(length(find(t<=TFlag3)):length(t))-IActual_sum(length(find(t<=TFlag3)):length(t)),2);
[x_optimization,~] = Levenberg_Marquardt_Method(f,0,0.4,2,1.5,beta3);
I=subs(I,beta3,x_optimization);
ISum=subs(ISum,beta3,x_optimization);
E=subs(E,beta3,x_optimization);
R=subs(R,beta3,x_optimization);
x_optimization
%绘制图形
figure(3)
plot(round(t(length(find(t<=TFlag2)):length(t))), round(IActual(length(find(t<=TFlag2)):length(t))), '--or',...
round(t(length(find(t<=TFlag2)):length(t))),round(I(length(find(t<=TFlag2)):length(t))), '^g:');
% 按照顺序标识标识图形
legend('实际新增人数', '理论新增人数');
% 添加标题 
title('实际与模型拟合结果比较');
%绘制图形
figure(4)
plot(t, IActual, '--or', t, I, '^g:');
% 按照顺序标识标识图形
legend('实际新增人数', '理论新增人数');
% 添加标题 
title('实际与模型拟合结果比较');
