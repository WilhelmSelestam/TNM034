function ellipse_params = fitEllipse(face_mask)
    stats = regionprops(logical(face_mask), ...
             'Centroid', 'Orientation', 'MajorAxisLength', 'MinorAxisLength');
    
    if isempty(stats)
        ellipse_params = [];
    else
        % Return the stats for the largest detected blob
        ellipse_params = stats(1);
    end
end