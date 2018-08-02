clear all
file_name = 'D:\数学建模竞赛D题附件\附件2-典型视频\不带晃动-静态背景\hall\input.avi';  
source = VideoReader(file_name);
numFrames = source.NumberOfFrames;                     % 读取视频的帧数  
thresh = 30;       %二值化初始阈值
bg = read(source,1);
bg_bw = rgb2gray(bg);           % convert background to greyscale
bg_static=bg_bw;
mask_gray = VideoWriter('mask.avi');   %所转换成的视频名称
fr_gray = VideoWriter('foreground.avi');   %所转换成的视频名称
% ----------------------- set frame size variables -----------------------
fr_size = size(bg);             
width = fr_size(2);
height = fr_size(1);
diff_map = zeros(height, width);
fr_map = zeros(height, width);
SE1 = strel('ball',8,1,0);
SE2 = strel('ball',8,1,0);
% --------------------- process frames -----------------------------------
open(mask_gray);
open(fr_gray);         

writeVideo(mask_gray,im2frame(uint8(diff_map),gray));           % save movie as avi 
writeVideo(fr_gray,im2frame(uint8(fr_map),gray));           % save movie as avi 
for i = 2:numFrames
    
    fr = read(source,i);       % read in frame
    fr_bw = rgb2gray(fr);       % convert frame to grayscale
    [ssim_num,~,~,~]=SSIM(fr_bw,bg_bw);

    fr_diff = abs(double(fr_bw) - double(bg_bw));  % cast operands as double to avoid negative overflow
    bg_diff = abs(double(fr_bw) - double(bg_static));
    for j=1:width                 % if fr_diff > thresh pixel in foreground
        for k=1:height
            if ((fr_diff(k,j) > thresh*ssim_num))
                fr_diff(k,j) = 255;
            else
                fr_diff(k,j) = 0;
            end
        end
    end
    for j=1:width                 % if fr_diff > thresh pixel in foreground
        for k=1:height
            if ((bg_diff(k,j) > thresh*ssim_num))
                bg_diff(k,j) = 1;
            else
                bg_diff(k,j) = 0;    
            end
        end
    end
    for j=1:width                 % if fr_diff > thresh pixel in foreground
        for k=1:height
            if ((bg_bw(k,j) < 200))
                bg_bw(k,j) = bg_bw(k,j) ;
            else
                bg_bw(k,j) = 0;
            end
        end
    end

    bg_bw = fr_bw;
    %diff_map=bg_diff.*fr_diff;
    diff_map=fr_diff;
    diff_map=imdilate(diff_map,SE1);
    diff_map=imerode(diff_map,SE2);
    imfill(uint8(diff_map));
    fr_map = immultiply((uint8(diff_map)./255),fr_bw);
    figure(1)
    subplot(3,1,1),imshow(fr_bw)
    subplot(3,1,2),imshow(uint8(diff_map))
    subplot(3,1,3),imshow(uint8(fr_map))
    writeVideo(mask_gray,im2frame(uint8(diff_map),gray));           % save movie as avi 
    writeVideo(fr_gray,im2frame(uint8(fr_map),gray));           % save movie as avi 
end
close(mask_gray);
close(fr_gray);
 
    