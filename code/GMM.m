%混合高斯模型算法分离背景信息
close
clear
clc
%'airport'
%'hall'
%'office'
%'pedestrian'
%'smoke'
file_name = 'H:\海洋大学\研究生\建模大赛\数学建模竞赛D题附件\附件2-典型视频\不带晃动-静态背景\hall\input.avi';  
wenjianming='hall_gaosi';
source = VideoReader(file_name);                   %读取视频
numFrames = source.NumberOfFrames;                 %读取视频的帧数  
bg = read(source,1);                               %读视频的第一帧
fr=bg;
if length(size(bg))>2                              %判断原始视频信息是否为灰色，如果不是转化为灰色
    bg_bw = rgb2gray(bg);
else
    bg_bw = bg;
end
%设定腐蚀膨胀系数
SE1 = strel('ball',10,1);
SE2 = strel('ball',10,1);
% -----------------------  确定框架的尺寸信息 -----------------------
%fr=bg均为视频的原始第一帧
%bg_bw为视频的灰白第一帧
fr_bw = bg_bw;     
fr_size = size(fr);%原始视频每帧画面的尺寸
width = fr_size(2);%宽度，即为矩阵的列数
height = fr_size(1);%高度，即为矩阵的行数

fg = zeros(height, width);
bg_bw = zeros(height, width);
diff_map = zeros(height, width);


% --------------------- mog variables -----------------------------------


C = 3;                                  % number of gaussian components (typically 3-5)   Cgegaosimoxing
M = 3;                                  % number of background components,
D = 2.5;                                % positive deviation threshold
alpha = 0.01;                           % learning rate (between 0 and 1) (from paper 0.01) the background will change slowly with the time, so the mean(u)should be updated slowly.
thresh = 0.2;                          % foreground threshold (0.25 or 0.75 in paper)
thresh1 = 20;
sd_init = 6;                            % initial standard deviation (for new components) var = 36 in paper
w = zeros(height,width,C);              % initialize weights array
mean = zeros(height,width,C);           % pixel means  , the u of gaosi(u,d)
sd = zeros(height,width,C);             % pixel standard deviations , the d of gaosi(u,d)
u_diff = zeros(height,width,C);         % difference of each pixel from mean
p = alpha/(1/C);                        % initial p variable (used to update mean and sd)
rank = zeros(1,C);                      % rank of components (w/sd)


% --------------------- initialize component means and weights -----------


pixel_depth = 8;                        % 8-bit resolution
pixel_range = 2^pixel_depth -1;         % pixel range (# of possible values)


for i=1:height
    for j=1:width
        for k=1:C
            
            mean(i,j,k) = rand*pixel_range;     % means random (0-255)
            w(i,j,k) = 1/C;                     % weights uniformly dist
            sd(i,j,k) = sd_init;                % initialize to sd_init
            
        end
    end
end


%--------------------- process frames -----------------------------------


for n = 2:numFrames              %there will be false route line,so it only include the pictures which has the car


    fr = read(source,n);       % read in frame
    fr_bw = rgb2gray(fr);       % convert frame to grayscale
    
    % calculate difference of pixel values from mean
    for m=1:C
        u_diff(:,:,m) = abs(double(fr_bw) - double(mean(:,:,m)));
    end
    sum_x=0;
    sum_y=0;
    num=0; 
    % 更新每一个像素点的高斯分量
    for i=1:height                        %搜索每一张图片的每一个像素点，如果符合高斯混合模型，那么这个像素点就属于背景，就会更新到背景信息中
        for j=1:width                     %If it is not in the C ge gaosimoxing, create a new gaosi and replace the least possible gaosi. Finally the the first several gaosi is background, and the last several is foreground 
            match = 0;            
            for k=1:C                       
                 if (abs(u_diff(i,j,k)) <= D*sd(i,j,k))       % pixel matches component
                    match = 1;                          % variable to signal component match
                    % update weights, mean, sd, p
                    w(i,j,k) = (1-alpha)*w(i,j,k) + alpha;
                    p = alpha/w(i,j,k);                  
                    mean(i,j,k) = (1-p)*mean(i,j,k) + p*double(fr_bw(i,j));
                    sd(i,j,k) =   sqrt((1-p)*(sd(i,j,k)^2) + p*((double(fr_bw(i,j)) - mean(i,j,k)))^2);
                else                                    % pixel doesn't match component
                    w(i,j,k) = (1-alpha)*w(i,j,k);      % weight slighly decreases
                end
            end      
            bg_bw(i,j)=0;
            for k=1:C
                bg_bw(i,j) = bg_bw(i,j)+ mean(i,j,k)*w(i,j,k);
            end
            % if no components match, create new component
            if (match == 0)
                [min_w, min_w_index] = min(w(i,j,:));  
                mean(i,j,min_w_index) = double(fr_bw(i,j));
                sd(i,j,min_w_index) = sd_init;
            end
            rank = w(i,j,:)./sd(i,j,:);             % calculate component rank
            rank_ind = [1:1:C];
            %计算更新背景信息
            fg(i,j) = 0;
            while ((match == 0)&&(k<=M))
 
                    if (abs(u_diff(i,j,rank_ind(k))) <= D*sd(i,j,rank_ind(k)))
                        fg(i,j) = 0; %black = 0
           
                    else
                        fg(i,j) = fr_bw(i,j);                  
                        sum_x=sum_x+j;        
                        sum_y=sum_y+i;
                        num=num+1;
                    end   
                k = k+1;                
            end
        end
    end
    num=0;
    X_bg_bw(:,:,n)=bg_bw;%将每一帧背景存储下来
end
%%
%根据高斯混合模型背景进行帧间差分
for i = 2:numFrames
    fr = read(source,i);       % read in frame
    fr_bw = rgb2gray(fr);       % convert frame to grayscale
    %bg_static=X_bg_static(:,:,i);
    [ssim_num,~,~,~]=SSIM(fr_bw,bg_bw);
    fr_diff = abs(double(fr_bw) - double(bg_bw));  % cast operands as double to avoid negative overflow
    bg_static = X_bg_bw(:,:,i);
    bg_diff = abs(double(fr_bw) - double(bg_static));
    for j=1:width                 % if fr_diff > thresh pixel in foreground
        for k=1:height
            if ((fr_diff(k,j) > thresh1*ssim_num))
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
    subplot(3,1,1),imshow(fr)
    subplot(3,1,1),imshow(fr_bw)
    subplot(3,1,2),imshow(uint8(diff_map))
    subplot(3,1,3),imshow(L)
    %writeVideo(obj_gray,im2frame(uint8(diff_map),gray));           % save movie as avi 
end
%baocunlujing='C:\Users\Administrator\Desktop\文档\保存图片\airport_gaosi.jpg';

imwrite(fr_bw,strcat('C:\Users\Administrator\Desktop\文档\保存图片\',wenjianming,'_input.jpg'));
imwrite(uint8(diff_map),strcat('C:\Users\Administrator\Desktop\文档\保存图片\',wenjianming,'_mask.jpg'));
L = mat2gray(L);
imwrite(L,strcat('C:\Users\Administrator\Desktop\文档\保存图片\',wenjianming,'_foreground.jpg'));