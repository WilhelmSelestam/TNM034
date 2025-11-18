function [is_valid, geom_data] = checkTriangleGeometry(e1, e2, m)
    % e1, e2, m are [x, y] coordinates
    is_valid = false;
    geom_data = struct();

    % --- 1. Calculate key positions and distances ---
    eye_midpoint = (e1 + e2) / 2;
    eye_distance = norm(e1 - e2);
    eye_mouth_distance = norm(eye_midpoint - m);

    % --- 2. Run geometric checks ---
    
    % Check 1: Points must be distinct and not too close
    if eye_distance < 10 || eye_mouth_distance < 5
        return; % Invalid, too small
    end
    
    % Check 2: Eyes should be roughly horizontal
    % (Angle of the eye-line)
    eye_angle_rad = atan2(e2(2) - e1(2), e2(1) - e1(1));
    eye_angle_deg = abs(rad2deg(eye_angle_rad));
    
    % A horizontal line is 0 or 180 deg. We allow a 30-degree tilt.
    if eye_angle_deg > 30 && eye_angle_deg < 150
        return; % Invalid, too tilted
    end
    
    % Check 3: Mouth must be below the eye midpoint
    if m(2) <= eye_midpoint(2)
        return; % Invalid, mouth is above eyes
    end
    
    % Check 4: Mouth should be centered (e.g., within 50% of eye-dist)
    mouth_x_offset = abs(m(1) - eye_midpoint(1));
    if mouth_x_offset > (eye_distance * 0.5)
        return; % Invalid, mouth is too far to the side
    end
    
    % Check 5: Check aspect ratio (eye-dist / eye-mouth-dist)
    % A typical face ratio is ~1.0-2.0
    aspect_ratio = eye_distance / eye_mouth_distance;
    if aspect_ratio < 0.8 || aspect_ratio > 2.5
        return; % Invalid, triangle shape is wrong
    end

    % --- If all checks pass ---
    is_valid = true;
    geom_data.eye_midpoint = eye_midpoint;
    geom_data.mouth_pos = m;
    geom_data.eye_angle_deg = eye_angle_deg;
    geom_data.scale = eye_distance; % Use eye-distance as a scale factor
end