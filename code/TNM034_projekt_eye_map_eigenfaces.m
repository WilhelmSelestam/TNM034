A = imread("DB1\db1_10.jpg");
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

% Visa resultat

figure;
subplot(3,2,1); imshow(A); title('Original');
subplot(3,2,2); imshow(A_balanced); title('Gray World Balanced');
subplot(3,2,3); imshow(EyeMapC_eq); title('Chroma Eye Map (C)');
subplot(3,2,4); imshow(EyeMapL); title('Luminance Eye Map (L)');
subplot(3,2,5); imshow(EyeMapCL); title('Combined Eye Map (C + L)');
subplot(3,2,6); imshow(EyeMap); title('Find Eyes');
%%
% Eigenfaces
filename = 'DB1\db1_01.jpg';
img = im2double(rgb2gray(imread(filename)));
% hitta en bra storlek på images först som sedan reshapes i loopen till
% behov
cropH = 400;
cropW = 300;

% Center coordinates
y1 = floor((h - cropH)/2) + 1;
x1 = floor((w - cropW)/2) + 1;

img = img(y1:y1+cropH-1, x1:x1+cropW-1, :);

imshow(img)
[h, w] = size(img);
images = zeros(h*w, 16);
images(:,1) = img(:);

for i = 2:16
    filename = sprintf('DB1\\db1_%02d.jpg', i);
    img = im2double(rgb2gray(imread(filename)));
     % Resize till samma storlek
    img = imresize(img, [h, w]);

    images(:, i) = img(:);
end

mean_face = mean(images, 2);
A = images - mean_face;
C = A' * A;
% D är eigenvalues i en diagonalmatris
[V, D] = eig(C);
eigenfaces = A * V;
% normalisera
for j = 1:size(eigenfaces,2)
    eigenfaces(:,j) = eigenfaces(:,j) / norm(eigenfaces(:,j));
end
% sorterat med descend från 16 och ner där jag tar alla eigenvektorer
[eigenvalues, order] = sort(diag(D), 'descend');
eigenfaces = eigenfaces(:, order);
eigenfaces = eigenfaces(:,1:16);
weights = eigenfaces' * A; % vikter hittade
% testade en bild för att se om den kan hitta närmaste bilden 
comparingface = 'DB1\db1_16.jpg';
comparingface = im2double(rgb2gray(imread(comparingface)));
comparingface = comparingface(y1:y1+cropH-1, x1:x1+cropW-1, :);
comparingfacezero = zeros(h*w, 1);
comparingfacezero(:,1) = comparingface(:);
comparingface = comparingfacezero - mean_face;
new_weights = eigenfaces' * comparingface;
distances = vecnorm(weights - new_weights, 2, 1);
[~,matchadbild] = min(distances);
%i = 1; % välj bild
%I = mean_face + eigenfaces * weights(:,i);

%figure;
%for i = 1:16
    %subplot(4,5,i); % arrange in a grid
    %imagesc(reshape(eigenfaces(:,i), h, w)); 
    %colormap gray;
%end
%ef = reshape(eigenfaces(:,1), [h, w]);
%figure; 
%imshow(mat2gray(ef));
%%
