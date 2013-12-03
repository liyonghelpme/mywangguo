function newAffineToCartesian(ax, ay, width, height, fixX, fixY)
    ax, ay = width-ax-1, height-ay-1 
    local nx, ny = affineToNormal(ax, ay)
    local cx, cy = normalToCartesian(nx, ny)
    --屏幕中心位置 是真实的坐标
    cx = cx+fixX
    cy = cy+fixY
    return cx, cy
end

function newCartesianToAffine(cx, cy, width, height, fixX, fixY)
    cx = cx-fixX
    cy = cy-fixY
    local nx, ny = cartesianToNormal(cx, cy)
    local ax, ay = normalToAffine(nx, ny)
    return width-ax-1, height-ay-1 
end
