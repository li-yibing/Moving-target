clear;
videoObj = VideoReader('D:\数学建模竞赛D题附件\附件2-典型视频\有晃动\people2\input.avi');
numFrames = get(videoObj, 'NumberOfFrames');

FRAME_HEIGHT =videoObj.height;
FRAME_WIDTH = videoObj.width;
SE1 = strel('ball',2,0,0);
SE2 = strel('ball',2,0,0);
SE3 = strel('ball',3,0,0);
mask_gray=VideoWriter('mask.avi');   %蒙版存储在程序目录mask.avi
fr_gray = VideoWriter('foreground.avi');   %前景目标存储在foreground.avi
open(mask_gray);
open(fr_gray);
vibe = VIBE();
bg=read(videoObj,1);

for ii = 2:numFrames,
    im = read(videoObj, ii);
    ptsOriginal  = detectSURFFeatures(rgb2gray(bg));
    ptsDistorted = detectSURFFeatures(rgb2gray(im));
    [featuresOriginal,validPtsOriginal] = extractFeatures(rgb2gray(bg), ptsOriginal);
    [featuresDistorted,validPtsDistorted] = extractFeatures(rgb2gray(im),ptsDistorted);
    
    index_pairs = matchFeatures(featuresOriginal,featuresDistorted);
    matchedPtsOriginal  = validPtsOriginal(index_pairs(:,1));
    matchedPtsDistorted = validPtsDistorted(index_pairs(:,2));
%    figure; showMatchedFeatures(bg,im,matchedPtsOriginal,matchedPtsDistorted);
%    title('Matched SURF points,including outliers');
    
    [tform,inlierPtsDistorted,inlierPtsOriginal] = estimateGeometricTransform(matchedPtsDistorted,matchedPtsOriginal,'similarity');
%    figure; showMatchedFeatures(bg,im,inlierPtsOriginal,inlierPtsDistorted);
%    title('Matched inlier points');
    
    outputView = imref2d(size(bg));
    im = imwarp(im,tform,'OutputView',outputView);
%    figure; imshow(Ir);
%    title('Recovered image');
%     im = double(imresize(im, [FRAME_HEIGHT, FRAME_WIDTH]));
%     temp=imdilate(im,SE1);
%     temp=imerode(im,SE2);
%     temp=imerode(im,SE3);
    diff_map = vibe.GetfrImageC3R(uint8(bg));
    diff_map=imerode(diff_map,SE1);
    diff_map=imdilate(diff_map,SE2);
    diff_map=imdilate(diff_map,SE3);
    bg=im;
    fr_map = immultiply((diff_map./255),rgb2gray(bg));
    figure(1)
    subplot(3,1,1),imshow(uint8(bg))
    subplot(3,1,2),imshow(uint8(diff_map))
    subplot(3,1,3),imshow(uint8(fr_map))
    writeVideo(mask_gray,im2frame(uint8(diff_map),gray));           % save movie as avi 
    writeVideo(fr_gray,im2frame(uint8(fr_map),gray));           % save movie as avi 
end
close(mask_gray);
close(fr_gray);