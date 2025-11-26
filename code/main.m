
clc; clear; close all;


img = imread('DB1\db1_01.jpg');

h = 260;
w = 190;
images = zeros(h*w, 15);
%images(:,1) = img(:);

for i = 1:16
    if (i == 10)
        continue;
    end

    filename = sprintf('DB1\\db1_%02d.jpg', i);
    img = imread(filename);
     % Resize till samma storlek
    img = rgb2gray(face_detection(img));

    j = i;
    if i > 10
        j = i-1;
    end

    images(:, j) = img(:);
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
eigenfaces = eigenfaces(:,1:15);
weights = eigenfaces' * A; % vikter hittade

%testade en bild för att se om den kan hitta närmaste bilden 
comparingface = 'DB1\db1_10.jpg';
comparingface = im2double(imread(comparingface));
comparingface = rgb2gray(face_detection(comparingface));
comparingfacezero = zeros(h*w, 1);
comparingfacezero(:,1) = comparingface(:);
comparingface = comparingfacezero - mean_face;
new_weights = eigenfaces' * comparingface;
distances = vecnorm(weights - new_weights, 2, 1);
[~,matchadbild] = min(distances);

svar = matchadbild;
if svar >= 10
    svar = svar+1;
end

svar













