%�����е�֡ͼƬת��Ϊ�����洢Ϊmat�ļ�
clear
clc

DIR='D:\��ѧ��ģ����D�⸽��\����4-��Ž��\��̬����\office\';     %��֡ͼƬ�����ļ���
file=dir(strcat(DIR,'*.jpg'));             %��ȡͼƬ�����ļ�����jpg�ļ�
filenum=size(file,1);                      %ͼƬ����

fname = strcat(DIR, num2str(1), '.jpg');   %��һ��ͼƬ���ļ���
frame = imread(fname);                     %��ȡ��һ��ͼƬ
rows = size(frame(:),1);                   %����ͼƬ�������ظ���
XX = zeros(rows, filenum);                 %������ͼƬ���ɾ���ʱ��ά��
%������ͼƬ��Ϊһ����
for k = 1: filenum
    fname = strcat(DIR, num2str(k), '.jpg');
    frame = imread(fname);
    x = frame(:);
    XX(:, k) = x;
    %writeVideo(obj_gray, frame);
end
%����Ƶ����������������obj����
obj.XX = uint8(XX);
obj.siz = size(frame);
save campus5 obj                           %��obj�����Ϊmat�ļ�