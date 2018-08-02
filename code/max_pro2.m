%%
clear
clc
%%
% file_name = 'H:\海洋大学\研究生\建模大赛\数学建模竞赛D题附件\附件2-典型视频\不带晃动-静态背景\airport\input.avi';  
% source = VideoReader(file_name);
% numFrames = source.NumberOfFrames;                     % 读取视频的帧数  
thresh = 20;       %二值化阈值
% bg = read(source,1);
%bg_bw = rgb2gray(bg);           % convert background to greyscale
load('office_bj_zhongshu.mat');
bg_static=Obj.beijing;
numFrames = Obj.filenum;
bg_bw=Obj.X_frame(:,:,1);
wenjianming=Obj.wenjianming;
%bg_static=bg_bw;
% ----------------------- set frame size variables -----------------------
fr_size = size(bg_static);
width = fr_size(2);
height = fr_size(1);
diff_map = zeros(height, width);
SE1 = strel('ball',6,1);
SE2 = strel('ball',6,1);
% --------------------- process frames -----------------------------------
for i = 2:numFrames
    %fr = read(source,i);       % read in frame
    %fr_bw = rgb2gray(fr);       % convert frame to grayscale
    fr_bw=Obj.X_frame(:,:,i);
    fr=cat(3,fr_bw,fr_bw,fr_bw);
    %bg_static=X_bg_static(:,:,i);
    [ssim_num,~,~,~]=SSIM(fr_bw,bg_bw);
    fr_diff = abs(double(fr_bw) - double(bg_bw));  % cast operands as double to avoid negative overflow
    bg_diff = abs(double(fr_bw) - double(bg_static));
    for j=1:width                 % if fr_diff > thresh pixel in foreground
        for k=1:height
            if ((fr_diff(k,j) > thresh*ssim_num))
                fr_map(k,j) = 255;  %255为全白
            else
                fr_map(k,j) = 0;    %0为全黑
            end
        end
    end
    for j=1:width                 % if fr_diff > thresh pixel in foreground
        for k=1:height
            if ((bg_diff(k,j) > 30))
                bg_map(k,j) = 255;
            else
                bg_map(k,j) = 0;    
            end
        end
    end
    bg_bw = fr_bw;
    diff_map=bg_map.*(fr_map./255);
    %diff_map=fr_map;
    diff_map=imdilate(diff_map,SE1);
    diff_map=imerode(diff_map,SE2);
    diff_map=imfill(diff_map);
    %
    diff_map=cat(3,diff_map,diff_map,diff_map);
    diff_map=imresize(diff_map,[120 160]);
    fr=imresize(fr,[120 160]);
    diff_map16=uint16(diff_map);
    fr16=uint16(fr);
    L=immultiply(diff_map16,fr16);
    %

    %diff_map=bwmorph(diff_map,'erode');
    %diff_map=bwmorph(diff_map,'dilate');        %完成膨胀腐蚀操作
    %figure(1)
    %subplot(3,1,1),imshow(fr)
    %subplot(3,1,1),imshow(fr_bw)
    %subplot(3,1,2),imshow(uint8(diff_map))
    %subplot(3,1,3),imshow(L)
    %writeVideo(obj_gray,im2frame(uint8(diff_map),gray));           % save movie as avi 
end

imwrite(fr_bw,strcat('C:\Users\Administrator\Desktop\文档\保存图片\',wenjianming,'_input.jpg'));
imwrite(uint8(diff_map),strcat('C:\Users\Administrator\Desktop\文档\保存图片\',wenjianming,'_mask.jpg'));
L = mat2gray(L);
imwrite(L,strcat('C:\Users\Administrator\Desktop\文档\保存图片\',wenjianming,'_foreground.jpg'));