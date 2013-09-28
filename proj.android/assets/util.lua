local sim = require "SimpleJson"
function registerMultiTouch(obj)
    --x y id x y id  x y id
    local function onTouch(eventType, touches)
        --print("onTouch", eventType, sim:encode(touches))
        --[[
        table.insert(touches, 400)
        table.insert(touches, 200)
        table.insert(touches, 1)
        --]]
        if eventType == "began" then   
            return obj:touchesBegan(touches)
        elseif eventType == "moved" then
            return obj:touchesMoved(touches)
        elseif eventType == "ended" then
            return obj:touchesEnded(touches)
        elseif eventType == "cancelled" then
        end
    end
    --single Touch
    obj.bg:registerScriptTouchHandler(onTouch, true, kCCMenuHandlerPriority, true)
    obj.bg:setTouchEnabled(true)
end
function registerTouch(obj)
    local function onTouch(eventType, x, y)
        if eventType == "began" then   
            return obj:touchBegan(x, y)
        elseif eventType == "moved" then
            return obj:touchMoved(x, y)
        else
            return obj:touchEnded(x, y)
        end
    end
    --single Touch
    obj.bg:registerScriptTouchHandler(onTouch, false, kCCMenuHandlerPriority, true)
    obj.bg:setTouchEnabled(true)
end
function registerUpdate(obj, interval)
    if not interval then
        interval = 0
    end
    local function update(diff)
        obj:update(diff)
    end
    obj.updateFunc = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(update, interval, false)
end
function registerEnterOrExit(obj)
    local function onEnterOrExit(tag)
        if tag == 'enter' then
            obj:enterScene()
        elseif tag == 'exit' then
            if obj.updateFunc ~= nil then
                CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(obj.updateFunc)
            end
            obj:exitScene()
        end
    end
    obj.bg:registerScriptHandler(onEnterOrExit)
end

function round(x)
    local t
    if x >= 0.0 then
        t = math.ceil(x)
        if t-x > 0.50000000001 then
            t = t - 1
        end
    else
        t = math.ceil(-x)
        if t+x > 0.50000000001 then
            t = t - 1
        end
        t = -t
    end
    return t
end

function roundGridPos(x, y)
    return {round(x/16)*16, round(y/16)*16}
end

function getGrid(x, y)
    return {round(x/16), round(y/16)}
end
function getSign(v)
    if v > 0 then
        return 1
    elseif v < 0 then
        return -1
    else
        return 0
    end
end
function runAction(obj, act)
    if obj.curAction ~= act then
        if obj.curAction ~= nil then
            obj.bg:stopAction(obj.curAction)
        end

        obj.curAction = act
        if act ~= nil then
            obj.bg:runAction(act)
        end
    end
end

function gridToSoldierPos(x, y)
    return {x*16+8, y*16+8}
end
function soldierPosToGrid(x, y)
    return getGrid(x-8, y-8)
end


function xyToKey(x, y)
    return x*100000+y
end
function keyToXY(key)
    return math.floor(key/100000), math.floor(key%100000)
end
function reverse(a)
    local temp = {}
    for i=#a, 1, -1 do
        table.insert(temp, a[i])
    end
    return temp
end

function magnitude(v)
    local len = math.sqrt(v[1]*v[1]+v[2]*v[2])
    return len
end

function normalize(v)
    local len = math.sqrt(v[1]*v[1]+v[2]*v[2])
    return {v[1]/len, v[2]/len}
end

function truncate(v, maxv)
    local len = math.sqrt(v[1]*v[1]+v[2]*v[2])
    if len == 0 then
        return {v[1], v[2]}
    end
    local nv = math.min(len, maxv)
    local cof = nv/len
    return {v[1]*cof, v[2]*cof}
end

function distance2(a, b)
    local dx, dy = a[1]-b[1], a[2]-b[2]
    return dx*dx+dy*dy
end
function distance(a, b)
    local dx, dy = a[1]-b[1], a[2]-b[2]
    return math.sqrt(dx*dx+dy*dy)
end
function scaleBy(v, s)
    return {v[1]*s, v[2]*s}
end
--短方法链
function setSize(sp, size)
    local sz = sp:getContentSize()
    sp:setScaleX(size[1]/sz.width)
    sp:setScaleY(size[2]/sz.height)
    return sp
end
function setContentSize(sp, sz)
    sp:setContentSize(CCSizeMake(sz[1], sz[2]))
    return sp
end

function setAnchor(sp, anchor)
    sp:setAnchorPoint(ccp(anchor[1], anchor[2]))
    return sp
end
--相对局部坐标就不对了
function setPos(sp, pos)
    sp:setPosition(ccp(pos[1], pos[2]))
    return sp
end
function setColor(sp, color)
    sp:setColor(ccc3(color[1], color[2], color[3]))
    if #color == 4 then
        sp:setOpacity(color[4])
    end
    return sp
end
function addSprite(bg, name)
    local sp
    if name == nil then
        sp = CCSprite:create()
    else
        sp = CCSprite:create(name)
    end
    bg:addChild(sp)
    return sp
end
--如果anchorY 是 0.5 则不用修正 sy了
function fixY(hei, y, sy, ay)
    if ay == nil then
        return hei-(y+sy)
    else
        return hei-(y)
    end
end
function addAction(bg, act)
    bg:runAction(act)
    return bg
end
function repeatForever(act)
    return CCRepeatForever:create(act)
end
function rotateby(t, ang)
    return CCRotateBy:create(t/1000, ang)
end
function frames(pattern, begin, last)
    local allFrame = CCArray:create()
    --如果不是plist 文件则 spriteFrames 没有办法复用 addSpriteFrame
    --单个图片文件 只能使用 
    local spc = CCSpriteFrameCache:sharedSpriteFrameCache()
    for i=begin, last, 1 do
        local fn = string.format(pattern, i)
        local frame = spc:spriteFrameByName(fn)
        if frame == nil then
            local tex = CCTextureCache:sharedTextureCache():addImage(fn)
            local sz = tex:getContentSize()
            local rect = CCRectMake(0, 0, sz.width, sz.height) 
            local sf = CCSpriteFrame:createWithTexture(tex, rect)
            frame = sf
        end
        print("frame", frame, fn)
        allFrame:addObject(frame)
    end
    return allFrame
end

function animate(t, arr)
    local count = arr:count() 
    local animation = CCAnimation:createWithSpriteFrames(arr, t/1000/count)
    local ani = CCAnimate:create(animation)
    return ani
end

--修正主picture 在images 文件夹
--修正key --->xxx.plist/x.png
--降低资源包
function addPlistSprite(name)
    --print("addPlistSprite", name)
    local dict = CCDictionary:createWithContentsOfFile('images/'..name)
    local metaData = tolua.cast(dict:objectForKey("metadata"), 'CCDictionary')
    local texturePath = metaData:valueForKey("textureFileName"):getCString()
    texturePath = 'images/'..texturePath
    local texture = CCTextureCache:sharedTextureCache():addImage(texturePath)
    local frames = tolua.cast(dict:objectForKey("frames"), "CCDictionary")
    local allKeys = frames:allKeys()
    local count = allKeys:count()
    local newFrames = CCDictionary:create()
    for i=0, count-1, 1 do
        local key = tolua.cast(allKeys:objectAtIndex(i), "CCString")
        local obj = frames:objectForKey(key:getCString())
        local cstr = key:getCString()
        local newName = name.."/"..cstr
        --print("newName", newName)
        newFrames:setObject(obj, newName)
    end
    --使用plist 文件名来区分不同的 frames
    dict:setObject(newFrames, "frames")

    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithDictionary(dict, texture)
end

local initYet = false
function altasWord(c, s)
    local n = CCNode:create()
    local plist = c..'.plist'
    if not initYet then
        addPlistSprite("yellow.plist")
        addPlistSprite("red.plist")
        --[[
        CCSpriteFrameCache:addSpriteFrameWithFile("yellow.plist")
        CCSpriteFrameCache:addSpriteFrameWithFile("blue.plist")
        CCSpriteFrameCache:addSpriteFrameWithFile("white.plist")
        CCSpriteFrameCache:addSpriteFrameWithFile("bold.plist")
        CCSpriteFrameCache:addSpriteFrameWithFile("red.plist")
        --]]
    end
    local offX = 0
    local hei = 0
    for i=1, #s, 1 do
        local w = s:sub(i,i)
        if w == "+" then
            w = 'plus'
        elseif w == '-' then
            w = 'minus'
        elseif w == '%' then
            w = 'percent'
        end
        local png = CCSprite:createWithSpriteFrameName(plist.."/"..w..'.png')   
        setAnchor(setPos(png, {offX, 0}), {0, 0})
        n:addChild(png)
        local si = png:getContentSize()
        offX = offX + si.width
        hei = si.height
    end
    n:setContentSize(CCSizeMake(offX, hei))
    return n
end

function removeSelf(obj)
    obj:removeFromParentAndCleanup(true)
end
function convertMultiToArr(touches)
    local lastPos = {}
    local ids = {}
    local x, y
    local count = 0
    for i, v in ipairs(touches) do
        if (i-1) % 3 == 0 then
            x = v
        elseif (i-1) % 3 == 1 then
            y = v
        else 
            lastPos[v] = {x, y}
            count = count+1
            table.insert(ids, v)
        end
    end 
    --从0 开始排序touch id
    table.sort(ids)
    local temp = {}
    for k, v in ipairs(ids) do
        temp[k-1] = lastPos[v]
    end
    temp.count = count
    return temp
end

function setDesignScale(sp)
    sp:setScaleX(global.director.disSize[1]/global.director.designSize[1])
    sp:setScaleY(global.director.disSize[2]/global.director.designSize[2])
    return sp
end
