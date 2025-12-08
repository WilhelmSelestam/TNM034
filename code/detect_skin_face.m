function skin_mask = detect_skin_face(img)

    [rows, cols, ~] = size(img);

    ycbcr_img = rgb2ycbcr(img);
    Cb = double(ycbcr_img(:,:,2));
    Cr = double(ycbcr_img(:,:,3));
    
    m = [110; 150];
    C = [100, 50; 50, 100];
    C_inv = inv(C);
    
    skin_prob_map = zeros(rows, cols);

    for i = 1:rows
        for j = 1:cols
            x = [Cb(i,j); Cr(i,j)];
            diff = x - m;
            exponent = -0.5 * (diff' * C_inv * diff);
            skin_prob_map(i,j) = exp(exponent);
        end
    end
    
    % Normalize map to 0-1 for image processing
    skin_prob_map = mat2gray(skin_prob_map);

    enhanced_map = histeq(skin_prob_map);
    
    level = graythresh(enhanced_map);
    binary_mask = imbinarize(enhanced_map, level);

    [L, num] = bwlabel(binary_mask);
    stats = regionprops(L, 'Area', 'BoundingBox', 'EulerNumber', 'Extent');
    
    final_mask = ismember(L, 0);
    
    for k = 1:num
        keep_region = true;
        
        if stats(k).EulerNumber >= 1 
             keep_region = false;
        end
        
        width = stats(k).BoundingBox(3);
        height = stats(k).BoundingBox(4);
        
        aspect_ratio = height / width; 
        
        if aspect_ratio < 0.8 || aspect_ratio > 2.0
            keep_region = false;
        end
        
        if stats(k).Area < 400
            keep_region = false;
        end
        
        if width < 20 || height < 20
            keep_region = false;
        end
        
        if keep_region
            final_mask = final_mask | (L == k);
        end
    end
    
    skin_mask = final_mask;
    
end