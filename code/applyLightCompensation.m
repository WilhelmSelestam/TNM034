% function img_corrected = applyLightCompensation(img)
%     img = im2double(img);
%     
%     avgR = mean(mean(img(:,:,1)));
%     avgG = mean(mean(img(:,:,2)));
%     avgB = mean(mean(img(:,:,3)));
%     avgGray = (avgR + avgG + avgB) / 3;
%     
%     aR = avgGray / avgR;
%     aG = avgGray / avgG;
%     aB = avgGray / avgB;
%     
%     img_corrected = img;
%     img_corrected(:,:,1) = img(:,:,1) * aR;
%     img_corrected(:,:,2) = img(:,:,2) * aG;
%     img_corrected(:,:,3) = img(:,:,3) * aB;
%     
%     img_corrected(img_corrected > 1) = 1;
% end


function img_corrected = applyLightCompensation(img)
    img = im2double(img);
    
    % standard "middle gray"
    desired_brightness = 0.5;
    
    avgR = mean(mean(img(:,:,1)));
    avgG = mean(mean(img(:,:,2)));
    avgB = mean(mean(img(:,:,3)));
    
    aR = desired_brightness / avgR;
    aG = desired_brightness / avgG;
    aB = desired_brightness / avgB;
    
    img_corrected1 = img;
    
    img_corrected1(:,:,1) = img(:,:,1) * aR;
    img_corrected1(:,:,2) = img(:,:,2) * aG;
    img_corrected1(:,:,3) = img(:,:,3) * aB;
    
    img_corrected1(img_corrected1 > 1) = 1;

    img_corrected = normalizeExposure(img_corrected1);
end