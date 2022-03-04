function theta = calc_angle(x1,x2,use_deg)
    if nargin <3
        use_deg = true;
    end
    % check dim
    sz1 = size(x1); sz2 = size(x2);
    assert(length(sz1) == 2 & length(sz2)==2);
    
    % wrap to column vectors
    x1 = x1(:); x2 = x2(:);
    
    % calculate
    if use_deg % in degrees
        theta = acosd(dot(x1,x2)/norm(x1)/norm(x2));
    else % in radians
        theta = acos(dot(x1,x2)/norm(x1)/norm(x2));
    end
end