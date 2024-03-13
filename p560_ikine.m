function [thetaall,thetatrue]=p560_ikine(Pos)
% The function of PUMA560 forward kinematics
% output theta(1��6��degree) by Pos(xyz and rpy_degree) as input
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         The MDH parameters of PUMA 560
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% |  number  | alpha  |   a   |   d   | theta  | min | max |
% |     1    |   90   |     0 |   0   | theta1 |-160 | 160 |
% |     2    |   0    | 0.4318|   0   | theta2 | -45 | 225 |
% |     3    |  -90   | 0.0203|0.15005| theta3 |-225 |  45 |
% |     4    |   90   |     0 | 0.4318| theta4 |-110 | 170 |
% |     5    |  -90   |     0 |   0   | theta5 |-100 | 100 |
% |     6    |    0   |     0 |   0   | theta6 |-266 | 266 |
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% �����۲����ĳ�ʼ����DH�������ؽڽǷ�Χ���м����������
x=Pos(1);y=Pos(2);z=Pos(3);roll=Pos(4);pitch=Pos(5);yaw=Pos(6);
thm=[-160 -45 -225 -110 -100 -266;
      160 225   45  170  100  266]; % �ؽڽǷ�Χ����һ��Ϊ��Сֵ���ڶ���Ϊ���ֵ
r=x^2+y^2+z^2;

%% ���theta_3
Del3=-4*r^2+3.16664*r-0.069; 
a=r-0.3783;b=0.746;c=r-0.41336;
if (Del3>=0)
    t3(1,1)=(-b+sqrt(Del3))/(2*a);t3(2,1)=(-b-sqrt(Del3))/(2*a);
    t3(1,2)=t3(1,1);t3(2,2)=t3(2,1);
else
    fprintf("tan(theta3/2)���̸��б�ʽС���㣬theta3�޽⣡\n");
    fprintf("r=x^2+y^2+z^2��������[0.0224,0.7692]�ڣ�\n");
    return;
end
th3=2.*atan(t3).*180./pi; % th3��һ��2��2����ͬ��Ԫ����ͬ����ͬ�д���ͬ������theta3�Ľ�
%% ���theta2
f1=0.0203.*cosd(th3)-0.4318.*sind(th3)+0.4318;
f2=0.0203.*sind(th3)+0.4318.*cosd(th3);
f3=0.15005.*ones(2);
Del2=4.*f1.^2-4.*(z^2*ones(2)-f2.^2);
a=z+f2;b=-2.*f1;c=z-f2;
if (Del2>=0)
    t2(:,1)=(-b(:,1)+sqrt(Del2(:,1)))./(2*a(:,1));
    t2(:,2)=(-b(:,2)-sqrt(Del2(:,2)))./(2*a(:,2));
else
    fprintf("tan(theta2/2)���̸��б�ʽС���㣬theta2�޽⣡\n");
    return;
end
th2=2.*atan(t2).*180./pi;  % th2��һ��2��2����,�б��Ӧtheta3���б��Ӧ������theta3��Ӧ��theta2
                 % ��th2��1��2��theta3�ĵ�һ����ĵڶ���theta2�Ľ�
%% ���theta1
g1=f1.*cosd(th2)-f2.*sind(th2);
g2=-f3;                     % g1,g2��2��2���󡣴����i��theta3�ĵ�j��theta2ȷ��Ӧ��g
                            % ��g1��1��2����theta3�ĵ�һ��������Ӧ�ĵڶ���theta2�Ľ�ȷ����g1
angle1=180*atan2(y,x)/pi;  %(x,y)�ĽǶ�angle1
angle2=180.*atan2(g2,g1)./pi;  % (g1,g2)�ĽǶ�angle2 
th1=angle1-angle2;
if th1<-180
    th1=th1+360;
elseif th1>180
    th1=th1-360;
end
%% ���theta4,theta5,theta6
R06=rotz(roll)*roty(pitch)*rotx(yaw);
thetaall(8,6)=0;  % ȫ��������ĳ�ʼ��
for i=1:4   % �ֱ�����theta123��ֵ��ѭ������sth123��ѭ���ĴΣ�����th456,����ֵȫ��������theta
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% �ֱ�����theta123��ֵ��ѭ������sth123  %%%%%%%%%%%%%%%%%%%%%%%%%%
    if i==1   
        sth1=th1(1,1);
        sth2=th2(1,1);
        sth3=th3(1,1);
    elseif i==2
        sth1=th1(1,2);
        sth2=th2(1,2);
        sth3=th3(1,2);
    elseif i==3
        sth1=th1(2,1);
        sth2=th2(2,1);
        sth3=th3(2,1);
    elseif i==4
        sth1=th1(2,2);
        sth2=th2(2,2);
        sth3=th3(2,2);
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%% ����R4ORG6 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    R01=[cosd(sth1),-sind(sth1),0;
         sind(sth1), cosd(sth1),0;
                  0,          0,1];

    R12=[cosd(sth2),-sind(sth2), 0;
                  0,          0,-1;
         sind(sth2), cosd(sth2), 0];

    R23=[cosd(sth3),-sind(sth3),0;
         sind(sth3), cosd(sth3),0;
                  0,          0,1];
    
    R34ORG=[   1,   0,  0;
               0,   0,  1;
               0,  -1,  0];
    
    R04ORG=R01*R12*R23*R34ORG;
    R4ORG6=R04ORG\R06;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ����sth456 %%%%%%%%%%%%%%%%%%%%%%%%%%
    if R4ORG6(3,1)==0&&R4ORG6(3,2)==0 % beta=0��180
        sth4(1)=0;sth5(1)=  0;sth6(1)=180*atan2(-R4ORG6(1,2),R4ORG6(1,1))/pi;
        sth4(2)=0;sth5(2)=180;sth6(2)=180*atan2(R4ORG6(1,2),-R4ORG6(1,1))/pi;
    else
        sth5(1)=-atan2(sqrt(R4ORG6(3,1)^2+R4ORG6(3,2)^2),R4ORG6(3,3))*180/pi;
        sth4(1)=atan2(R4ORG6(2,3)/sind(-sth5(1)),R4ORG6(1,3)/sind(-sth5(1)))*180/pi;
        sth6(1)=atan2(R4ORG6(3,2)/sind(-sth5(1)),-R4ORG6(3,1)/sind(-sth5(1)))*180/pi;
        
        sth5(2)=-atan2(-sqrt(R4ORG6(3,1)^2+R4ORG6(3,2)^2),R4ORG6(3,3))*180/pi;
        sth4(2)=atan2(R4ORG6(2,3)/sind(-sth5(2)),R4ORG6(1,3)/sind(-sth5(2)))*180/pi;
        sth6(2)=atan2(R4ORG6(3,2)/sind(-sth5(2)),-R4ORG6(3,1)/sind(-sth5(2)))*180/pi;
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%% theta %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    thetaall(2*i-1,:)=[sth1,sth2,sth3,sth4(1),sth5(1),sth6(1)];
    thetaall(2*i  ,:)=[sth1,sth2,sth3,sth4(2),sth5(2),sth6(2)];
end

%% ���ؽ��
thetatrue=thetaall; % �޳��ظ���ͳ����ؽڷ�Χ�Ľ��Ľ����
epss=0.1; %���ùؽڽǶ��ظ��޳��ľ���
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% �޳��ظ��� %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if abs(th3(1,1)-th3(2,1))<epss % th3�ؽ�
    thetatrue(5:8,:)=[];
    if abs(th2(1,1)-th2(1,2))<epss % th3�ؽ�th2�ؽ�
        thetatrue(3:4,:)=[];
    end
else                         %  th3���ؽ�
    if abs(th2(2,1)-th2(2,2))<epss % �ڶ���th3��th2�ؽ�
        thetatrue(7:8,:)=[];         
    end
    if abs(th2(1,1)-th2(1,2))<epss % ��һ��th3��th2�ؽ�
        thetatrue(3:4,:)=[]; 
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% �޳������ؽ����ƵĽ� %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[m,n]=size(thetatrue); % thetatrue��ʣm��
for j=m:-1:1  % ���µ��ϣ����м���
    for k=1:6
        if (thetatrue(j,k)<thm(1,k))||(thetatrue(j,k)>thm(2,k))
            thetatrue(j,:)=[];
            break;
        end
    end
end
