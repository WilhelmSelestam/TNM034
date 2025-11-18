function [points, values] = findFeaturePoints(featureMap, max_points, min_threshold)
    % Find all local peaks in the map
    peaks_mask = imregionalmax(featureMap);
    
    % Get the (row, col) coordinates of the peaks
    [peak_y, peak_x] = find(peaks_mask);
    
    % Get the brightness values at those peak locations
    peak_values = featureMap(peaks_mask);
    
    % Filter out peaks that are below our minimum threshold
    strong_indices = (peak_values >= min_threshold);
    peak_x = peak_x(strong_indices);
    peak_y = peak_y(strong_indices);
    peak_values = peak_values(strong_indices);
    
    % Sort the strong peaks by value, from highest to lowest
    [sorted_values, sort_order] = sort(peak_values, 'descend');
    sorted_x = peak_x(sort_order);
    sorted_y = peak_y(sort_order);
    
    % Keep only the top 'max_points'
    num_to_keep = min(length(sorted_values), max_points);
    
    values = sorted_values(1:num_to_keep);
    points = [sorted_x(1:num_to_keep), sorted_y(1:num_to_keep)]; % [x, y]
end