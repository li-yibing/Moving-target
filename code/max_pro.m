%�����ʱ���ģ��
clear
clc
%airport
%hall
%office
%pedestrian
%smoke
file_name = 'H:\�����ѧ\�о���\��ģ����\��ѧ��ģ����D�⸽��\����2-������Ƶ\�����ζ�-��̬����\smoke\input.avi';  
obj = VideoReader(file_name);     %��ȡ��Ƶ�ļ�
numFrames = obj.NumberOfFrames;   %��Ƶ�ܵ�֡��
file_name2 = 'H:\�����ѧ\�о���\��ģ����\��ѧ��ģ����D�⸽��\����2-������Ƶ\�����ζ�-��̬����\smoke\image\';
wenjianming = 'smoke_mode';
for k = 1: numFrames
    frame = read(obj,k);
    %imshow(frame);
     gray_frame = rgb2gray(frame); %��ÿһ֡Ϊ��ɫͼƬ��ת��Ϊ�Ҷ�ͼ
    %imshow(frame);                %��ʾÿһ֡ͼƬ
    %����ÿһ֡ͼƬ
    imwrite(gray_frame,strcat(file_name2,num2str(k),'.jpg'),'jpg');
end

DIR=file_name2;     %��֡ͼƬ�����ļ���
file=dir(strcat(DIR,'*.jpg'));             %��ȡͼƬ�����ļ�����jpg�ļ�
filenum=size(file,1);                      %ͼƬ����
for k=1:filenum
    fname = strcat(DIR, num2str(k), '.jpg');   %��k��ͼƬ���ļ���
    frame = imread(fname);                     %��ȡ��k��ͼƬ
    if length(size(frame))>2
        fname=rgb2gray(frame);
    end
    X_frame(:,:,k)=frame;
end

[fwidth,flength]=size(frame);
fbeijing=zeros(1,fwidth*flength);
fmode=zeros(1,filenum);
i=1;
for w=1:fwidth
    for l=1:flength
        for k=1:filenum
            fmode(k)=X_frame(w,l,k);
            if k==filenum
                fbeijing(i)=mode(fmode);
                i=i+1;
            end
        end
    end
end
Obj.beijing=uint8(reshape(fbeijing,l,w)');
Obj.file_name=file_name;
Obj.file_name2=file_name2;
Obj.filenum=filenum;
Obj.X_frame=X_frame;
Obj.wenjianming=wenjianming;
%imshow(beijing);
save office_bj_zhongshu Obj
run('max_pro2');
