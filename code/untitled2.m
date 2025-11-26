%%
for i = 1:length(face_candidates_stats)
    
    current_face_mask = false(size(skin_mask));
    current_face_mask(valid_pixel_lists{i}) = true;
    
    eyeMap = EyeMap(im2double(I_comp_ycbcr));
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