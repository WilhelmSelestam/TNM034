function EyeMap = EyeMap(A)

% RGB kanaler
R = A(:,:,1);
G = A(:,:,2);
B = A(:,:,3);

% medelvärde för varje kanal
meanR = mean(R(:));
meanG = mean(G(:));
meanB = mean(B(:));

% medelvärde
meanGray = (meanR + meanG + meanB) / 3;

% skalningsfaktorer
scaleR = meanGray / meanR;
scaleG = meanGray / meanG;
scaleB = meanGray / meanB;

% skala varje kanal
R_balanced = R * scaleR;
G_balanced = G * scaleG;
B_balanced = B * scaleB;

% gör det till en bild
A_balanced = cat(3, R_balanced, G_balanced, B_balanced);

% Klipp värden mellan [0, 1]
A_balanced = min(max(A_balanced, 0), 1);

% Chroma Eye Map (Eye Map C)

R = A_balanced(:,:,1);
G = A_balanced(:,:,2);
B = A_balanced(:,:,3);
% luminans
Yrgb = (R + G + B) / 3;
YCbCr = rgb2ycbcr(A_balanced);
Y  = YCbCr(:,:,1);
Cb = YCbCr(:,:,2);
Cr = YCbCr(:,:,3);


% Eye Map C 
%EyeMapC = (1/3) * ((0.5*R.^2 + 0.15*G.^2 + 0.25*B.^2) ./ (Yrgb.^2 + 0.01));
EyeMapC = (1/3) * (Cb.^2 + (1 - Cr).^2 + (Cb ./ (Cr + 0.01)));

EyeMapC = mat2gray(EyeMapC); % normalisera mellan 0-1


% Histogramnormalisering

EyeMapC_eq = histeq(EyeMapC);

% För att betona mörka områden mot ljusa delar
se = strel('disk', 3);
Y_dilate = imdilate(Y, se);
Y_erode = imerode(Y, se);

EyeMapL = Y_dilate ./ (Y_erode + 0.01);
EyeMapL = mat2gray(EyeMapL);

% Kombinera EyeMap C och L

EyeMap = EyeMapC_eq .* EyeMapL;
EyeMap = mat2gray(EyeMap);

EyeMapCL = EyeMap;
threshold = 0.4;
[imSizerow,imSizecol] = size(EyeMap);
for row = 1: imSizerow
for col = 1: imSizecol
    if EyeMap(row,col) > threshold
        EyeMap(row,col) = 1;
    else EyeMap(row,col) = 0;
    end
end
end
kernel = strel('disk',1);
kernel2 = strel('disk', 6);
EyeMap = imerode(EyeMap,kernel);
EyeMap = imdilate(EyeMap,kernel2);


