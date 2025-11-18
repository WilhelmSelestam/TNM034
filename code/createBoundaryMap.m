% This function creates the boundary map as described in the paper
function boundaryMap = createBoundaryMap(Y_channel, face_mask)
    % Get the luma gradient magnitude
    [Gmag, ~] = imgradient(Y_channel, 'sobel');
    
    % Mask it to the face region
    boundaryMap = Gmag .* face_mask;
    
    % Threshold to get distinct edges
    if any(boundaryMap(:))
        threshold = mean(boundaryMap(face_mask)) + 0.5 * std(boundaryMap(face_mask));
        boundaryMap = boundaryMap > threshold;
    end
end

