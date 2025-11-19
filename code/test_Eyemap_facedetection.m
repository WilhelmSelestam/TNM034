A = imread("DB1\db1_12.jpg");
I_orig = A;
A = im2double(A);

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




%I_orig = imrotate(I_orig, 10);
%imwrite(I_orig, 'rot.jpg')
I = im2double(I_orig);

I_ycbcr = rgb2ycbcr(I);
Y = I_ycbcr(:,:,1);

thresh = quantile(Y(:), 0.95); 
ref_mask = Y > thresh;

%Välj "White Patch" (1) eller "Grey World" (0)
normalisera = 1;

%Check för att se om bilden behöver vitbalanceras
if nnz(ref_mask) > 100 
        R = I(:,:,1);
        G = I(:,:,2);
        B = I(:,:,3);
        
        avg_R = mean(R(ref_mask));
        avg_G = mean(G(ref_mask));
        avg_B = mean(B(ref_mask));

    if normalisera == 1
        scale_R = 1.0 / avg_R;
        scale_G = 1.0 / avg_G;
        scale_B = 1.0 / avg_B;
    
        I_comp = zeros(size(I));
        I_comp(:,:,1) = I(:,:,1) * scale_R;
        I_comp(:,:,2) = I(:,:,2) * scale_G;
        I_comp(:,:,3) = I(:,:,3) * scale_B;
        
        I_comp(I_comp > 1) = 1;
    else
        gainForR = avg_G/avg_R;
        gainForG = avg_G/avg_B;
            
        %Räkna ut nya RChannel & GChannel med gainForR & gainForG
        R = gainForR .* R;
        G = gainForG .* G;
        
        I_comp = cat(3,R, G, B);
    end
else
    I_comp = I;
end


I_comp = im2uint8(I_comp);


%figure;
%subplot(1, 3, 1);
%imshow(I_orig);

%subplot(1, 3, 2);
%imshow(I_comp);

I_comp_ycbcr = rgb2ycbcr(I_comp);


skin_mask_raw = detectSkin(I_comp_ycbcr);

%imshow(skin_mask_raw);


se_open = strel('disk', 3);
skin_mask = imopen(skin_mask_raw, se_open);

se_close = strel('disk', 15);
skin_mask = imclose(skin_mask, se_close);

skin_mask = imfill(skin_mask, 'holes');

skin_mask = skin_mask.* EyeMap;
imshow(skin_mask);