A = imread("DB1\db1_01.jpg");
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

% Y-komponent (luminans)
Y = (R + G + B) / 3;

% Eye Map C 
EyeMapC = (1/3) * ((0.5*R.^2 + 0.15*G.^2 + 0.25*B.^2) ./ (Y.^2 + 0.01));
EyeMapC = mat2gray(EyeMapC); % normalisera mellan 0-1

% Histogramnormalisering

EyeMapC_eq = histeq(EyeMapC);
EyeMapC_eq = 1 - EyeMapC_eq;

% För att betona mörka områden mot ljusa delar
se = strel('disk', 5);
Y_dil = imdilate(Y, se);
Y_ero = imerode(Y, se);

EyeMapL = Y_dil ./ (Y_ero + 0.001).^0.05;
EyeMapL = (EyeMapL - min(EyeMapL(:))) / (max(EyeMapL(:)) - min(EyeMapL(:)) + eps);

% Kombinera EyeMap C och L

EyeMap = EyeMapC_eq .* EyeMapL;
EyeMap = (EyeMap - min(EyeMap(:))) / (max(EyeMap(:)) - min(EyeMap(:)) + eps);


threshold = 0.7;
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
kernel2 = strel('disk', 5);
EyeMap = imerode(EyeMap,kernel);
EyeMap = imdilate(EyeMap,kernel2);

% Visa resultat

figure;
subplot(2,2,1); imshow(A); title('Original');
subplot(2,2,2); imshow(A_balanced); title('Gray World Balanced');
subplot(2,2,3); imshow(EyeMapC_eq); title('Chroma Eye Map (C)');
subplot(2,2,4); imshow(EyeMap); title('Combined Eye Map (C + L)');
