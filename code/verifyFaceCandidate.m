function [best_score, best_ellipse, best_e1, best_e2] = verifyFaceCandidate(eyeMap, mouthMap, Y, face_mask)
    MAX_EYE_ANGLE_DEG = 10; % 5% på db2 -> kanske sätta gränsen på 10% ??????
    MIN_MOUTH_BELOW_EYES = 0.1;
    MAX_MOUTH_X_OFFSET = 0.4;
    RATIO_EYE_MOUTH_MIN = 0.8;
    RATIO_EYE_MOUTH_MAX = 1.8;
    
    best_score = 0;
    best_ellipse = [];

    best_e1 = [];
    best_e2 = [];

    eye_thresh = quantile(eyeMap(face_mask), 0.90);
    mouth_thresh = quantile(mouthMap(face_mask), 0.90);
    
    eye_blobs_mask = (eyeMap > eye_thresh) & face_mask;
    %figure(25)
    %imshow(eye_blobs_mask)
    mouth_blobs_mask = (mouthMap > mouth_thresh) & face_mask;
    %imshow(mouth_blobs_mask)
        
    eye_stats = regionprops(bwconncomp(eye_blobs_mask), eyeMap, 'Centroid', 'MeanIntensity');
    mouth_stats = regionprops(bwconncomp(mouth_blobs_mask), mouthMap, 'Centroid', 'MeanIntensity');

    num_eyes = length(eye_stats);
    num_mouths = length(mouth_stats);

    if num_eyes < 2 || num_mouths < 1
        return;
    end

    boundaryMap = edge(Y, 'sobel');
    boundaryMap = boundaryMap & face_mask;

    for i = 1:num_eyes
        for j = i+1:num_eyes
            for k = 1:num_mouths
                
                e1 = eye_stats(i).Centroid;
                e2 = eye_stats(j).Centroid;
                m = mouth_stats(k).Centroid;

                eye_mid = (e1 + e2) / 2;
                eye_dist = norm(e1 - e2);
                eye_angle_rad = atan2(e2(2) - e1(2), e2(1) - e1(1));
                eye_angle_deg = rad2deg(eye_angle_rad);

                if abs(eye_angle_deg) > MAX_EYE_ANGLE_DEG
                    continue;
                end

                mouth_y_offset = m(2) - eye_mid(2);
                if mouth_y_offset < (MIN_MOUTH_BELOW_EYES * eye_dist)
                    continue;
                end
                
                mouth_x_offset = abs(m(1) - eye_mid(1));
                if mouth_x_offset > (MAX_MOUTH_X_OFFSET * eye_dist)
                    continue;
                end

                eye_mouth_dist = norm(eye_mid - m);
                ratio = eye_mouth_dist / eye_dist;
                if ratio < RATIO_EYE_MOUTH_MIN || ratio > RATIO_EYE_MOUTH_MAX
                    continue;
                end

                score_map = (eye_stats(i).MeanIntensity + eye_stats(j).MeanIntensity + mouth_stats(k).MeanIntensity) / 3;
                
                score_orientation = (1 - (abs(eye_angle_deg) / 90)) * 0.7;

                center_x = eye_mid(1);
                center_y = eye_mid(2) + 0.4 * eye_mouth_dist;
                major_axis = 2.0 * eye_mouth_dist;
                minor_axis = 1.6 * eye_dist;
                theta = eye_angle_rad;
                
                current_ellipse = [center_x, center_y, minor_axis, major_axis, theta];
                
                [X_coords, Y_coords] = getEllipsePixels(current_ellipse, size(Y));
                
                valid_idx = Y_coords >= 1 & Y_coords <= size(Y, 1) & ...
                            X_coords >= 1 & X_coords <= size(Y, 2);
                if ~any(valid_idx), continue; end
                
                lin_idx = sub2ind(size(Y), Y_coords(valid_idx), X_coords(valid_idx));
                
                score_boundary = sum(boundaryMap(lin_idx)) / length(lin_idx);

                total_score = (0.4 * score_map) + (0.4 * score_boundary) + (0.2 * score_orientation);

                if total_score > best_score
                    best_score = total_score;
                    best_ellipse = current_ellipse;
                    best_e1 = e1;
                    best_e2 = e2;
                end
            end
        end
    end
end



%% --- HELPER FUNCTION 1: Get Ellipse Pixels ---
function [X_coords, Y_coords] = getEllipsePixels(ellipse_params, imgSize)
    % Generates X, Y coordinates for pixels on an ellipse's perimeter
    % This is for the "Ellipse Vote"
    
    cx = ellipse_params(1);
    cy = ellipse_params(2);
    a = ellipse_params(3) / 2;
    b = ellipse_params(4) / 2;
    theta = ellipse_params(5);

    t = linspace(0, 2*pi, 100);
    
    x = cx + a * cos(t) * cos(theta) - b * sin(t) * sin(theta);
    y = cy + a * cos(t) * sin(theta) + b * sin(t) * cos(theta);
    
    X_coords = round(x);
    Y_coords = round(y);
    
    % Ensure no duplicates
    [~, idx] = unique(sub2ind(imgSize, max(1,min(Y_coords,imgSize(1))), max(1,min(X_coords,imgSize(2)))));
    X_coords = X_coords(idx);
    Y_coords = Y_coords(idx);
end

%% --- HELPER FUNCTION 2: Draw Ellipse ---
function drawEllipse(ellipse_params)
    % Draws the ellipse on the current figure
    
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