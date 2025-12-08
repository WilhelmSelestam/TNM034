
clc; clear; close all;

Directory = 'DB1\'; 
% Read images from Images folder
Imgs = dir(fullfile(Directory,'*.jpg'));
% for j=1:length(Imgs)
%     Img = imread(fullfile(Directory,Imgs(j).name));
% end

%img = imread('db2\il_16.jpg');

h = 260;
w = 190;
images = zeros(h*w, 16);
%images(:,1) = img(:);

for i = 1:16

    filename = imread(fullfile(Directory,Imgs(i).name));
    img = filename;
    
    I = applyLightCompensation(img);
    I_comp = im2uint8(I);
    I_comp_ycbcr = rgb2ycbcr(I_comp);
    
    skin_mask_raw = detectSkin(I_comp_ycbcr);
    % skin_mask_raw = detect_skin_face(I_comp);
    
    se_open = strel('disk', 3);
    skin_mask = imopen(skin_mask_raw, se_open);
    
    se_close = strel('disk', 15);
    skin_mask = imclose(skin_mask, se_close);
    
    skin_mask = imfill(skin_mask, 'holes');
    
    skin_mask_full = bwconvhull(skin_mask);

    subplot(4,4,i)
    imshow(skin_mask);


end
% 
% mean_face = mean(images, 2);
% A = images - mean_face;
% C = A' * A;
% % D är eigenvalues i en diagonalmatris
% [V, D] = eig(C);
% eigenfaces = A * V;
% % normalisera
% for j = 1:size(eigenfaces,2)
%     eigenfaces(:,j) = eigenfaces(:,j) / norm(eigenfaces(:,j));
% end
% % sorterat med descend från 16 och ner där jag tar alla eigenvektorer
% [eigenvalues, order] = sort(diag(D), 'descend');
% eigenfaces = eigenfaces(:, order);
% eigenfaces = eigenfaces(:,1:15);
% weights = eigenfaces' * A; % vikter hittade
% 
% %allDists = zeros(15, 15);
% %images(:,1) = img(:);
% 
% % for i = 1:16
% %     if (i == 10)
% %         continue;
% %     end
% 
% %testade en bild för att se om den kan hitta närmaste bilden 
% %comparingface = fullfile(Directory,Imgs(i).name);
% comparingface = 'Images\rot.jpg';
% comparingface = im2double(imread(comparingface));
% comparingface = rgb2gray(face_detection(comparingface));
% comparingfacezero = zeros(h*w, 1);
% comparingfacezero(:,1) = comparingface(:);
% comparingface = comparingfacezero - mean_face;
% new_weights = eigenfaces' * comparingface;
% distances = vecnorm(weights - new_weights, 2, 1);
% %allDists(:,i) = distances;
% if min(distances) < 5
%     [~,matchadbild] = min(distances);
% else
%     matchadbild = 0;
% end
%     
% % end
% 
% svar = matchadbild;
% if svar >= 10
%     svar = svar+1;
% end
% 
% svar
% 
% 
% 
% 
% 
% 





