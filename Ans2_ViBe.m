clear;
videoObj = VideoReader('D:\数学建模竞赛D题附件\附件2-典型视频\不带晃动-动态背景\waterSurface\input.avi');
numFrames = get(videoObj, 'NumberOfFrames');

FRAME_HEIGHT =videoObj.height;
FRAME_WIDTH = videoObj.width;
SE1 = strel('ball',2,1,0);
SE2 = strel('ball',1,1,0);
SE3 = strel('ball',1,1,0);
mask_gray=VideoWriter('mask.avi');   %蒙版存储在程序目录mask.avi
fr_gray = VideoWriter('foreground.avi');   %前景目标存储在foreground.avi
open(mask_gray);
open(fr_gray);
vibe = VIBE();
for ii = 1:numFrames-1,
    im = read(videoObj, ii);
    
%     im = double(imresize(im, [FRAME_HEIGHT, FRAME_WIDTH]));
%     temp=imdilate(im,SE1);
%     temp=imerode(im,SE2);
%     temp=imerode(im,SE3);
    diff_map = vibe.GetfrImageC3R(uint8(im));
    diff_map=imerode(diff_map,SE1);
    diff_map=imdilate(diff_map,SE2);
    diff_map=imdilate(diff_map,SE3);

    fr_map = immultiply((diff_map./255),rgb2gray(im));
    figure(1)
    subplot(3,1,1),imshow(uint8(im))
    subplot(3,1,2),imshow(uint8(diff_map))
    subplot(3,1,3),imshow(uint8(fr_map))
    writeVideo(mask_gray,im2frame(uint8(diff_map),gray));           % save movie as avi 
    writeVideo(fr_gray,im2frame(uint8(fr_map),gray));           % save movie as avi 
end
close(mask_gray);
close(fr_gray);