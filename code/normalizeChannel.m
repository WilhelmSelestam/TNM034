function [norm_channel] = normalizeChannel(channel, mask)

    masked_vals = channel(mask);
    if isempty(masked_vals)
        norm_channel = zeros(size(channel));
        return;
    end
    
    minVal = min(masked_vals);
    maxVal = max(masked_vals);
    
    norm_channel = (channel - minVal) ./ (maxVal - minVal + eps);
    norm_channel = norm_channel * 255.0;
    
    norm_channel(norm_channel > 255) = 255;
    norm_channel(norm_channel < 0) = 0;
end