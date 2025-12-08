function img_norm = normalizeExposure(img)
    %img = im2double(img);
    current_mean = mean(img(:));
    target_mean = 0.5;
    
    if current_mean < 0.001
        scaling_factor = 1; 
    else
        scaling_factor = target_mean / current_mean;
    end
    
    img_norm = img * scaling_factor;
    img_norm(img_norm > 1) = 1;
end