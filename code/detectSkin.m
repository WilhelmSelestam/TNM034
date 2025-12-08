function skin_mask = detectSkin(I_ycbcr)

    %img = imgaussfilt(img, 1);

    Cb = double(I_ycbcr(:,:,2));
    Cr = double(I_ycbcr(:,:,3));
    Y = double(I_ycbcr(:,:,1));

    mask_Cb = (Cb >= 60) & (Cb <= 135);
    mask_Cr = (Cr >= 125) & (Cr <= 175);
    %skin_mask = mask_Cb & mask_Cr;

    imgHSV = rgb2hsv(ycbcr2rgb(I_ycbcr));
    H = imgHSV(:,:,1);
    S = imgHSV(:,:,2);

    %maskHSV = (H <= 0.15 | H >= 0.8) & (S >= 0.05 & S <= 0.95);
    %skin_mask = skin_mask & maskHSV;

    base_skin = (H <= 0.15 | H >= 0.8) & (S >= 0.05 & S <= 0.95);
    
    is_bright = Y > 0.8;
    pale_skin = is_bright & (H <= 0.15 | H >= 0.8) & (S >= 0.0);
    
    maskHSV_combined = base_skin | pale_skin;
    
    % Final Mask
    skin_mask = mask_Cb & mask_Cr & maskHSV_combined;

%     Cb = double(I_ycbcr(:,:,2));
%     Cr = double(I_ycbcr(:,:,3));
% 
%     mask_Cb = (Cb >= 77) & (Cb <= 127);
%     mask_Cr = (Cr >= 133) & (Cr <= 173);
%     skin_mask = mask_Cb & mask_Cr;
% 
%     imgHSV = rgb2hsv(ycbcr2rgb(I_ycbcr));
%     H = imgHSV(:,:,1);
%     S = imgHSV(:,:,2);
% 
%     maskHSV = (H <= 0.15 | H >= 0.95) & (S >= 0.2 & S <= 0.8);
%     
%     skin_mask = skin_mask & maskHSV;
    

    %{ 
    
    Y = double(I_ycbcr(:,:,1));
    Cb = double(I_ycbcr(:,:,2));
    Cr = double(I_ycbcr(:,:,3));

    Kl = 125;
    Kh = 188;
    Ymin = 16;
    Ymax = 235;
    
    W0cb = 46.97; 
    WLcb = 23; 
    WHcb = 14;
    W0cr = 38.76; 
    WLcr = 20; 
    WHcr = 10;
    
    Cb_prime = Cb;
    Cr_prime = Cr;

    mask_low = (Y < Kl);
    mask_high = (Y > Kh);

    Wcb_low = WLcb + (Kl - Y(mask_low)) .* (W0cb - WLcb) ./ (Kl - Ymin);
    Wcr_low = WLcr + (Kl - Y(mask_low)) .* (W0cr - WLcr) ./ (Kl - Ymin);
    
    Cb_bar_low = 108 + (Kl - Y(mask_low)) .* (118 - 108) ./ (Kl - Ymin);
    Cr_bar_low = 154 - (Kl - Y(mask_low)) .* (154 - 144) ./ (Kl - Ymin);

    Wcb_high = WHcb + (Y(mask_high) - Kh) .* (W0cb - WHcb) ./ (Ymax - Kh);
    Wcr_high = WHcr + (Y(mask_high) - Kh) .* (W0cr - WHcr) ./ (Ymax - Kh);

    Cb_bar_high = 108 + (Y(mask_high) - Kh) .* (118 - 108) ./ (Ymax - Kh);
    Cr_bar_high = 154 + (Y(mask_high) - Kh) .* (154 - 132) ./ (Ymax - Kh);
    
    Cb_prime(mask_low) = (Cb(mask_low) - Cb_bar_low) .* (W0cb ./ Wcb_low) + 108;
    Cr_prime(mask_low) = (Cr(mask_low) - Cr_bar_low) .* (W0cr ./ Wcr_low) + 154;

    Cb_prime(mask_high) = (Cb(mask_high) - Cb_bar_high) .* (W0cb ./ Wcb_high) + 108;
    Cr_prime(mask_high) = (Cr(mask_high) - Cr_bar_high) .* (W0cr ./ Wcr_high) + 154;

    cx = 109.38;
    cy = 152.02;
    theta = 2.53; % radians
    ecx = 1.60;
    ecy = 2.41;
    a = 25.39;
    b = 14.03;

    Cb_centered = Cb_prime - cx;
    Cr_centered = Cr_prime - cy;
    
    cos_theta = cos(theta);
    sin_theta = sin(theta);
    
    x_rot = cos_theta .* Cb_centered + sin_theta .* Cr_centered;
    y_rot = -sin_theta .* Cb_centered + cos_theta .* Cr_centered;

    ellipse_eq = ( (x_rot - ecx).^2 / a^2 ) + ( (y_rot - ecy).^2 / b^2 );
    
    skin_mask = ellipse_eq <= 1;
    %}
end