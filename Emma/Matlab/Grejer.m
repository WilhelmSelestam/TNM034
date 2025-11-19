clc; clear; close all;

%im: Image of unknown face, RGB-image in uint8 format in the range [0,255]

%id: The identity number (integer) of the identidied person, i.e. '1', '2',
%..., '16' for the persons belonging to db1 and '0' for all other faces

%For Grade 3:
%Translation
%Rotation
%Scaling
%Tone value
%Combinations

%%
clc; clear; close all;
%Test

%%%%%%%%%%%%%%% Bild läses in %%%%%%%%%%%%%%%
im = imread("DB1\db1_02.jpg"); %Originalbilden läses in
newIm = im;

figure('Name','Steg 1: "Balancering" & RGB-uppdelning','NumberTitle','off');
subplot(2,3,1);
imshow(im);
title('Originalbild');


%%%%%%%%%%%%%% RGB Channels uppdelade %%%%%%%%%%%%%
RChannel = im(:,:,1);
GChannel = im(:,:,2);
BChannel = im(:,:,3);

subplot(2,3,4);
imshow(RChannel);
title('Red Channel');

subplot(2,3,5);
imshow(GChannel);
title('Green Channel');

subplot(2,3,6);
imshow(BChannel);
title('Blue Channel');


%%%%%%%%%%%%%%%%% AWB %%%%%%%%%%%%%%%%%%%%
%AWB, Automatic While Balancing
%Grey World

%Räkna ut medelvärdet för färgkanalerna
RMean = sum(mean(RChannel));
GMean = sum(mean(GChannel));
BMean = sum(mean(BChannel));

if RMean == GMean && RMean == Bmean && GMean == BMean
    disp('Bilden uppfyller Grey World redan, no adjustment needed :)');
else
    disp('Bilden uppfyller inte Grey World, adjustment needed :( eller :)');
    gainForR = GMean/RMean;
    gainForG = GMean/BMean;
    
    %Räkna ut nya RChannel & GChannel med gainForR & gainForG
    RChannel = gainForR .* RChannel;
    GChannel = gainForG .* GChannel;

    imInGreyWorld = cat(3,RChannel, GChannel, BChannel);
end

subplot(2,3,2);
imshow(imInGreyWorld);
title('Grey World');


%White patch

%Hitta max-värdet i samtliga kanaler
maxR = max(max(im(:,:,1)));
maxG = max(max(im(:,:,2)));
maxB = max(max(im(:,:,3)));

%Räkna ut gain for kanaler
whiteGainForR = maxG/maxR;
whiteGainForG = maxB/maxB;

%Räkna ut nya R och G kanaler
whiteRChannel = whiteGainForR .* RChannel;
whiteGChannel = whiteGainForG .* GChannel;

%Sätta ihop den nya vitbalancerade bilden
whitePatchIm = cat(3, whiteRChannel, whiteGChannel,BChannel);

%Visa ny vitbalancerad bild
subplot(2,3,3);
imshow(whitePatchIm);
title('White Patch');


%%%%%%%%%%%%%%%%%%% YCbCr & HSV %%%%%%%%%%%%%%%%%

%Trichromatic theory VS Opponent color theory
%Humans perceive four distinct opponent colors: red, green, yellow and blue
%Perceptual attributes: hue, saturation and brightness

%Different color spaces:
%RGB: RChannel, GChannel and BChannel
%YCbCr: Luminance, Red Chroma and Blue Chroma
%HSV: Hue, Saturation and Value

normaliseradBild = imInGreyWorld;

imInYCbCr = rgb2ycbcr(normaliseradBild);

imInHSV = rgb2hsv(normaliseradBild);

figure('Name','Steg 2: Olika color space','NumberTitle','off');
subplot(3,3,1);
imshow(im);
title('Original');

subplot(3,3,2);
imshow(imInYCbCr);
title('YCbCr');

subplot(3,3,3);
imshow(imInHSV);
title('HSV');

subplot(3,3,4);
imshow(imInYCbCr(:,:,1));
title('Y, Luminance');

subplot(3,3,5);
imshow(imInYCbCr(:,:,2));
title('Cb, Chroma Blue');

subplot(3,3,6);
imshow(imInYCbCr(:,:,3));
title('Cr, Chroma Red');

subplot(3,3,7);
imshow(imInHSV(:,:,1));
title('Hue');

subplot(3,3,8);
imshow(imInHSV(:,:,2));
title('Saturation');

subplot(3,3,9);
imshow(imInHSV(:,:,3));
title('Value');

%%%%%%%%%%%%%% Face Mask %%%%%%%%%%%%%%
%Face Mask, Morphological operations

%Maska ut ansikte
%Tröskla för att få en BW bild

imtoThresh = imInYCbCr(:,:,1)./3 + imInYCbCr(:,:,2)./3 + imInYCbCr(:,:,3)./3;

%imtoThresh = imtoThresh .* 255;

imGray = im2gray(imtoThresh);
imtoThresh = imGray;

% [imSizeRow, imSizeCol] = size(thresIm);
% newIm = zeros(imSizeRow,imSizeCol);
% threshold = 135;
% 
% for row = 1:imSizeRow
%    for col = 1:imSizeCol
%        if imtoThresh(row,col) < threshold
%            newIm(row,col) = 0;
%        else
%            newIm(row,col) = 255;
%        end
%    end
% end

lowpass = ones(5)/(5^2);

bfilt = imfilter(imtoThresh,lowpass,"symmetric");

threshhold = 120;
% The thresholded image
newIm = bfilt < threshhold;


innan = newIm;


SE = strel('disk',3);
newIm = imclose(newIm,SE);

figure(3);
imshow(newIm);

SE = strel('rectangle', [5 2]);
newIm = imerode(newIm, SE);

% SE = strel('sphere', 3);
% newIm = imerode(newIm, SE);
% 
% 
% SE = strel('disk',3);
% newIm = imclose(newIm,SE);

% %Draw an ellipse
% x = linspace(461, 376);
% y = linspace(461, 376);
% a = 100;
% b = 100;
% ellipssss = (x-a).^2 + (y-b).^2;
% figure(8);

%plot(ellipssss);



% newIm = imfill(newIm,'holes');


figure(6);
imshowpair(innan,newIm,'montage');
title('Försöker med skin mask');




%%
clc; clear; close all;
%Test

%%%%%%%%%%%%%%% Bild läses in %%%%%%%%%%%%%%%
im = imread("DB1\db1_02.jpg"); %Originalbilden läses in
originalIm = im;

% figure('Name','Steg 0: Originalbild','NumberTitle','off');
% subplot(1,3,1);
% imshow(originalIm);
% title('Originalbild');

newIm = toGreyWorld(im);
%newIm = toWhitePatch(im);


bonk = newIm;
bink = mean(mean(mean(newIm)));

%Få ut YCbCr & HSV
imInYCbCr = rgb2ycbcr(newIm);
imInHSV = rgb2hsv(newIm);

newIm = imInYCbCr(:,:,1)./3 + imInYCbCr(:,:,2)./3 + imInYCbCr(:,:,3)./3;

lpFilter= ones(5)/(5^2);

newIm = imfilter(newIm,lpFilter,"symmetric");


threshhold = bink + 5;
% The thresholded image
newIm = newIm < threshhold;


%%%%%%%%%%%%%% Face Mask %%%%%%%%%%%%%%
%Face Mask, Morphological operations

innan = newIm;

SE = strel('disk',8);
newIm = imdilate(newIm,SE);


% SE = strel('disk',3);
% newIm = imdilate(newIm,SE);

newIm = imfill(newIm,'holes');

newIm = newIm - innan;

SE = strel('disk',3);
newIm = imclose(newIm,SE);

SE = strel('disk',10);
newIm = imopen(newIm,SE);

newIm = imfill(newIm,'holes');
% 
% SE = strel('sphere',15);
% newIm = imopen(newIm,SE);



%%%%%%%%%%% Display plots %%%%%%%%%%%%%%

figure(1);
imshowpair(originalIm,newIm,'montage');
title('Originalbild & Skin Mask');




















