function eyeMap = createEyeMap(I_ycbcr, face_mask)
    
    Y = double(I_ycbcr(:,:,1));
    Cb = double(I_ycbcr(:,:,2));
    Cr = double(I_ycbcr(:,:,3));

    Cb_norm = normalizeChannel(Cb, face_mask);
    Cr_norm = normalizeChannel(Cr, face_mask);

    Cb_sq = (Cb_norm / 255).^2;
    Cr_tilde = (255 - Cr_norm);
    Cr_tilde_sq = (Cr_tilde / 255).^2;
    
    Cb_div_Cr = (Cb_norm + 1) ./ (Cr_norm + 1);
    
    EyeMapC = (Cb_sq + Cr_tilde_sq + Cb_div_Cr);
    
    EyeMapC = histeq(mat2gray(EyeMapC));

    se = strel('disk', 2);
    
    Y_dilated = imdilate(Y, se);
    Y_eroded = imerode(Y, se);
    
    EyeMapL = Y_dilated ./ (Y_eroded + 1);


    eyeMap = EyeMapL .* EyeMapC;
    
    eyeMap_dilated = imdilate(eyeMap, strel('disk', 5));
    eyeMap_final = eyeMap_dilated .* face_mask;
    
    eyeMap = mat2gray(eyeMap_final);
end


