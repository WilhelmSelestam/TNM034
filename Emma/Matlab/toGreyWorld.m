function [imInGreyWorld] = toGreyWorld(im)
%%%% Function to convert RGB image to Grey World%%%%

%%%%%%%%%%%%%% RGB Channels uppdelade %%%%%%%%%%%%%
RChannel = im(:,:,1);
GChannel = im(:,:,2);
BChannel = im(:,:,3);

%Plots for RGB Channels
% subplot(2,3,4);
% imshow(RChannel);
% title('Red Channel');
% 
% subplot(2,3,5);
% imshow(GChannel);
% title('Green Channel');
% 
% subplot(2,3,6);
% imshow(BChannel);
% title('Blue Channel');

%Räkna ut medelvärdet för färgkanalerna
RMean = sum(mean(RChannel));
GMean = sum(mean(GChannel));
BMean = sum(mean(BChannel));

    if RMean == GMean && RMean == Bmean && GMean == BMean
        
    else
        gainForR = GMean/RMean;
        gainForG = GMean/BMean;
        
        %Räkna ut nya RChannel & GChannel med gainForR & gainForG
        RChannel = gainForR .* RChannel;
        GChannel = gainForG .* GChannel;
    
        imInGreyWorld = cat(3,RChannel, GChannel, BChannel);
    end

end