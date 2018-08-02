%最大概率背景模型
clear
clc
%airport
%hall
%office
%pedestrian
%smoke
file_name = 'H:\海洋大学\研究生\建模大赛\数学建模竞赛D题附件\附件2-典型视频\不带晃动-静态背景\smoke\input.avi';  
obj = VideoReader(file_name);     %读取视频文件
numFrames = obj.NumberOfFrames;   %视频总的帧数
file_name2 = 'H:\海洋大学\研究生\建模大赛\数学建模竞赛D题附件\附件2-典型视频\不带晃动-静态背景\smoke\image\';
wenjianming = 'smoke_mode';
for k = 1: numFrames
    frame = read(obj,k);
    %imshow(frame);
     gray_frame = rgb2gray(frame); %若每一帧为彩色图片，转换为灰度图
    %imshow(frame);                %显示每一帧图片
    %保存每一帧图片
    imwrite(gray_frame,strcat(file_name2,num2str(k),'.jpg'),'jpg');
end

DIR=file_name2;     %单帧图片所在文件夹
file=dir(strcat(DIR,'*.jpg'));             %读取图片所在文件所有jpg文件
filenum=size(file,1);                      %图片个数
for k=1:filenum
    fname = strcat(DIR, num2str(k), '.jpg');   %第k张图片的文件名
    frame = imread(fname);                     %读取第k张图片
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
