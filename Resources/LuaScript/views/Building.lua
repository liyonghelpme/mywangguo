require "views.FuncBuild"
require "views.Wall"
require "views.GodBuild"
require "views.Farm"
require "views.MineFunc"
require "views.BuildAnimate"
require "views.Camp"
require "views.Castle"
require "views.CrystalDef"
require "busiViews.BuildWorkMenu"
require "views.SellDialog"
require "views.Wind"

Building = class()
function Building:ctor(m, d, privateData)
    self.data = d
    self.bid = privateData["bid"] or -1
    self.map = m
    self.kind = self.data["id"]
    self.sx = self.data["sx"]
    self.sy = self.data["sy"]
    self.funcs = d["funcs"]
    self.showMenuYet = false
    --是否被摧毁掉
    self.broken = false
    --神像有防御效果 WorkNode

    self.health = self.data.maxHealth
    self.maxHealth = self.data.maxHealth

    self.bg = CCLayer:create()
    
    self.buildColor = privateData['color'] or global.user:getLastColor()
    self.objectList = privateData['objectList'] or {}
    self.buildLevel = privateData['level'] or 0

    if self.funcs == FARM_BUILD then
        self.funcBuild = Farm.new(self)
    elseif self.funcs == MINE_KIND then
        self.funcBuild = Mine.new(self)
    elseif self.funcs == CAMP then
        self.funcBuild = Camp.new(self)
    elseif self.funcs == GOD_BUILD then
        self.funcBuild = GodBuild.new(self)
    elseif self.funcs == WALL then
        self.funcBuild = Wall.new(self)
    elseif self.funcs == CASTLE_BUILD then
        self.funcBuild = Castle.new(self)
    elseif self.funcs == CRYSTAL_DEF then
        self.funcBuild = CrystalDef.new(self)
    elseif self.funcs == WIND then
        self.funcBuild = Wind.new(self)
    else
        self.funcBuild = FuncBuild.new(self) 
    end
    --papaya不同之处
    --anchorPoint 就是 坐标 0 0 时候的点 因此 changeDirNode 坐标就是0 0 
    if self.funcs == WALL then
        self.changeDirNode = setAnchor(addSprite(self.bg, "wall0.png"), {0.5, 0})
        local sz = self.changeDirNode:getContentSize()
        local axy = WALL_OFFXY[0]
        setAnchor(self.changeDirNode, {axy[1]/sz.width, (sz.height-axy[2])/sz.height})
    else
        self.changeDirNode = setAnchor(addSprite(self.bg, "build"..self.kind..".png"), {0.5, 0})
    end
    if self.data['hasFeature'] and self.buildColor ~= 0 then
        
    end
    local offY = 0
    if self.data['isoView'] then
        offY = (self.sx+self.sy)*SIZEY/2
    end

    --调整建筑物 setPos 的时候就需要调整sp位置
    local sz = self.changeDirNode:getContentSize()
    setPos(setAnchor(setContentSize(self.bg, {sz.width, sz.height}), {0.5, 0}), {ZoneCenter[1][1], fixY(MapHeight, ZoneCenter[1][2])})
    local sp = CCSprite:create("grass3.png")
    self.shadow = sp
    sp:setOpacity(200)
    --self.bg:addChild(sp, -1)
    self.map.bg:addChild(sp)
    local p = getPos(self.bg)
    setPos(sp, p)
    setSize(setAnchor(sp, {0.5, 0.2}), {SIZEX*(self.sx+self.sy+2), SIZEY*(self.sx+self.sy+2)})

    setPos(self.changeDirNode, {0, self.data['offY']})
    self.dir = getDefault(privateData, 'dir', 0)
    self:setState(getParam("buildFree"))
    self:setDir(self.dir)


    local pos = getPos(self.bg)
    local nPos = normalizePos(pos, self.sx, self.sy)
    self:setPos(nPos)
    self:setColPos()
    --新建造的建筑物不用初始化工作状态
    if self.bid ~= -1 then
        self.funcBuild:initWorking(privateData)
    end
    if BattleLogic.inBattle then
        local rh = math.max(sz.height, 150)
        self.healthBar = setScale(setPos(CCSprite:create("mapSolBloodBar1.png"), {0, 150}), 0.7)
        
        self.bg:addChild(self.healthBar)
        self.innerBar = setAnchor(setPos(addSprite(self.healthBar, "mapSolBloodRed1.png"), {2, 2}), {0, 0})
    
        self.healthBar:setVisible(false)
    end


    registerEnterOrExit(self)
    --registerMultiTouch(self)
end
function Building:setMap(m)
    self.map = m
end
--检测冲突设置 底部的颜色
function Building:setColPos()
    self.colNow = 0
    local other = self.map:checkCollision(self)
    print("checkCollision result", other)
    if other ~= nil then
        self.colNow = 1
        self:setColor(0)
    else
        self:setColor(1);
    end
end
function Building:setColor(inZ)
    if self.bottom == nil then
        return
    end
    print('bottom setColor', inZ)
    if inZ == 0 then
        setTexture(self.bottom, "red2.png")
    else
        setTexture(self.bottom, "green2.png")
    end
end

function Building:setDir(d)
    self.dir = d
    if dir == 0 then
        self.changeDirNode:setFlipX(true)
    else
        self.changeDirNode:setFlipX(false)
    end
end
function Building:receiveMsg(name, msg)
end
function Building:enterScene()
    if self.funcs == CAMP and self.state == getParam("buildFree") then
        Event:unregisterEvent(EVENT_TYPE.CALL_SOL, self)
        Event:registerEvent(EVENT_TYPE.CALL_SOL, self)

        Event:unregisterEvent(EVENT_TYPE.MOVE_TO_CAMP, self)
        Event:registerEvent(EVENT_TYPE.MOVE_TO_CAMP, self)
    end

    if self.funcs == FARM_BUILD and self.state == getParam("buildFree") then
        Event:unregisterEvent(EVENT_TYPE.MOVE_TO_FARM, self)
        Event:registerEvent(EVENT_TYPE.MOVE_TO_FARM, self)
    end
end
function Building:exitScene()
    Event:unregisterEvent(EVENT_TYPE.CALL_SOL, self)
    Event:unregisterEvent(EVENT_TYPE.MOVE_TO_CAMP, self)
    Event:unregisterEvent(EVENT_TYPE.MOVE_TO_FARM, self)
end
function Building:onSwitch()
    if self.data['changeDir'] == 0 then
        return
    end
    self.dirty = 1
    self.dir = 1-self.dir
    self:setDir(self.dir)

    global.user:updateBuilding(self)
end

--建筑物一旦触摸成功则swallow 掉场景的touch
--某个手指在建筑物内
--只有一个手指 则移动建筑 并且拒绝移动地图
--touch的Point 从0开始计数
function Building:touchesBegan(touches)
    if BattleLogic.inBattle then
        return
    end
    self.lastPos = convertMultiToArr(touches)
    self.doMove = false
    self.inSelf = false
    self.accMove = 0

    if self.lastPos.count == 1 then
        --local px, py = self.bg:getPosition()
        --local tp = self.bg:getParent():convertToNodeSpace(ccp(self.lastPos[0][1], self.lastPos[0][2]-SIZEY))
        --checkPointIn(tp.x, tp.y,  px, py, self.sx, self.sy) 
        local ret = true   
        if ret then
            self.inSelf = true
            local setSuc = 0
            if self.state == getParam("buildMove") or self.Planing == 1 then
                setSuc = global.director.curScene:setBuilding(self)
                --经营场景不允许该建筑物
                if setSuc == 1 then
                    if self.bottom == nil then
                        self:setState(self.state)
                    end
                end
            end
            print("touchesBegan", setSuc, self.state, self.Planing)
            if setSuc == 1 then
                self.dirty = 1
                self.map.mapGridController:clearMap(self)

                self.doMove = true
                Event:sendMsg(EVENT_TYPE.DO_MOVE, self)    
                --规划的时候移动
                self.funcBuild:removeBuild()
            --建造的时候 inSelf 但是不要 弹出对话框
            --else
                --self.inSelf = false
            end

        end
    end
end
function Building:setState(s)
    print('Building setState', s, getParam('buildMove'))
    self.state = s;
    if self.funcs == CAMP then
        Event:unregisterEvent(EVENT_TYPE.CALL_SOL, self)
        if self.state == getParam("buildFree") then
            Event:registerEvent(EVENT_TYPE.CALL_SOL, self)
        end
    end
    if self.state == getParam("buildMove") or self.Planing == 1 then
        local bSize = self.bg:getContentSize()
        if self.bottom == nil then
            self.bottom = setSize(setAnchor(setPos(CCSprite:create("green2.png"), {0, (self.sx+self.sy)/2*SIZEY}), {0.5, 0.5}), {(self.sx+self.sy)*SIZEX+20, (self.sx+self.sy)*SIZEY+10})
            self.bg:addChild(self.bottom, -1)
        end
    end
end
--move 的时候降低 checkCollision 的频率
function Building:touchesMoved(touches)
    if BattleLogic.inBattle then
        return
    end
    local oldPos = self.lastPos
    self.lastPos = convertMultiToArr(touches)
    if oldPos == nil then
        return
    end
    local difx = self.lastPos[0][1]-oldPos[0][1]
    local dify = self.lastPos[0][2]-oldPos[0][2]
    if self.doMove then
        local offY = (self.sx+self.sy)*SIZEY/2
        local parPos = self.bg:getParent():convertToNodeSpace(ccp(self.lastPos[0][1], self.lastPos[0][2]-offY))
        local newPos = normalizePos({parPos.x, parPos.y}, self.sx, self.sy)
        --先判定是否冲突 再 设置位置
        if math.abs(difx)+math.abs(dify) > 20 then
            self:setColPos()
        end
        self:setPos(newPos)
    else
        --if not self.showMenuYet then
        --end
    end
    --print("accMove", self.accMove)
    self.accMove = self.accMove+math.abs(difx)+math.abs(dify)
end
function Building:showGlobalMenu()
    print("self showGlobalMenu")
    self.acced = 0
    self.selled = 0
    self.showMenuYet = 1
    local func = getBuildFunc(self.funcs)
     
    global.director:pushView(BuildWorkMenu.new(self, func[0], func[1]), 0, 0)
end
function Building:doFree()
    local ret = self.funcBuild:whenFree()
    if ret == 0 then
        if self.showMenuYet == 0 then
            global.director.curScene:showGlobalMenu(self, self.showGlobalMenu, self)
        end
    end
end
function Building:touchesEnded(touches)
    if BattleLogic.inBattle then
        return
    end
    if self.doMove then
        self:setColPos()
        local p = getPos(self.bg)
        self:setPos(p)
        self.map.mapGridController:updateMap(self)
        self.funcBuild:finishBuild()
        Event:sendMsg(EVENT_TYPE.FINISH_MOVE, self)
        if self.showMenuYet then
            global.director.curScene:closeGlobalMenu(self)
        end
    else
        if self.inSelf then
            --只能卖出普通建筑物不能卖出主基地
            local function sellBuild()
                local v = self.data.numCost[1]
                global.director.curScene.bg:addChild(FlyObject.new(self.bg, v, nil, nil).bg)

                local fire = CCParticleSystemQuad:create("inAttack.plist")
                fire:setPositionType(1)
                self.map.bg:addChild(fire)
                setPos(fire, getPos(self.bg))

                global.user:sellBuilding(self, v)
                self.map.mapGridController:removeBuilding(self)
                removeSelf(self.bg)
                removeSelf(self.shadow)

                sendReq("sellBuild", dict({{"uid", global.user.uid}, {"bid", self.bid}, {'gain', v}}))
            end
            if global.director.curScene.Selling then
                if self.accMove < 40 then
                    if self.kind == 200 then
                        addBanner(getStr("notSellCastle"))
                        return
                    end
                    local v = self.data.numCost[1]
                    v = getNotZero(v)
                    global.director:pushView(SellDialog.new(getStr("sureSell", {"[NUM]", str(v[2]), "[KIND]", getStr(v[1])}), sellBuild), 1, 0)
                end
                return
            elseif not global.director.curScene.inBuild then
                if self.state == getParam("buildFree") and self.accMove < 40 then
                    self:doFree()
                elseif self.state == getParam("buildWork") and self.accMove < 40 then
                    local ret = self.funcBuild:whenBusy()
                    if ret == 0 then
                        global.director.curScene:showGlobalMenu(self, self.showGlobalMenu, self)
                    end
                end
            end
        end
    end
end

--调整zord
function Building:setPos(p)
    print("buildingPos", p[1], p[2])

    local curPos = p
    local zord = MAX_BUILD_ZORD-curPos[2]
    if self.colNow == 1 then
        zord = MAX_BUILD_ZORD
    end
    self.bg:setPosition(ccp(curPos[1], curPos[2]))
    setPos(self.shadow, curPos)
    local parent = self.bg:getParent()
    if parent == nil then
        return
    end
    print("zord is ", zord)
    self.bg:setZOrder(zord)
end
function Building:keepPos()
    self.oldPos = getPos(self.bg)
    self.dirty = 0
    self.Planing = 1
end
function Building:restorePos()
    if self.dirty then
        self.map.mapGridController:clearMap(self)
        self:setPos(self.oldPos)
        self.map.mapGridController:updateMap(self)
    end
    self:finishPlan()
end
function Building:finishPlan()
    print("finishPlan")
    self.dirty = 0
    self.Planing = 0
    if self.bottom ~= nil then
        self:finishBottom()
        --self:setZord()
    end
end

function Building:setBid(b)
    self.bid = b
end

function Building:finishBuild()
    self:setState(getParam("buildFree"))
    self:finishBottom()
    self:setZord()
    local privateData = {objectId=0, objectTime=client2Server(Timer.now)}
    self.funcBuild:initWorking(privateData)
    global.user:updateBuilding(self)

    local dust = CCParticleSystemQuad:create("dust.plist")
    dust:setPositionType(2)
    self.bg:addChild(dust, 1)

end
function Building:setZord()
    local zOrd = MAX_BUILD_ZORD-getPos(self.bg)[2]
    local par = self.bg:getParent()
    if par ~= nil then
        --self.bg:retain()
        --removeSelf(self.bg)
        --self.bg:removeFromParentAndCleanup(false)
        --par:addChild(self.bg, zOrd)
        --self.bg:release()
        self.bg:setZOrder(zOrd)
    end
end
function Building:finishBottom()
    self.bottom:removeFromParentAndCleanup(true)
    self.bottom = nil
end
function Building:cancelBuild()
    self.funcBuild:removeBuild()
end

function Building:getPos()
    return getPos(self.bg)
end

function Building:getObjectId()
    return self.funcBuild:getObjectId()
end

function Building:getStartTime()
    return self.funcBuild:getStartTime()
end
function Building:getName()
    return self.data["name"]
end

function Building:beginPlant(cost, id)
    global.user:doCost(cost)
    self.funcBuild:beginPlant(id)
end
function Building:getLeftTime()
    return self.funcBuild:getLeftTime()
end
function Building:closeGlobalMenu()
    self.showMenuYet = 0
end
function Building:doHarm(n)
    if self.broken then
        return
    end
    local realHurt = math.min(n, self.health)
    self.health = self.health-n
    self.health = math.max(0, self.health)
    local vs = self.healthBar:isVisible()
    if not vs then
        self.healthBar:setVisible(true)
        self.healthBar:runAction(fadein(0.5))
        self.innerBar:runAction(fadein(0.5))
    end

    local b = self.health/self.maxHealth
    self.innerBar:runAction(scaleto(0.2, b, 1)) 
    
    --农田
    if self.resPar == nil and self.kind == 0 then
        self.resPar = CCNode:create()
        local n = math.random(4)+3
        for i=1, n do
            local kind = math.random(20)-1
            local sp = CCSprite:create("Wplant"..kind..".png")
            local sca = math.random()*0.3+0.3
            sp:setScale(sca)
            self.resPar:addChild(sp)
            local rx, ry = math.random(100)-50, math.random(20)+10
            sp:runAction(sequence({fadein(0.1), jumpBy(1, rx, ry, 200, 1), fadeout(0.1)}))
            local ang = math.random(300)+360
            local d = math.random(2)
            if d == 1 then
                ang = -ang
            end
            sp:runAction(rotateby(1, ang))
        end

        self.bg:addChild(self.resPar)
        setPos(self.resPar, {0, 30})
        local function removeRes()
            removeSelf(self.resPar)
            self.resPar = nil
        end
        self.resPar:runAction(sequence({delaytime(1.2), callfunc(nil, removeRes)}))
    end
    if self.resPar == nil and self.kind == 200 then
        self.resPar = CCNode:create()
        
        for i=1, n do
            local kind = math.random(20)-1
            local sp = CCSprite:create("Wplant"..kind..".png")
            local sca = math.random()*0.3+0.3
            sp:setScale(sca)
            self.resPar:addChild(sp)
            local rx, ry = math.random(50)+30, math.random(20)+10
            local dir = math.random(2)
            sp:runAction(sequence({fadein(0.1), jumpBy(1, rx, ry, 200, 1), fadeout(0.1)}))
            local ang = math.random(300)+360
            local d = math.random(2)
            if d == 1 then
                ang = -ang
            end
            sp:runAction(rotateby(1, ang))
        end

        for i=1, n do
            local sp = CCSprite:create("crystal.png")
            local sca = math.random()*0.3+0.3
            sp:setScale(sca)
            self.resPar:addChild(sp)
            local rx, ry = math.random(100)-50, math.random(20)+10
            sp:runAction(sequence({fadein(0.1), jumpBy(1, rx, ry, 200, 1), fadeout(0.1)}))
            local ang = math.random(300)+360
            local d = math.random(2)
            if d == 1 then
                ang = -ang
            end
            sp:runAction(rotateby(1, ang))
        end


        self.bg:addChild(self.resPar)
        setPos(self.resPar, {0, 30})
        local function removeRes()
            removeSelf(self.resPar)
            self.resPar = nil
        end
        self.resPar:runAction(sequence({delaytime(1.2), callfunc(nil, removeRes)}))
    end

    if self.resPar == nil and self.kind == 300 then
        self.resPar = CCNode:create()
        for i=1, n do
            local sp = CCSprite:create("crystal.png")
            local sca = math.random()*0.3+0.3
            sp:setScale(sca)
            self.resPar:addChild(sp)
            local rx, ry = math.random(100)-50, math.random(20)+10
            sp:runAction(sequence({fadein(0.1), jumpBy(1, rx, ry, 200, 1), fadeout(0.1)}))
            local ang = math.random(300)+360
            local d = math.random(2)
            if d == 1 then
                ang = -ang
            end
            sp:runAction(rotateby(1, ang))
        end

        self.bg:addChild(self.resPar)
        setPos(self.resPar, {0, 30})
        local function removeRes()
            removeSelf(self.resPar)
            self.resPar = nil
        end
        self.resPar:runAction(sequence({delaytime(1.2), callfunc(nil, removeRes)}))
    end

    if self.kind == 0 then
        local ts = math.floor(BattleLogic.resource.silver/2/2/BattleLogic.farmNum)
        ts = math.max(math.floor(ts*realHurt/self.maxHealth), 1)
        BattleLogic.addSilver(ts)
    elseif self.kind == 200 then
        local ts = math.floor(BattleLogic.resource.silver/2/2)
        ts = math.max(math.floor(ts*realHurt/self.maxHealth), 1)
        BattleLogic.addSilver(ts)

        local ts = math.floor(BattleLogic.resource.crystal/2/2)
        ts = math.max(math.floor(ts*realHurt/self.maxHealth), 1)
        BattleLogic.addCrystal(ts)
    elseif self.kind == 300 then
        local ts = math.floor(BattleLogic.resource.crystal/2/2/BattleLogic.mineNum)
        ts = math.max(math.floor(ts*realHurt/self.maxHealth), 1)
        BattleLogic.addCrystal(ts)
    end


    if self.health > 0 then
        if self.bigBomb == nil then
            self.bigBomb = CCParticleSystemQuad:create('bigBomb.plist')
            self.bg:addChild(self.bigBomb)
            self.bigBomb:setTotalParticles(50)
            local function clearBigBomb()
                removeSelf(self.bigBomb)
                self.bigBomb = nil
            end
            local rx = math.random(20)-10
            local ry = math.random(20)+self.sy*SIZEY-10
            setPos(self.bigBomb, {rx, ry})
            self.bigBomb:setPositionType(1)
            self.bigBomb:runAction(sequence({delaytime(0.5), callfunc(nil, clearBigBomb)}))
        end
    end

    if self.health == 0 and self.broken == false then
        self.broken = true
        self.healthBar:setVisible(false)  
        local function fadeAll(bg)
            local child = bg:getChildren()
            local n = bg:getChildrenCount()
            if n > 0 then
                for i=0, n-1, 1 do
                    local c = child:objectAtIndex(i)
                    --print("whos c", c)
                    if c.runAction ~= nil then
                        c:runAction(fadeout(0.4))
                        fadeAll(c)
                    end
                end
            end
            --bg:runAction(sequence({scaleto(0.3, 1.1, 1.1), scaleto(0.1,  1, 1) }))
            if self.funcBuild.flowBanner ~= nil then
                self.funcBuild.flowBanner.pl:runAction(fadeout(0.4))
            end

        end
        self.funcBuild:doBroken()
        --爆炸的效果
        --repeatN(sequence({scaleto(0.2, 0.95, 1.05), scaleto(0.2, 1, 1)}), 4), 
        self.bg:runAction(sequence({callfunc(nil, fadeAll, self.bg)}))
        local fire = CCParticleSystemQuad:create("inAttack.plist")
        fire:setPositionType(1)
        self.bg:addChild(fire)
    end
end
