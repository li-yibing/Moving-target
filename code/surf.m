%function:  
%surf特征点检测与匹配   
clear
close
clc
%从视频中获取图片
file_name = 'H:\海洋大学\研究生\建模大赛\数学建模竞赛D题附件\附件2-典型视频\有晃动\people2\input.avi';  
obj = VideoReader(file_name);     %读取视频文件
numFrames = obj.NumberOfFrames;   %视频总的帧数
for k=1:(numFrames-1)
    bg = read(obj,k);                 %读第k帧
    bg2 = read(obj,k+1);              %读第k+1帧
    if length(size(bg))>2
        bg = rgb2gray(bg);
    end
    if length(size(bg2))>2
        bg2 = rgb2gray(bg2);
    end
    %Read the two images.
    I1=bg;
    I2=bg2;
    %Find the SURF features.寻找特征点  
    points1 = detectSURFFeatures(I1);  
    points2 = detectSURFFeatures(I2);   
  
    %Extract the features.计算描述向量  
    [f1, vpts1] = extractFeatures(I1, points1);  
    [f2, vpts2] = extractFeatures(I2, points2);  
  
    %Retrieve the locations of matched points. The SURF feature vectors are already normalized.  
    %进行匹配  
    indexPairs = matchFeatures(f1, f2, 'Prenormalized', true) ;  
    matched_pts1 = vpts1(indexPairs(:, 1));  
    matched_pts2 = vpts2(indexPairs(:, 2));  
  
    %Display the matching points. The data still includes several outliers,   
    %but you can see the effects of rotation and scaling on the display of matched features.  
    %对匹配结果进行显示，可以看到，还有一些异常值  
%     figure('name','result'); showMatchedFeatures(I1,I2,matched_pts1,matched_pts2);  
%     legend('matched points 1','matched points 2');

    [tform,inlierPtsDistorted,inlierPtsOriginal] = estimateGeometricTransform(matched_pts2,matched_pts1,'similarity');
    outputView = imref2d(size(I1));
    Ir = imwarp(I2,tform,'OutputView',outputView);%Ir即为偏移校正后的图片
    X_Ir(:,:,k)=Ir;
%     figure; imshow(Ir);
%     title('Recovered image');
end
save surf X_Ir
% clear
% load('surf.mat');
thresh = 20;
fr_size = size(bg);
width = fr_size(2);
height = fr_size(1);
SE1 = strel('ball',6,1);
SE2 = strel('ball',6,1);
for i = 2:(numFrames-1)
    fr_bw = X_Ir(:,:,i);       % convert frame to grayscale
    fr = cat(3,fr_bw,fr_bw,fr_bw);
    bg_bw = read(obj,i);
    if length(size(bg_bw))>2
        bg_bw = rgb2gray(bg_bw);
    end
    %bg_static=X_bg_static(:,:,i);
    [ssim_num,~,~,~]=SSIM(fr_bw,bg_bw);
    fr_diff = abs(double(fr_bw) - double(bg_bw));  % cast operands as double to avoid negative overflow
    bg_static = bg_bw;
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
    figure(1)
    %subplot(3,1,1),imshow(fr)
    subplot(3,1,1),imshow(fr_bw)
    subplot(3,1,2),imshow(uint8(diff_map))
    subplot(3,1,3),imshow(L)
    %writeVideo(obj_gray,im2frame(uint8(diff_map),gray));           % save movie as avi 
    imwrite(fr_bw,strcat('C:\Users\Administrator\Desktop\文档\保存图片\第三题静态差分模型结果\people2\input',num2str(i),'.jpg'),'jpg');
    imwrite(uint8(diff_map),strcat('C:\Users\Administrator\Desktop\文档\保存图片\第三题静态差分模型结果\people2\mask',num2str(i),'.jpg'),'jpg');
    L = mat2gray(L);
    imwrite(L,strcat('C:\Users\Administrator\Desktop\文档\保存图片\第三题静态差分模型结果\people2\foreground',num2str(i),'.jpg'),'jpg');
end