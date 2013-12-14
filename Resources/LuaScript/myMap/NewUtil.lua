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

--调整changeDirNode 的偏移位置即可 bg 的位置不会改变的 根据bg 确定所在的图层高度
function adjustNewHeight(mask2, width, ax, ay)
    local dk = ay*width+ax+1
    --数组从1开始编号
    print("ax ay obj offY !!!!!!!", ax, ay, offY, width, mask2[dk], dk)
    --[[
    if mask2[dk] then
        setPos(obj, {0, offY})
    else
        setPos(obj, {0, 0})
    end
    --]]
    return mask2[dk]
end

--点击时使用 点击坐标 到 网格坐标转化
--裂缝区域属于 斜坡区域 属于下一个层的区域 因此 裂缝区域属于下一个层
--第三个返回值 当前点是否在裂缝里面
--4是否在高地上面 如果在高地上面
--5 6 返回值 表明 相夹的裂缝另一个块
--在裂缝里面就属于
--
--#   #
-- # #
--  #  
--4 高度值
function cxyToAxyWithDepth(cx, cy, width, height, fixX, fixY, mask, cxyToAxyMap)
    local nx = math.floor(cx/SIZEX)
    local ny = math.floor(cy/SIZEY)

    local allV = cxyToAxyMap(getMapKey(nx,ny))
    if allV ~= nil then
        for k, v in ipairs(allV) do
            local hei = mask[v[2]*width+v[1]+1]
            local ncy = cy-hei*103
            local ax, ay = newCartesianToAffine(cx, ncy, width, height, fixX, fixY)
            if ax == v[1] and ay == v[2] then
                return ax, ay, hei
            end
        end
    end
    --没有找到包含的 菱形网格 在裂缝里面
    return nil 

    --[[
    local ax, ay = newCartesianToAffine(cx, cy, width, height, fixX, fixY)
    local dk = ay*width+ax+1
    if mask[dk] then
        --因为裂缝上面的网格都向上偏移了103 所以减去103 如果还在当前高度里面那么就在高地中
        cy = cy-103
        local nax, nay = newCartesianToAffine(cx, cy, width, height, fixX, fixY)
        local dk = nay*width+nax+1
        if mask[dk] then
            return nax, nay, false, true
        end
        return ax, ay, true, false, nax, nay
    end
    return ax, ay, false, false
    --]]
end

function axyToCxyWithDepth(ax, ay, width, height, fixX, fixY, mask)
    local dk = ay*width+ax+1
    local cx, cy = newAffineToCartesian(ax, ay, width, height, fixX, fixY)
    --print("axyToCxyWithDepth", ax, ay, cx, cy)
    cy = cy+103*mask[dk]
    return cx, cy
end

function tidToTile(tid)
    if tid < 65 then
        tid = tid-1
        return 'tile'..tid..'.png'
    else
        tid = tid-65
        return 'tile'..tid..".png"
    end
end
