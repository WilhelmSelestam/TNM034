function mouthMap = createMouthMap(I_ycbcr, face_mask)
    
    Cb = double(I_ycbcr(:,:,2));
    Cr = double(I_ycbcr(:,:,3));

    Cr_sq = Cr.^2;
    Cr_div_Cb = Cr ./ (Cb + eps);

    Cr_sq_norm = normalizeChannel(Cr_sq, face_mask);
    Cr_div_Cb_norm = normalizeChannel(Cr_div_Cb, face_mask);
    
    Cr_sq_masked = Cr_sq_norm(face_mask);
    Cr_div_Cb_masked = Cr_div_Cb_norm(face_mask);

    if isempty(Cr_sq_masked)
        mouthMap = zeros(size(Cr));
        return;
    end
    
    mean_Cr_sq = mean(Cr_sq_masked);
    mean_Cr_div_Cb = mean(Cr_div_Cb_masked);
    eta = 0.95 * (mean_Cr_sq / (mean_Cr_div_Cb + eps));
    
    map_component = Cr_sq_norm - eta .* Cr_div_Cb_norm;
    mouthMap = Cr_sq_norm .* (map_component.^2);
    
    mouthMap_dilated = imdilate(mouthMap, strel('disk', 5));
    mouthMap_final = mouthMap_dilated .* face_mask;
    
    mouthMap = mat2gray(mouthMap_final);
end
