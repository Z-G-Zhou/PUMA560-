clear,clc,close all;
%% �ֱ�����Աຯ����rtb��������
mdl_puma560;
thetad=[-30.0000  -58.2807   30.0000  -61.7193  -30.0000  -30.0000];%�Զ��Ƕ�
theta=thetad/180*pi;   %תΪ����
[Tmine,Posmine]=p560_fkine(thetad); %�Աຯ����T��Pos��xyz+rpy
Trtb=p560.fkine(theta);  %��������T
%% ��֤T�Ƿ�һ��
Tmine
Trtb 
%% ��֤Pos�Ƿ�һ��
Posmine                 %����Աຯ������Pos
p560.teach(theta)       %��ʾrtb�ĵõ���pos�͵�ǰ��������̬