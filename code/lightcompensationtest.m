clc;
clear;
close all;



img = 'DB1\db1_01.jpg';
img = (imread(img));

comparingface = img .* 0.7;
comparingface = applyLightCompensation(comparingface);
subplot(1,5,1)
imshow(comparingface);

comparingface = img .* 1.3;
comparingface = applyLightCompensation(comparingface);
hej = comparingface - im2double(img);
sum(sum(im2gray(hej)))
subplot(1,5,2)
imshow(comparingface);


comparingface = img .* 1.4;
comparingface = applyLightCompensation(comparingface);
subplot(1,5,3)
imshow(comparingface);

comparingface = img .* 1.3;
comparingface = applyLightCompensation(comparingface);
subplot(1,5,4)
imshow(comparingface);




comparingface = applyLightCompensation(img);
subplot(1,5,5)
imshow(comparingface);



