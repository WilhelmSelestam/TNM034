clear
clc

% --- (PREVIOUS STEPS) ---
I = imread('db1_04.jpg');
I_ycbcr = rgb2ycbcr(I);
Y_channel = double(I_ycbcr(:,:,1));
skin_mask = detectSkin(I_ycbcr); % From first answer
cc = bwconncomp(skin_mask);
stats = regionprops(cc, 'Area', 'BoundingBox');

% Filter candidates (e.g., remove tiny regions)
min_face_area = 500;
valid_indices = [stats.Area] > min_face_area;
face_candidates_stats = stats(valid_indices);
valid_pixel_lists = cc.PixelIdxList(valid_indices);

% --- FINAL VERIFICATION LOOP ---
detected_faces = []; % Store final ellipse parameters
face_scores = [];

MIN_FACE_SCORE_THRESHOLD = 0.2; % You must tune this threshold!

for i = 1:length(face_candidates_stats)
    
    % 1. Create the specific face mask (FG) for this candidate
    current_face_mask = false(size(skin_mask));
    current_face_mask(valid_pixel_lists{i}) = true;
    
    % 2. Create the feature maps
    eyeMap = createEyeMap(I_ycbcr, current_face_mask);
    mouthMap = createMouthMap(I_ycbcr, current_face_mask);
    
    % 3. Run the verification
    [score, ellipse] = veifyFaceCandidate(eyeMap, mouthMap, Y_channel, current_face_mask);
    r
    % 4. If the score is high enough, save it as a detection
    if score > MIN_FACE_SCORE_THRESHOLD
        detected_faces = [detected_faces; ellipse];
        face_scores = [face_scores; score];
    end
end

% --- 5. Display Final Results ---
figure;
imshow(I);
title(['Final Detections: ' num2str(length(detected_faces)) ' faces']);

for i = 1:length(detected_faces)
    % Draw the ellipse
    drawEllipse(detected_faces(i));
end


% --- Helper function to draw an ellipse from regionprops ---
