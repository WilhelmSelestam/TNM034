function [imInWhitePatch] = toWhitePatch(im)
%Function to convert RGB image to White Patch

%RGB kanaler
RChannel = im(:,:,1);
GChannel = im(:,:,2);
BChannel = im(:,:,3);

%Hitta max-värdet i samtliga kanaler
maxR = max(max(im(:,:,1)));
maxG = max(max(im(:,:,2)));
maxB = max(max(im(:,:,3)));

%Räkna ut gain for kanaler
whiteGainForR = maxG/maxR;
whiteGainForG = maxB/maxB;

%Räkna ut nya R och G kanaler
whiteRChannel = whiteGainForR .* RChannel;
whiteGChannel = whiteGainForG .* GChannel;

%Sätta ihop den nya vitbalancerade bilden
imInWhitePatch = cat(3, whiteRChannel, whiteGChannel,BChannel);

end
