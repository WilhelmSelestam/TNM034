clc; clear; close all;

I_orig = imread('DB1/db1_12.jpg');
%I_orig = imrotate(I_orig, 10);
%imwrite(I_orig, 'rot.jpg')
I = im2double(I_orig);

I_ycbcr = rgb2ycbcr(I);
Y = I_ycbcr(:,:,1);

thresh = quantile(Y(:), 0.95); 
ref_mask = Y > thresh;

%Välj "White Patch" (1) eller "Grey World" (0)
normalisera = 0;

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


skin_mask = detectSkin(I_comp_ycbcr);

%imshow(skin_mask);


se_open = strel('disk', 3);
skin_mask_opened = imopen(skin_mask, se_open);

se_close = strel('disk', 15);
skin_mask_final = imclose(skin_mask_opened, se_close);

skin_mask_final = imfill(skin_mask_final, 'holes');

skin_mask = skin_mask_final;

skin_mask = bwconvhull(skin_mask);

figure('Name','Skin mask','NumberTitle','off');
imshow(skin_mask);
title('Skin mask'); %Visar inte titeln, vet inte varför

cc = bwconncomp(skin_mask);
stats = regionprops(cc, 'BoundingBox', 'Area');

min_face_area = 500;
max_face_area = size(skin_mask, 1) * size(skin_mask, 2) * 1.75;

valid_indices = [stats.Area] > min_face_area & [stats.Area] < max_face_area;
face_candidates_stats = stats(valid_indices);


face_candidate_boxes = cat(1, face_candidates_stats.BoundingBox);

valid_pixel_lists = cc.PixelIdxList(valid_indices);

eyeMap = createEyeMap(I_comp_ycbcr, skin_mask);
imshow(eyeMap)



detected_faces = [];
face_scores = [];
e1 = [];
e2 = [];

MIN_FACE_SCORE_THRESHOLD = 0.1; % ????????

for i = 1:length(face_candidates_stats)
    
    current_face_mask = false(size(skin_mask));
    current_face_mask(valid_pixel_lists{i}) = true;

    %imshow(current_face_mask)
    
    eyeMap = createEyeMap(I_comp_ycbcr, current_face_mask);
    mouthMap = createMouthMap(I_comp_ycbcr, current_face_mask);
    
    [score, ellipse, e1, e2] = verifyFaceCandidate(eyeMap, mouthMap, Y, current_face_mask);
    
    if score > MIN_FACE_SCORE_THRESHOLD
        detected_faces = [detected_faces; ellipse];
        face_scores = [face_scores; score];
        e1 = e1;
        e2 = e2;
    end
end

figure;
imshow(I);
title(['Final Detections: ' num2str(size(detected_faces, 1)) ' face(s)']);

e1
e2
score
ellipse

detected_faces

line([e1(1), e2(1)], [e1(2), e2(2)], 'Color', 'yellow', 'LineWidth', 2);

for i = 1:size(detected_faces, 1)
    %drawEllipse(detected_faces(i));
    drawEllipse(detected_faces(i, :));
end





%%
for i = 1:length(face_candidates_stats)
    
    current_face_mask = false(size(skin_mask));
    current_face_mask(valid_pixel_lists{i}) = true;
    
    eyeMap = createEyeMap(I_comp_ycbcr, current_face_mask);
    imshow(eyeMap)
    mouthMap = createMouthMap(I_comp_ycbcr, current_face_mask);
    
    bbox = face_candidates_stats(i).BoundingBox;
    
    figure;
    subplot(2, 2, 1);
    imshow(imcrop(I, bbox));
    title(['Candidate ' num2str(i)]);
    
    subplot(2, 2, 2);
    imshow(imcrop(eyeMap, bbox));
    title('Eye Map');
    
    subplot(2, 2, 3);
    imshow(imcrop(mouthMap, bbox));
    title('Mouth Map');

    subplot(2, 2, 4);
    imshow(imcrop(current_face_mask, bbox));
    title('Face Mask');
end















%%

figure;
imshow(I_comp);
title('Face Candidates from Skin Grouping');
hold on;

for k = 1:size(face_candidate_boxes, 1)
    bbox = face_candidate_boxes(k, :);
    rectangle('Position', bbox, 'EdgeColor', 'r', 'LineWidth', 2);
end
    

%%






function drawEllipse(ellipse_params)
    
    cx = ellipse_params(1);
    cy = ellipse_params(2);
    a = ellipse_params(3) / 2;
    b = ellipse_params(4) / 2;
    theta = ellipse_params(5);

    t = linspace(0, 2*pi, 100);
    
    x = cx + a * cos(t) * cos(theta) - b * sin(t) * sin(theta);
    y = cy + a * cos(t) * sin(theta) + b * sin(t) * cos(theta);
    
    hold on;
    plot(x, y, 'g', 'LineWidth', 2);
    hold off;
end



