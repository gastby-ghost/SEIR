%分层描述
familyNum=4;
floorNum=4;
buildNum=25;
communityNum=15;
sectorNum=20;
areaNum=80;
%交流比例
exchangeRatio=0.6;
%感染范围
infectArea=8;
%初始人数
Population=familyNum*floorNum*buildNum*communityNum*sectorNum*areaNum;
%初始感染人数
infective0=1;
%感染率
homeInfectRatio=0.1;
outInfectRatio=0.08;
%状态
S=true(1,Population);
E=false(1,Population);
ET=repmat(10000,1,Population);
ET_mu=5.2;
ET_sigma=3.6;
I=false(1,Population);
IT=repmat(10000,1,Population);
IT_mu=10;
IT_sigma=2;
R=false(1,Population);
%初始化感染个体
IPosition0=fix(unifrnd(1,Population,1,infective0));
I(IPosition0)=1;
S(IPosition0)=0;
length(find(I==1))
length(find(S==0))
%仿真部分
time=0;
%绘图参数
S_y=zeros(1,60);
I_y=zeros(1,60);
E_y=zeros(1,60);
R_y=zeros(1,60);
time_x=zeros(1,0);
while(1)
    if (time>60)
        break;
    end
    time=time+1;
    %将感染期的个体变成恢复期的个体
    R(IT==1)=1;
    I(IT==1)=0;
    %恢复时间递减
    IT=IT-1;
    %将潜伏期的个体变成感染期的个体
    I(ET==1)=1;
    E(ET==1)=0;
    %正太分布的恢复期
    IT(ET==1)=fix(normrnd(IT_mu,IT_sigma,1,length(find(ET==1))));
    %潜伏时间递减
    ET=ET-1;
    %共同空间矩阵
    ETemp=false(1,Population);%用于存储这个仿真步长的感染情况
    C={};
    %家庭
    familyCs=true(1,Population);
    familyCount=int32(Population/familyNum);%家庭个数，也就是分块的数量
    for i=0:familyCount-1
        %当前块中的共同空间内有感染者
        familyCom=familyCs(i*familyNum+1:i*familyNum+familyNum);
        if any(I(i*familyNum+1:i*familyNum+familyNum)&familyCom)
            %做感染的随机性判断
            familyETemp=unifrnd(0,1,1,familyNum);
            familyETemp(familyETemp<1-homeInfectRatio)=0;
            familyETemp(familyETemp>1-homeInfectRatio)=1;
            %添加到潜伏期矩阵--注意保留原有数据
            ETemp(i*familyNum+1:i*familyNum+4)=ETemp(i*familyNum+1:i*familyNum+4)|(familyETemp&familyCom);
            %存储到共同空间
            C=[C find(familyCom)+double(i*familyNum)*ones(1,familyNum)];
        end
    end
    length(C)
    %楼层
    %随机生成共同空间
    floorCs=unifrnd(0,1,1,Population);
    floorCs(floorCs>(1-exchangeRatio))=1;
    floorCs(floorCs<(1-exchangeRatio))=0;
    floorCs=logical(floorCs&familyCs);
    floorSumNum=familyNum*floorNum;
    floorCount=int32(Population/(familyNum*floorNum));%楼层考虑的个体数量
    floorLevel=ceil((exchangeRatio*familyNum*floorNum)/infectArea);%整数化的子块数量
    for i=0:floorCount-1
        if any(I(i*floorSumNum+1:i*floorSumNum+floorSumNum)&floorCs(i*floorSumNum+1:i*floorSumNum+floorSumNum))
            floorRandomi=unifrnd(0,1,1,floorSumNum);
            floorRandomi(floorCs(i*floorSumNum+1:i*floorSumNum+floorSumNum)==0)=0;
            for j=1:floorLevel
                floorCom=false(1,floorSumNum);
                floorCom(floorRandomi>(1-j/floorLevel+0.000001))=1;
                floorCom=floorCom&floorCs(i*floorSumNum+1:i*floorSumNum+floorSumNum);
                floorRandomi(floorRandomi>(1-j/floorLevel+0.000001))=0;
                if any(I(i*floorSumNum+1:i*floorSumNum+floorSumNum)&floorCom)
                    %获取感染信息--加入了感染概率的考虑
                    floorETemp=unifrnd(0,1,1,floorSumNum);
                    floorETemp(floorETemp<(1-outInfectRatio))=0;
                    floorETemp(floorETemp>(1-outInfectRatio))=1;
                    ETemp(i*floorSumNum+1:i*floorSumNum+floorSumNum)=floorETemp&floorCom;
                    %存储共同空间
                    C=[C find(floorCom)+double(i*floorSumNum)*ones(1,length(find(floorCom)))];
                end
            end
        end
    end
    length(C)
    %build
    %随机生成共同空间
    buildCs=unifrnd(0,1,1,Population);
    buildCs(buildCs>(1-exchangeRatio))=1;
    buildCs(buildCs<(1-exchangeRatio))=0;
    buildCs=logical(buildCs&floorCs);
    buildSumNum=familyNum*floorNum*buildNum;
    buildCount=int32(Population/buildSumNum);%楼层考虑的个体数量
    buildLevel=ceil((exchangeRatio^2*buildSumNum)/infectArea);%整数化的子块数量
    for i=0:buildCount-1
        if any(I(i*buildSumNum+1:i*buildSumNum+buildSumNum)&buildCs(i*buildSumNum+1:i*buildSumNum+buildSumNum))
            buildRandomi=unifrnd(0,1,1,buildSumNum);
            buildRandomi(buildCs(i*buildSumNum+1:i*buildSumNum+buildSumNum)==0)=0;
            for j=1:buildLevel
                buildCom=false(1,buildSumNum);
                buildCom(buildRandomi>(1-j/buildLevel+0.000001))=1;
                buildRandomi(buildRandomi>(1-j/buildLevel+0.000001))=0;
                if any(I(i*buildSumNum+1:i*buildSumNum+buildSumNum)&buildCom)
                    %获取感染信息--加入了感染概率的考虑
                    buildETemp=unifrnd(0,1,1,buildSumNum);
                    buildETemp(buildETemp<(1-outInfectRatio))=0;
                    buildETemp(buildETemp>(1-outInfectRatio))=1;
                    ETemp(i*buildSumNum+1:i*buildSumNum+buildSumNum)=buildETemp&buildCom;
                    %存储共同空间
                    C=[C find(buildCom)+double(i*buildSumNum)*ones(1,length(find(buildCom)))];
                end
            end
        end
    end
    length(C)
    %community
    %随机生成共同空间
    communityCs=unifrnd(0,1,1,Population);
    communityCs(communityCs>(1-exchangeRatio))=1;
    communityCs(communityCs<(1-exchangeRatio))=0;
    communityCs=logical(communityCs&buildCs);
    communitySumNum=familyNum*floorNum*buildNum*communityNum;
    communityCount=int32(Population/communitySumNum);%考虑的个体数量
    communityLevel=ceil((exchangeRatio^3*communitySumNum)/infectArea);%整数化的子块数量
    for i=0:communityCount-1
        if any(I(i*communitySumNum+1:i*communitySumNum+communitySumNum)&communityCs(i*communitySumNum+1:i*communitySumNum+communitySumNum))
            communityRandomi=unifrnd(0,1,1,communitySumNum);
            communityRandomi(communityCs(i*communitySumNum+1:i*communitySumNum+communitySumNum)==0)=0;
            for j=1:communityLevel
                communityCom=false(1,communitySumNum);
                communityCom(communityRandomi>(1-j/communityLevel+0.000001))=1;
                communityRandomi(communityRandomi>(1-j/communityLevel+0.000001))=0;
                if any(I(i*communitySumNum+1:i*communitySumNum+communitySumNum)&communityCom)
                    %获取感染信息--加入了感染概率的考虑
                    communityETemp=unifrnd(0,1,1,communitySumNum);
                    communityETemp(communityETemp<(1-outInfectRatio))=0;
                    communityETemp(communityETemp>(1-outInfectRatio))=1;
                    ETemp(i*communitySumNum+1:i*communitySumNum+communitySumNum)=communityETemp&communityCom;
                    %存储共同空间
                    C=[C find(communityCom)+double(i*communitySumNum)*ones(1,length(find(communityCom)))];
                end
            end
        end
    end
    length(C)
    %sector
    %随机生成共同空间
    sectorCs=unifrnd(0,1,1,Population);
    sectorCs(sectorCs>(1-exchangeRatio))=1;
    sectorCs(sectorCs<(1-exchangeRatio))=0;
    sectorCs=logical(sectorCs&communityCs);
    sectorSumNum=familyNum*floorNum*buildNum*communityNum*sectorNum;
    sectorCount=int32(Population/sectorSumNum);%考虑的个体数量
    sectorLevel=ceil((exchangeRatio^4*sectorSumNum)/infectArea);%整数化的子块数量
    for i=0:sectorCount-1
        if any(I(i*sectorSumNum+1:i*sectorSumNum+sectorSumNum)&sectorCs(i*sectorSumNum+1:i*sectorSumNum+sectorSumNum))
            sectorRandomi=unifrnd(0,1,1,sectorSumNum);
            sectorRandomi(sectorCs(i*sectorSumNum+1:i*sectorSumNum+sectorSumNum)==0)=0;
            for j=1:sectorLevel
                sectorCom=false(1,sectorSumNum);
                sectorCom(sectorRandomi>(1-j/sectorLevel+0.000001))=1;
                sectorRandomi(sectorRandomi>(1-j/sectorLevel+0.000001))=0;
                if any(I(i*sectorSumNum+1:i*sectorSumNum+sectorSumNum)&sectorCom)
                    %获取感染信息--加入了感染概率的考虑
                    sectorETemp=unifrnd(0,1,1,sectorSumNum);
                    sectorETemp(sectorETemp<(1-outInfectRatio))=0;
                    sectorETemp(sectorETemp>(1-outInfectRatio))=1;
                    ETemp(i*sectorSumNum+1:i*sectorSumNum+sectorSumNum)=sectorETemp&sectorCom;
                    %存储共同空间
                    C=[C find(sectorCom)+double(i*sectorSumNum)*ones(1,length(find(sectorCom)))];
                end
            end
        end
    end
    length(C)
    %area
    %随机生成共同空间
    areaCs=unifrnd(0,1,1,Population);
    areaCs(areaCs>(1-exchangeRatio))=1;
    areaCs(areaCs<(1-exchangeRatio))=0;
    areaCs=logical(areaCs&sectorCs);
    areaSumNum=familyNum*floorNum*buildNum*communityNum*sectorNum*areaNum;
    areaCount=int32(Population/areaSumNum);%考虑的个体数量
    areaLevel=ceil((exchangeRatio^5*areaSumNum)/infectArea);%整数化的子块数量
    for i=0:areaCount-1
        if any(I(i*areaSumNum+1:i*areaSumNum+areaSumNum)&areaCs(i*areaSumNum+1:i*areaSumNum+areaSumNum))
            %计算方法2
            %计算每个area共同空间
            areaPos=find(areaCs);
            areaRandomi=unifrnd(0,1,1,length(areaPos));
            for j=1:areaLevel
                areaCom=zeros(1,length(areaPos));
                areaCom(areaRandomi>(1-j/areaLevel+0.000001))=1;
                areaPosj=areaPos(areaCom==1);
                areaCom=areaCs(areaPosj);
                %areaCom=areaCom&communityCs(i*areaSumNum+1:i*areaSumNum+areaSumNum);
                areaRandomi(areaRandomi>(1-j/areaLevel+0.000001))=0;
                areaFlag=any(I(areaPosj)&areaCom);
                if areaFlag>0
                    areaETemp=unifrnd(0,1,1,length(areaPosj));
                    areaETemp(areaETemp<(1-outInfectRatio))=0;
                    areaETemp(areaETemp>(1-outInfectRatio))=1;
                    ETemp(areaPosj(areaETemp==1))=1;
                    C=[C areaPosj];
                end
            end
        end
    end
    length(C)
    %进行感染的计算
    %从上个感染的人群中去除感染者与康复者
    ETemp(R&I)=0;
    E(ETemp)=1;
    %正太分布的潜伏期
    ET(ETemp)=fix(normrnd(ET_mu,ET_sigma,1,length(find(ETemp))));
    S(ETemp)=0;
    %循环结束，添加数据
    S_y(time)=length(find(S));
    E_y(time)=length(find(E));
    I_y(time)=length(find(I));
    R_y(time)=length(find(R));
    time_x(time)=time;
end
plot(time_x,S_y);
plot(time_x,E_y);
plot(time_x,I_y);
plot(time_x,R_y);