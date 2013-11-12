function dict(arr)
    local temp = {}
    if arr ~= nil then
        for k, v in ipairs(arr) do
            temp[v[1]] = v[2]
        end
    end
    return temp
end
require "data.String"
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
--注册更新通常需要注册enter和exitScene 这样在退出场景的时候自动关闭更新
--registerEnterOrExit must!!
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
            if obj.enterScene ~= nil then
                obj:enterScene()
            end
        elseif tag == 'exit' then
            if obj.updateFunc ~= nil then
                CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(obj.updateFunc)
            end
            if obj.exitScene ~= nil then
                obj:exitScene()
            end
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
--背景高度 默认 global.director.disSize[2]
--y 原始位置
--sy 图片尺寸
--ay 图片的anchorPoint
function fixY(hei, y, sy, ay)
    if hei == nil then
        hei = global.director.disSize[2]
    end
    if sy == nil then
        sy = 0
    end
    if ay == nil then
        return hei-(y+sy)
    else
        return hei-(y)
    end
end

function designToRealY(y)
    local dy = global.director.designSize[2]-y
    return global.director.disSize[2]-dy
end

function addAction(bg, act)
    bg:runAction(act)
    return bg
end
function repeatForever(act)
    return CCRepeatForever:create(act)
end
function repeatN(act, n)
    return CCRepeat:create(act, n)
end
function rotateby(t, ang)
    return CCRotateBy:create(t, ang)
end
function moveto(d, x, y)
    local mov = CCMoveTo:create(d, ccp(x, y))
    return mov
end
function moveby(d, x, y)
    local mov = CCMoveBy:create(d, ccp(x, y))
    return mov
end
function expout(act)
    return CCEaseExponentialOut:create(act)
end
function expin(act)
    return CCEaseExponentialIn:create(act)
end
function fadein(t)
    return CCFadeIn:create(t)
end
function fadeout(t)
    return CCFadeOut:create(t)
end
function delaytime(t)
    return CCDelayTime:create(t)
end
function spawn(sp)
    local array = CCArray:create()
    for k, v in ipairs(sp) do
        array:addObject(v)
    end
    return CCSpawn:create(array)
end
function scaleto(t, sx, sy)
    return CCScaleTo:create(t, sx, sy)
end

function scaleby(t, sx, sy)
    return CCScaleBy:create(t, sx, sy)
end
function sizeto(t, sx, sy, sp)
    local sz = sp:getContentSize()
    local scax = sx/sz.width
    local scay = sy/sz.height
    return CCScaleTo:create(t, scax, scay)
end

function callfunc(delegate, cb, param)
    local function cm()
        if delegate ~= nil then
            cb(delegate, param)
        else
            cb(param)
        end
    end
    return CCCallFunc:create(cm)
end
function fadeto(d, o)
    return CCFadeTo:create(d, o)
end

function itintto(d, r, g, b)
    return CCTintTo:create(d, r, g, b)
end
function sequence(seq)
    local arr = CCArray:create()
    for k, v in ipairs(seq) do
        arr:addObject(v)
    end
    return CCSequence:create(arr)
end

function sineout(act)
    return CCEaseSineOut:create(act)
end
function sinein(act)
    return CCEaseSineIn:create(act)
end
function purebezierby(t, x1, y1, x2, y2, x3, y3)
    local bezier = ccBezierConfig()
    bezier.controlPoint_1 = ccp(x1, y1)
    bezier.controlPoint_2 = ccp(x2, y2)
    bezier.endPosition = ccp(x3, y3)
    return CCBezierBy:create(t, bezier)
end
function bezierby(t, x0, y0, x1, y1, x2, y2, x3, y3)
    local b = purebezierby(t, x1, y1, x2, y2, x3, y3)
    return sequence({moveto(0, x0, y0), b})
end
function purebezierto(t, x1, y1, x2, y2, x3, y3)
    local bezier = ccBezierConfig()
    bezier.controlPoint_1 = ccp(x1, y1)
    bezier.controlPoint_2 = ccp(x2, y2)
    bezier.endPosition = ccp(x3, y3)
    return CCBezierTo:create(t, bezier)
end
function bezierto(t, x0, y0, x1, y1, x2, y2, x3, y3)
    local b = purebezierto(t, x1, y1, x2, y2, x3, y3)
    return sequence({moveto(0, x0, y0), b})
end
--数组中放着图片名字
function arrPicFrames(arr)
    local allFrame = CCArray:create()
    local spc = CCSpriteFrameCache:sharedSpriteFrameCache()

    for k, v in ipairs(arr) do
        local fn = 'images/'..v
        local frame = spc:spriteFrameByName(fn)
        if frame == nil then
            local tex = CCTextureCache:sharedTextureCache():addImage(fn)
            local sz = tex:getContentSize()
            local rect = CCRectMake(0, 0, sz.width, sz.height) 
            local sf = CCSpriteFrame:createWithTexture(tex, rect)
            frame = sf
        end
        --print("frame", frame, fn)
        allFrame:addObject(frame)
    end
    return allFrame
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

function addPlistSprite(name)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(name)
end
--修正主picture 在images 文件夹
--修正key --->xxx.plist/x.png
--降低资源包
--[[
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
--]]

local initYet = false
function altasWord(c, s)
    local n = CCNode:create()
    local plist = c..'.plist'
    if not initYet then
        addPlistSprite("yellow.plist")
        addPlistSprite("red.plist")
        addPlistSprite("blue.plist")
        addPlistSprite("white.plist")
        addPlistSprite("bold.plist")
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

function setSca(sp, sca)
    return setScale(sp, sca)
end
function setScale(sp, sca)
    sp:setScale(sca)
    return sp
end
function setScaleX(sp, x)
    sp:setScaleX(x)
    return sp
end
function adjustWidth(sp)
    sp:setScale(global.director.disSize[1]/global.director.designSize[1])
    return sp
end

function addLayer(s, c)
    s.bg:addChild(c.bg)
    return s
end

function addLabel(s, w, f, sz)
    local l = CCLabelTTF:create(w, f, sz)
    s:addChild(l)
    return l
end
function addNode(s)
    local n = CCNode:create()
    s:addChild(n)
    return n
end
function setVisible(s, v)
    s:setVisible(v)
    return s
end


function getStr(key, rep)
    local s = Strings[key]
    if s == nil then
        s = WORDS[key]
        if s == nil then
            return key
        end
    end
    --语言
    s = s[1]
    if rep == nil then
        return s
    end
    s = replaceStr(s, rep)
    return s
end

--可以参考nozomi MyWorld 网格 笛卡尔坐标 仿射坐标的转化
--从 笛卡尔坐标 到 左下角的normal 坐标
--转化成 normal 坐标
function getPosMap(sx, sy, px, py)
    px = px - (sx+sy)*SIZEX/2
    --py = py - (sx+sy)*SIZEY
    px = round(px/SIZEX)
    py = round(py/SIZEY)
    return {sx, sy, px+sx, py+1}
end
--修正点击的位置 最近的正常的Affine坐标
--需要先得到normal 位置再计算 map
function getPosMapFloat(sx, sy, px, py)
    local np = normalizePos({px,py},sx, sy)
    px = np[1]
    py = np[2]
    px = px - (sx+sy)*SIZEX/2
    px = round(px/SIZEX)+sx
    py = round(py/SIZEY)+1
    return {sx, sy, px, py}
end
function getMapKey(x, y)
    return x*10000+y
end
function getXY(k)
    return math.floor(k/10000), math.floor(k%10000)
end

function getDefault(t, k, def)
    local v = t[k]
    if v == nil then
        t[k]= def
        v = def
    end
    return v
end

function getBuildMap(build)
    local sx = build.sx
    local sy = build.sy
    local px, py = build.bg:getPosition()
    return getPosMap(sx, sy, px, py)
end
--用 normal To Cartesian 来实现的
--[[
function normalToCartesian(nx, ny)
    return nx*SIZEX, ny*SIZEY
end
--]]
--从寻路的normal 转化成 建筑物的normal 坐标
function cellNormalToMapNormal(x, y)
end
--这个替代了从normal 到Cartesian 坐标转化
function setBuildMap(map)
    local sx = map[1]
    local sy = map[2]
    local px = map[3]
    local py = map[4]

    px = px-sx
    py = py-1
    px = px*SIZEX
    py = py*SIZEY
    px = px+(sx+sy)*SIZEX/2
    --py = py+(sx+sy)*SIZEY
    return {px, py}
end

function removeMapEle(arr, obj)
    for k, v in ipairs(arr) do
        if v[1] == obj then
            table.remove(arr, k)
            break
        end
    end
end
function getGoodsKey(kind, id)
    return kind*10000+id
end
local dataPool = {}
function getData(kind, id)
    local key = getGoodsKey(kind, id)
    local ret = dataPool[key]
    if ret == nil then
        local k = Keys[kind]
        local datas = CostData[kind][id]
        ret = {}

        for m, n in ipairs(k) do
            if n == "name" then
                ret[n] = getStr(datas[m], nil)
            else
                ret[n] = datas[m]
            end
        end
        dataPool[key] = ret
    end
    return ret
end
--使用右下角 规划格子 所以不用减去y方向的值
function normalizePos(p, sx, sy)
    local x = p[1]
    local y = p[2]
    x = x - (sx+sy)*SIZEX/2
    --y = y - (sx+sy)*SIZEY
    
    local q1 = round(x/SIZEX)
    local q2 = round(y/SIZEY)
    if (q1+sx)%2 ~= (q2+1)%2 then
        q2 = q2+1
    end
    x = q1*SIZEX
    y = q2*SIZEY
    x = x + (sx+sy)*SIZEX/2
    return {x, y}
end


--笛卡尔 正则  仿射坐标转化
--寻路算法中使用 正则坐标 
--neibor 
--x+1 y
--x-1 y
--x y+1
--x y-1
--x+1 y+1
--x-1 y+1
--x-1 y-1
--x+1 y-1
--cartesian  normal  affine
function cartesianToNormal(x, y)
    return round(x/SIZEX), round(y/SIZEY)
end
function normalToAffine(nx, ny)
    return round((nx+ny)/2), round((ny-nx)/2)
end

--用于计算当前位置和攻击范围的关系
--返回浮点normal 网格坐标
function cartesianToNormalFloat(x, y)
    return (x/SIZEX), (y/SIZEY)
end
--将坐标基数 现有坐标奇数偶数相同 现有的建筑物坐标的要求
function sameOdd(x, y)
    if x%2 ~= y%2 then
        y = y+1
    end
    return x, y
end


--返回浮点affine 网格坐标  
function normalToAffineFloat(nx, ny)
    return (nx+ny)/2, (ny-nx)/2
end

function normalToCartesian(nx, ny)
    return nx*SIZEX, ny*SIZEY
end
function affineToNormal(dx, dy)
    return dx-dy, dx+dy
end

--转化成 affine 坐标进行比较
function checkPointIn(x, y, px, py, sx, sy)
    local nxy = getPosMapFloat(1, 1, x, y)
    local ax, ay = normalToAffine(nxy[3], nxy[4]) 

    --建筑物 对应的affine 网格 中心点
    local npxy = getPosMapFloat(1, 1, px, py) 
    local apx, apy = normalToAffine(npxy[3], npxy[4])

    --[[
    print("checkPointIn", x, y, px, py, sx, sy)
    print("nx ny ax ay", nx, ny, ax, ay)
    print("point", npx, npy, apx, apy)
    --]]
    --网格坐标在其内部
    return ax >= apx and ay >= apy and ax < apx+sx and ay < apy+sy
end

function getPos(s)
    local x, y = s:getPosition()
    return {x, y}
end
function getSize(s)
    local sz = {}
    local t = s:getContentSize()
    sz = {t.width, t.height}
    return sz
end
function checkIn(x, y, sz)
    return x >= 0 and x < sz.width and y > 0 and y < sz.height
end
function getHeight(sp)
    return sp:getContentSize().height
end

--可以合并素材到一个renderTarget 里面用于静态显示 适合于静态组合的场景背景图片的显示 
function picNumWord(w, sz, col)
    local n = CCNode:create()
    local curX = 0
    local curY = 0
    local height = 0
    local over = split(w, "}")
    for i=1, #over, 1 do
        local begin = split(over[i], '{')
        if #begin[1] > 0 then
            local l = ui.newTTFLabel({text=begin[1], font="", size=sz})
            setPos(setColor(setAnchor(l, {0, 0}), col), {curX, curY})
            n:addChild(l)
            local lSize = l:getContentSize()
            curX = curX+lSize.width
            height = math.max(height, lSize.height)
            local shadow = ui.newTTFLabel({text=begin[1], font="", size=sz})
            setPos(setColor(setAnchor(shadow, {0, 0}), {0, 0, 0}), {1, -1})
            l:addChild(shadow, -1)
        end
        if #begin > 1 then
        end
    end
    n:setContentSize(CCSizeMake(curX, height))
    return n
end

function split(str, del)
    local fields = {}
    str:gsub("([^"..del.."]+)", function(c) table.insert(fields, c) end)
    return fields
end

--level == 0
function getLevelCost(kind, id, level)
    local build = getData(kind, id)
    local cost = {}
    for k, i in ipairs(costKey)do
        local v = getDefault(build, i, 0)
        if v > 0 then
            cost[i] = v
        end
    end

    --建筑物 需要根据数量 等级计算开销
    --普通建筑都是0级别购买 
    --水晶矿升级 是 另外的 方式
    --print(simple.encode(build))
    --level 总是 0 只是根据level 不同价格不同
    if kind == GOODS_KIND.BUILD then
        if build["hasNum"] == 1 then
            local curNum = getCurLevelBuildNum(id, level)
            --升级建筑物 建筑物的数量不变
            curNum = math.min(#build.numCost-1, curNum)
            --购买建筑物建筑
            local c = build.numCost[curNum+1]
            for i = 1, #costKey, 1 do 
                v = getDefault(c, costKey[i], 0)
                if v > 0 then
                    cost[costKey[i]] = v
                end
            end
        end
    end
    return cost
end
function getNotZero(val)
    for k, v in pairs(val) do
        if v > 0 then
            return {k, v}
        end
    end
end

function getCost(kind, id)
    return getLevelCost(kind, id, 0)
    --[[
    local build = getData(kind, id)
    local cost = {}
    for k, i in ipairs(costKey) do
        local v = getDefault(build, i, 0)
        if v > 0 then
            cost[i] = v
        end
    end
    return cost
    --]]
end
function getGain(kind, id)
    local build = getData(kind, id)
    local gain = {}
    for k, i in ipairs(addKey) do
        local v = getDefault(build, i, 0)
        if v > 0 then
            local newKey = string.gsub(i, "gain", "") 
            gain[newKey] = v
        end
    end
    return gain
end

function replaceStr(s, rep)
    local temp = {}
    for k, v in ipairs(rep) do
        if (k-1)%2 == 0 then
            v = string.gsub(v, '%[', '{')
            v = string.gsub(v, '%]', '}')
        end
        table.insert(temp, v)
    end
    rep = temp
    for i=1, #rep, 2 do
        s = string.gsub(s, rep[i], rep[i+1])
    end
    return s
end

function getSca(n, box)
    local nSize = n:getContentSize()
    local sca
    if nSize.width > box[1] or nSize.height > box[2] then
        sca = math.min(box[1]/nSize.width, box[2]/nSize.height)
    else
        sca = 1
    end
    return sca
end

function checkInChild(bg, pos)
    local sub = bg:getChildren()
    local count = bg:getChildrenCount()
    for i=0, count-1, 1 do
        local child = tolua.cast(sub:objectAtIndex(i), 'CCNode')
        local np = child:convertToNodeSpace(ccp(pos[1], pos[2]))
        if checkIn(np.x, np.y, child:getContentSize()) then
            print('child', child:getTag())
            return child
        end
    end
    return nil
end

function getParam(k)
    return getDefault(GameParam, k, 0)
end


function colorWordsNode(s, si, nc, sc)
    local n = CCNode:create()
    local over = split(s, "%]")

    local curX = 0
    local height = 0
    for i = 1, #over,  1 do
        if string.find(over[i], "%[") ~= nil then
            local p = split(over[i], "%[")
            if #p[1] > 0 then
                local l = setPos(setColor(CCLabelTTF:create(p[1], "", si), nc), {curX, 0})
                n:addChild(l)
                setAnchor(l, {0, 0})
                local lSize = l:getContentSize()
                curX = curX+lSize.width
                height = lSize.height
            end

            if #p[2] > 0 then
                local l = setPos(setColor(CCLabelTTF:create(p[2], "", si), sc), {curX, 0})
                n:addChild(l)
                setAnchor(l, {0, 0})
                local lSize = l:getContentSize()
                curX = curX+lSize.width
                height = lSize.height
            end
        else
            if #over[i] > 0 then
                local l = setPos(setColor(CCLabelTTF:create(over[i], "", si), nc), {curX, 0})
                setAnchor(l, {0, 0})
                n:addChild(l)
                local lSize = l:getContentSize()
                curX = curX+lSize.width
                height = lSize.height
            end
        end
    end
    n:setContentSize(CCSizeMake(curX, height))
    return n;
end
function getRealHeight(sp)
    local sz = sp:getContentSize()
    local sca = sp:getScale()
    return sz.height*sca
end


function cost2Minus(cost)
    local data = {}
    for k, v in pairs(cost) do
        data[k] = -v
    end
    return data;
end
function updateTable(a, b)
    for k, v in pairs(b) do
        a[k] = v
    end
    return a
end
function showMultiPopBanner(showData)
    for k, v in pairs(showData) do
        local w
        if v > 0 then
            w = getStr("opSuc", {"[NUM]", "+"..str(v), "[KIND]", getStr(k, null)})
            global.director.curScene.dialogController:addBanner(UpgradeBanner.new(w, {255, 255, 255}, nil, nil))
        end
    end
end
function strictSca(n, box)
    local nSize = n:getContentSize()
    local sca = math.min(box[1]/nSize.width, box[2]/nSize.height)
    return sca
end
function server2Client(t)
    return math.floor(t-global.user.serverTime+global.user.clientTime)
end
function client2Server(t)
    return math.floor(t-global.user.clientTime+global.user.serverTime)
end
function setTexture(sp, tex)
    local t = CCTextureCache:sharedTextureCache():addImage(tex)
    --print('setTexture', sp, t)
    sp:setTexture(t)
    local sz = t:getContentSize()
    local r = CCRectMake(0, 0, sz.width, sz.height)
    sp:setTextureRect(r)
    return sp
end
function linearInter(va, vb, ta, tb, cut)
    return va+(vb-va)*cut/(tb-ta)
end
function calAccCost(leftTime)
    for i = 1, i < #AccCost,  1 do
        if AccCost[i][1] > i then
            break
        end
    end
    i = i-1
    local beginTime = AccCost[i][1]
    local endTime = AccCost[i+1][1]
    local beginGold = AccCost[i][2]
    local endGold = AccCost[i+1][2]
    local needGold = linearInter(beginGold, endGold, beginTime, endTime, leftTime)
    return needGold
end

function getLevelUpNeedExp(level)
    return levelExp[math.min(#levelExp, level+1)]
end
function getAni(id)
    return buildAnimate[id]
end
function adjustZord(bg, z)
    bg:retain()
    local par = bg:getParent()
    removeSelf(bg)
    par:addChild(bg, z)
    bg:release()
    return bg
end

function getBuildFunc(id)
    return buildFunc[id]
end

function getWorkTime(t)
    local sec = math.floor(t%60)
    t = math.floor(t/60)
    local min = t%60
    local hour = math.floor(t/60)
    local res = hour..":"..min..":"..sec
    return res
end
function getTimeStr(t)
    local sec = t % 60
    t = math.floor(t / 60)
    local min = t % 60
    local hour = math.floor(t / 60)
    local res = ""
    if hour ~= 0 then
        res = res..hour.."h "
    end
    if min ~= 0 then
        res = res..min.."m "
    end
    if (hour == 0 or min == 0) and sec ~= 0 then
        res = res..sec.."s"
    end
    return res
end
function getLen(t)
    local count = 0
    for k, v in pairs(t) do
        count = count+1
    end
    return count
end
function fixColor(c)
    temp = {}
    for k, v in ipairs(c) do
        temp[k] = v*255/100
    end
    return temp
end

function getNodeSca(n, box)
    local nSize = n:getContentSize()
    local sca = math.min(box[1]/nSize.width, box[2]/nSize.height)
    sca = math.max(math.min(1.5, sca), 0.5)
    return sca
end
function str(v)
    return ""..v
end
function disappear(obj)
    local function cb()
        obj:setVisible(false)
    end
    return callfunc(nil, cb, nil)
end
function sendReq(url, postData, handler, param, delegate)
    global.httpController:addRequest(url, postData, handler, param, delegate)
end
function addFly(bg, gain, cb, delegate)
    global.director.curScene.bg:addChild(FlyObject.new(bg, gain, cb, delegate).bg)
end
function toCol(c)
    return ccc3(c[1], c[2], c[3])
end
function addBanner(w)
    global.director.curScene.dialogController:addBanner(UpgradeBanner.new(w, {255, 255, 255}, nil, nil))
end
function addCmd(c)
    global.director.curScene.dialogController:addCmd(c)
end
function Sign(v)
    if v > 0 then
        return 1
    elseif v < 0 then
        return -1
    else
        return 0
    end
end

--BMFontLabel 数字使用这个动画
function numAct(sp, curVal, tarVal)
    print("numAct", curVal, tarVal)
    if tarVal == nil then
        return
    end
    local delta = math.max(math.floor(math.abs(tarVal-curVal)/20), 1)
    local up = Sign(tarVal-curVal)
    delta = delta*up
    local function changeV()
        curVal = curVal+delta
        if up == 1 and curVal >= tarVal then
            curVal = tarVal
            sp:stopAction(sp.numAction)
        elseif up == -1 and curVal <= tarVal then
            curVal = tarVal
            sp:stopAction(sp.numAction)
        elseif up == 0 then
            curVal = tarVal
            sp:stopAction(sp.numAction)
        end
        sp:setString(str(curVal))
    end
    sp.numAction = repeatForever(sequence({callfunc(nil, changeV), delaytime(0.05)}))
    sp:runAction(sp.numAction)
end

function getSca(n, box)
    local nSize = getSize(n)
    local sca = 1
    if nSize[1] > box[1] or nSize[2] > box[2] then
        sca = math.min(box[1]/nSize[1], box[2]/nSize[2])
    end
    return sca
end
function fixY2(y)
    return global.director.designSize[2]-y
end


--动画名称
--动画名字pattern
--动画开始frame
--动画结束frame
--动画frame 之间的 间隔
--动画总时间
--是否是 SpriteFrame  还是普通的Image
function createAnimation(name, format, a,b,c,t, isFrame)
    local animation = CCAnimationCache:sharedAnimationCache():animationByName(name)
    if not animation then
        animation = CCAnimation:create()
        --从SpriteFrameCache 中获取动画Frame
        if isFrame then
            local cache = CCSpriteFrameCache:sharedSpriteFrameCache()
            for i=a, b, c do
                animation:addSpriteFrame(cache:spriteFrameByName(string.format(format, i)))
            end
        else
            for i=a, b, c do
                animation:addSpriteFrameWithFileName(string.format(format, i))
            end
        end
        animation:setDelayPerUnit(t*c/(b-a+c))
        animation:setRestoreOriginalFrame(true)
        CCAnimationCache:sharedAnimationCache():addAnimation(animation, name)
    end
    return animation
end
function getVS()
    return CCDirector:sharedDirector():getVisibleSize()
end
function setRotation(p, ang)
    p:setRotation(ang)
    return p
end

function multiScalar(arr, s)
    for k, v in pairs(arr) do
        v = v*s
        arr[k] = v
    end
end

--right 对齐的坐标
function fixX(x)
    local dx = global.director.designSize[1]-x
    return global.director.disSize[1]-dx
end
function setDesignY(sp)
    local sca = sp:getScaleY()
    sp:setScaleY(sca*global.director.disSize[2]/global.director.designSize[2])
    return sp
end
function setDesignXY(sp)
    local dx = global.director.disSize[1]/global.director.designSize[1]
    local dy = global.director.disSize[2]/global.director.designSize[2]
    local sca = math.min(dx, dy)
    sp:setScale(sca)
end
function getDesignSca()
    local dx = global.director.disSize[1]/global.director.designSize[1]
    local dy = global.director.disSize[2]/global.director.designSize[2]
    local sca = math.min(dx, dy)
    return sca
end
--调整Scale 之后 bg 居中对齐的方法
function setMidPos(sp)
    local sca = sp:getScale()
    local vs = getVS()
    local ds = global.director.designSize
    local rx = ds[1]*sca
    local ry = ds[2]*sca
    local offX = (vs.width-rx)/2
    local offY = (vs.height-ry)/2
    return setPos(sp, {offX, offY})
end
function getWinMid()
    local vs = getVS()
    return {vs.width/2, vs.height/2}
end
function getBool(k)
    return CCUserDefault:sharedUserDefault():getBoolForKey(k)
end
function setBool(k, v)
    CCUserDefault:sharedUserDefault():setBoolForKey(k, v)
end
function jumpBy(t, x, y, hei, n)
    return CCJumpBy:create(t, ccp(x, y), hei, n)
end
function jumpTo(t, x, y, hei, n)
    return CCJumpTo:create(t, ccp(x, y), hei, n)
end
function addCmd(c)
    global.director.curScene.dialogController:addCmd(c)
end
function STR(v)
    if type(v) == 'boolean' then
        if v then
            return 'true'
        end
        return 'false'
    end
    return ''
end
function delayCall(t, cb, par)
    local handler
    local function cancel()
        cb(par)
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(handler)
    end
    handler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(cancel, t, false)
end
