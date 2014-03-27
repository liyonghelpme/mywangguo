--[[
BUILD_STATE = {
    FREE = 0,
    MOVE = 1,
}
--]]
TestBuild = class()
function TestBuild:ctor(m, data)
    self.map = m
    self.sx = 1
    self.sy = 1
    self.picName = data.picName
    self.id = data.id
    self.bg = CCNode:create()
    self.data = {kind=0}
    self.bid = -1
    self.changeDirNode = setAnchor(CCSprite:create("build"..self.id..".png"), {0.5, 0})
    self.bg:addChild(self.changeDirNode)
    
    self.bottom = setSize(setAnchor(addSprite(self.bg, "white2.png"), {0.5, 0}), {SIZEX*2, SIZEY*2})
    self.bottom:setZOrder(-1)

    self.pnum = ui.newBMFontLabel({text="", font="bound.fnt", size=20})
    setPos(self.pnum, {0, 20})
    self.bg:addChild(self.pnum)

    self.anum = ui.newBMFontLabel({text="", font="bound.fnt", size=20})
    setPos(self.anum, {0, 50})
    self.bg:addChild(self.anum)

    self.posnum = ui.newBMFontLabel({text="", font="bound.fnt", size=20})
    setPos(self.posnum, {0, 100})
    self.bg:addChild(self.posnum)
end

function TestBuild:setPos(p)
    local curPos = p
    local zord = MAX_BUILD_ZORD-curPos[2]

    self.bg:setPosition(ccp(curPos[1], curPos[2]))
    self.bg:setZOrder(zord)

    local mx, my = self:calNormal()
    self.pnum:setString(mx..','..my)

    --local ax, ay = normalToAffine(m[3], m[4])
    local ax, ay = self:calAff()
    self.anum:setString(ax..","..ay)
    
    self.posnum:setString(curPos[1]..","..curPos[2])
end
function TestBuild:touchesBegan(touches)
    self.accMove = 0
    self.lastPos = convertMultiToArr(touches)
    self.map.mapGridController:clearMap(self)

    local tex = self.changeDirNode:getTexture()
    local tempSp = CCSprite:createWithTexture(tex)
    self.changeDirNode:addChild(tempSp)
    local sz = tex:getContentSize()
    setPos(tempSp, {sz.width/2, sz.height/2})
    tempSp:runAction(sequence({spawn({fadeout(0.5), scaleto(0.5, 1.5, 1.5)}), callfunc(nil, removeSelf, tempSp)}))
end

function TestBuild:touchesMoved(touches)
    local oldPos = self.lastPos
    self.lastPos = convertMultiToArr(touches)

    if self.state == BUILD_STATE.MOVE then
        local parPos = self.bg:getParent():convertToNodeSpace(ccp(self.lastPos[0][1], self.lastPos[0][2]-SIZEY))
        local newPos = normalizePos({parPos.x, parPos.y}, self.sx, self.sy)
        self:setPos(newPos)
        self:setMenuWord()
    end

    local difx = self.lastPos[0][1]-oldPos[0][1]
    local dify = self.lastPos[0][2]-oldPos[0][2]
    self.accMove = self.accMove+math.abs(difx)+math.abs(dify)
end

function TestBuild:touchesEnded(touches)
    self:setColPos()
    self.map.mapGridController:updateMap(self)
    if self.state == BUILD_STATE.FREE and self.accMove < 20 then
        --self.map:addPeople(self) 
        self.map:startBattle(self)
    end
    if self.colNow == 0 and self.accMove < 20 and self.state == BUILD_STATE.MOVE then
        self:setState(BUILD_STATE.FREE)
        self.map:finishBuild()
    end
end

function TestBuild:calNormal()
    local p = getPos(self.bg)
    local px, py = p[1]-1472, p[2]
    local nx, ny = cartesianToNormal(px, py)
    return nx, ny
end
--修正一下坐标
function TestBuild:calAff()
    local p = getPos(self.bg)
    local px, py = p[1]-1472, p[2]
    local nx, ny = cartesianToNormal(px, py) 
    local ax, ay = normalToAffine(nx, ny)
    local ax, ay = MapGX-1-ax, MapGY-1-ay
    return ax, ay
end

function TestBuild:setColPos()
    self.colNow = 0
    --[[
    self.colNow = 1
    setColor(self.bottom, {102, 0, 0})
    local ax, ay = self:calAff()
    
    local layer = self.map.tileMap:layerNamed("dirt1");
    if ax < 0 or ay < 0 or ax >= MapGX or ay >= MapGY or ax >= 21 then
        self.colNow = 1
        setColor(self.bottom, {102, 0, 0})
        return
    end

    local gid = layer:tileGIDAt(ccp(ax, ay))
    local pro = self.map.tileMap:propertiesForGID(gid)
    if pro ~= nil then
        local v = pro:valueForKey("b"):intValue()
        print("tile gid", gid, v)
        if v == 1 then
            self.colNow = 0
            setColor(self.bottom, {0, 102, 0})
        end
    end
    --]]
end
function TestBuild:setState(s)
    self.state = s
    print("MiaoBuild setState", s, self.state)
    if self.state == BUILD_STATE.MOVE then
        self.bottom:setVisible(true)
    else
        self.bottom:setVisible(false)
    end
end

function TestBuild:setMenuWord()
    if self.state == BUILD_STATE.MOVE then
        local ax, ay = self:calAff()
        self.map.scene.menu.infoWord:setString(Logic.buildings[self.id].name..'('..ax..","..ay..")")
    end
end
