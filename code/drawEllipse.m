function drawEllipse(params)
    t = linspace(0, 2*pi, 50); % 50 points around ellipse
    
    % Get ellipse parameters
    a = params.MajorAxisLength / 2;
    b = params.MinorAxisLength / 2;
    xc = params.Centroid(1);
    yc = params.Centroid(2);
    phi = -deg2rad(params.Orientation); % Orientation is in degrees
    
    % Parametric equation for a rotated ellipse
    x = xc + a * cos(t) * cos(phi) - b * sin(t) * sin(phi);
    y = yc + a * cos(t) * sin(phi) + b * sin(t) * cos(phi);
    
    hold on;
    plot(x, y, 'g', 'LineWidth', 2);
    hold off;
end