%读取表格数据
Diagnose = DiagnoseRead('Diagnose.xlsx','ods_sjkfds_zsj_daily_confirmed_',[2, 78]);
Flow = FlowRead('Flow.xlsx','Sheet1',2,29);
%生成考虑的时间段
t=datetime(2020,1,1):datetime(2020,3,20);
I=zeros(1,length(t));
I_sum=zeros(1,length(t));
In=zeros(1,length(t));
Out=zeros(1,length(t));
%初步读取数据
for i=1:length(t)
    if find(Diagnose.Time==t(i))
        I(i)=Diagnose.New_confirmed(Diagnose.Time==t(i));
        I_sum(i)=Diagnose.Cumulative(Diagnose.Time==t(i));
    end
    if find(Flow.Date==t(i))
        In(i)=Flow.Inflow(Flow.Date==t(i));
        Out(i)=Flow.Outflow(Flow.Date==t(i));
    end
end
%清理数据
for i=2:length(I_sum)
    if(I_sum(i)==0)
        I_sum(i)=I_sum(i-1);
    end
end

