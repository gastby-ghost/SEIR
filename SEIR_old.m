%�ֲ�����
familyNum=4;
floorNum=4;
buildNum=25;
communityNum=15;
sectorNum=20;
areaNum=80;
%��������
exchangeRatio=0.6;
%��Ⱦ��Χ
infectArea=8;
%��ʼ����
Population=familyNum*floorNum*buildNum*communityNum*sectorNum*areaNum;
%��ʼ��Ⱦ����
infective0=1;
%��Ⱦ��
homeInfectRatio=0.1;
outInfectRatio=0.08;
%״̬
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
%��ʼ����Ⱦ����
IPosition0=fix(unifrnd(1,Population,1,infective0));
I(IPosition0)=1;
S(IPosition0)=0;
length(find(I==1))
length(find(S==0))
%���沿��
time=0;
%��ͼ����
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
    %����Ⱦ�ڵĸ����ɻָ��ڵĸ���
    R(IT==1)=1;
    I(IT==1)=0;
    %�ָ�ʱ��ݼ�
    IT=IT-1;
    %��Ǳ���ڵĸ����ɸ�Ⱦ�ڵĸ���
    I(ET==1)=1;
    E(ET==1)=0;
    %��̫�ֲ��Ļָ���
    IT(ET==1)=fix(normrnd(IT_mu,IT_sigma,1,length(find(ET==1))));
    %Ǳ��ʱ��ݼ�
    ET=ET-1;
    %��ͬ�ռ����
    ETemp=false(1,Population);%���ڴ洢������沽���ĸ�Ⱦ���
    C={};
    %��ͥ
    familyCs=true(1,Population);
    familyCount=int32(Population/familyNum);%��ͥ������Ҳ���Ƿֿ������
    for i=0:familyCount-1
        %��ǰ���еĹ�ͬ�ռ����и�Ⱦ��
        familyCom=familyCs(i*familyNum+1:i*familyNum+familyNum);
        if any(I(i*familyNum+1:i*familyNum+familyNum)&familyCom)
            %����Ⱦ��������ж�
            familyETemp=unifrnd(0,1,1,familyNum);
            familyETemp(familyETemp<1-homeInfectRatio)=0;
            familyETemp(familyETemp>1-homeInfectRatio)=1;
            %��ӵ�Ǳ���ھ���--ע�Ᵽ��ԭ������
            ETemp(i*familyNum+1:i*familyNum+4)=ETemp(i*familyNum+1:i*familyNum+4)|(familyETemp&familyCom);
            %�洢����ͬ�ռ�
            C=[C find(familyCom)+double(i*familyNum)*ones(1,familyNum)];
        end
    end
    length(C)
    %¥��
    %������ɹ�ͬ�ռ�
    floorCs=unifrnd(0,1,1,Population);
    floorCs(floorCs>(1-exchangeRatio))=1;
    floorCs(floorCs<(1-exchangeRatio))=0;
    floorCs=logical(floorCs&familyCs);
    floorSumNum=familyNum*floorNum;
    floorCount=int32(Population/(familyNum*floorNum));%¥�㿼�ǵĸ�������
    floorLevel=ceil((exchangeRatio*familyNum*floorNum)/infectArea);%���������ӿ�����
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
                    %��ȡ��Ⱦ��Ϣ--�����˸�Ⱦ���ʵĿ���
                    floorETemp=unifrnd(0,1,1,floorSumNum);
                    floorETemp(floorETemp<(1-outInfectRatio))=0;
                    floorETemp(floorETemp>(1-outInfectRatio))=1;
                    ETemp(i*floorSumNum+1:i*floorSumNum+floorSumNum)=floorETemp&floorCom;
                    %�洢��ͬ�ռ�
                    C=[C find(floorCom)+double(i*floorSumNum)*ones(1,length(find(floorCom)))];
                end
            end
        end
    end
    length(C)
    %build
    %������ɹ�ͬ�ռ�
    buildCs=unifrnd(0,1,1,Population);
    buildCs(buildCs>(1-exchangeRatio))=1;
    buildCs(buildCs<(1-exchangeRatio))=0;
    buildCs=logical(buildCs&floorCs);
    buildSumNum=familyNum*floorNum*buildNum;
    buildCount=int32(Population/buildSumNum);%¥�㿼�ǵĸ�������
    buildLevel=ceil((exchangeRatio^2*buildSumNum)/infectArea);%���������ӿ�����
    for i=0:buildCount-1
        if any(I(i*buildSumNum+1:i*buildSumNum+buildSumNum)&buildCs(i*buildSumNum+1:i*buildSumNum+buildSumNum))
            buildRandomi=unifrnd(0,1,1,buildSumNum);
            buildRandomi(buildCs(i*buildSumNum+1:i*buildSumNum+buildSumNum)==0)=0;
            for j=1:buildLevel
                buildCom=false(1,buildSumNum);
                buildCom(buildRandomi>(1-j/buildLevel+0.000001))=1;
                buildRandomi(buildRandomi>(1-j/buildLevel+0.000001))=0;
                if any(I(i*buildSumNum+1:i*buildSumNum+buildSumNum)&buildCom)
                    %��ȡ��Ⱦ��Ϣ--�����˸�Ⱦ���ʵĿ���
                    buildETemp=unifrnd(0,1,1,buildSumNum);
                    buildETemp(buildETemp<(1-outInfectRatio))=0;
                    buildETemp(buildETemp>(1-outInfectRatio))=1;
                    ETemp(i*buildSumNum+1:i*buildSumNum+buildSumNum)=buildETemp&buildCom;
                    %�洢��ͬ�ռ�
                    C=[C find(buildCom)+double(i*buildSumNum)*ones(1,length(find(buildCom)))];
                end
            end
        end
    end
    length(C)
    %community
    %������ɹ�ͬ�ռ�
    communityCs=unifrnd(0,1,1,Population);
    communityCs(communityCs>(1-exchangeRatio))=1;
    communityCs(communityCs<(1-exchangeRatio))=0;
    communityCs=logical(communityCs&buildCs);
    communitySumNum=familyNum*floorNum*buildNum*communityNum;
    communityCount=int32(Population/communitySumNum);%���ǵĸ�������
    communityLevel=ceil((exchangeRatio^3*communitySumNum)/infectArea);%���������ӿ�����
    for i=0:communityCount-1
        if any(I(i*communitySumNum+1:i*communitySumNum+communitySumNum)&communityCs(i*communitySumNum+1:i*communitySumNum+communitySumNum))
            communityRandomi=unifrnd(0,1,1,communitySumNum);
            communityRandomi(communityCs(i*communitySumNum+1:i*communitySumNum+communitySumNum)==0)=0;
            for j=1:communityLevel
                communityCom=false(1,communitySumNum);
                communityCom(communityRandomi>(1-j/communityLevel+0.000001))=1;
                communityRandomi(communityRandomi>(1-j/communityLevel+0.000001))=0;
                if any(I(i*communitySumNum+1:i*communitySumNum+communitySumNum)&communityCom)
                    %��ȡ��Ⱦ��Ϣ--�����˸�Ⱦ���ʵĿ���
                    communityETemp=unifrnd(0,1,1,communitySumNum);
                    communityETemp(communityETemp<(1-outInfectRatio))=0;
                    communityETemp(communityETemp>(1-outInfectRatio))=1;
                    ETemp(i*communitySumNum+1:i*communitySumNum+communitySumNum)=communityETemp&communityCom;
                    %�洢��ͬ�ռ�
                    C=[C find(communityCom)+double(i*communitySumNum)*ones(1,length(find(communityCom)))];
                end
            end
        end
    end
    length(C)
    %sector
    %������ɹ�ͬ�ռ�
    sectorCs=unifrnd(0,1,1,Population);
    sectorCs(sectorCs>(1-exchangeRatio))=1;
    sectorCs(sectorCs<(1-exchangeRatio))=0;
    sectorCs=logical(sectorCs&communityCs);
    sectorSumNum=familyNum*floorNum*buildNum*communityNum*sectorNum;
    sectorCount=int32(Population/sectorSumNum);%���ǵĸ�������
    sectorLevel=ceil((exchangeRatio^4*sectorSumNum)/infectArea);%���������ӿ�����
    for i=0:sectorCount-1
        if any(I(i*sectorSumNum+1:i*sectorSumNum+sectorSumNum)&sectorCs(i*sectorSumNum+1:i*sectorSumNum+sectorSumNum))
            sectorRandomi=unifrnd(0,1,1,sectorSumNum);
            sectorRandomi(sectorCs(i*sectorSumNum+1:i*sectorSumNum+sectorSumNum)==0)=0;
            for j=1:sectorLevel
                sectorCom=false(1,sectorSumNum);
                sectorCom(sectorRandomi>(1-j/sectorLevel+0.000001))=1;
                sectorRandomi(sectorRandomi>(1-j/sectorLevel+0.000001))=0;
                if any(I(i*sectorSumNum+1:i*sectorSumNum+sectorSumNum)&sectorCom)
                    %��ȡ��Ⱦ��Ϣ--�����˸�Ⱦ���ʵĿ���
                    sectorETemp=unifrnd(0,1,1,sectorSumNum);
                    sectorETemp(sectorETemp<(1-outInfectRatio))=0;
                    sectorETemp(sectorETemp>(1-outInfectRatio))=1;
                    ETemp(i*sectorSumNum+1:i*sectorSumNum+sectorSumNum)=sectorETemp&sectorCom;
                    %�洢��ͬ�ռ�
                    C=[C find(sectorCom)+double(i*sectorSumNum)*ones(1,length(find(sectorCom)))];
                end
            end
        end
    end
    length(C)
    %area
    %������ɹ�ͬ�ռ�
    areaCs=unifrnd(0,1,1,Population);
    areaCs(areaCs>(1-exchangeRatio))=1;
    areaCs(areaCs<(1-exchangeRatio))=0;
    areaCs=logical(areaCs&sectorCs);
    areaSumNum=familyNum*floorNum*buildNum*communityNum*sectorNum*areaNum;
    areaCount=int32(Population/areaSumNum);%���ǵĸ�������
    areaLevel=ceil((exchangeRatio^5*areaSumNum)/infectArea);%���������ӿ�����
    for i=0:areaCount-1
        if any(I(i*areaSumNum+1:i*areaSumNum+areaSumNum)&areaCs(i*areaSumNum+1:i*areaSumNum+areaSumNum))
            %���㷽��2
            %����ÿ��area��ͬ�ռ�
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
    %���и�Ⱦ�ļ���
    %���ϸ���Ⱦ����Ⱥ��ȥ����Ⱦ���뿵����
    ETemp(R&I)=0;
    E(ETemp)=1;
    %��̫�ֲ���Ǳ����
    ET(ETemp)=fix(normrnd(ET_mu,ET_sigma,1,length(find(ETemp))));
    S(ETemp)=0;
    %ѭ���������������
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