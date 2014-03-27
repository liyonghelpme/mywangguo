function Sky()
    local bg = CCNode:create()
    setAnchor(setPos(addSprite(bg, "images/sky0.png"), {0, 1120}), {0, 1})

    setAnchor(setPos(addSprite(bg, "images/sky1.png"), {1000, 1120}), {0, 1})
    setAnchor(setPos(addSprite(bg, "images/sky2.png"), {2000, 1120}), {0, 1})
    return bg
end

function TrainLand()
    local bg = CCSprite:create("images/land0.png")
    setAnchor(setPos(bg, {0, 0}), {0, 0})
    setAnchor(setPos(addSprite(bg, "images/land3.png"), {0, 722}), {0, 0})
    return bg
end
function BuildLand()
    local bg = CCSprite:create("images/land1.png")
    setAnchor(setPos(bg, {1000, 0}), {0, 0})
    setAnchor(setPos(addSprite(bg, "images/land4.png"), {0, 722}), {0, 0})
    return bg
end
function FarmLand()
    local bg = CCSprite:create("images/land2.png")
    setAnchor(setPos(bg, {2000, 0}), {0, 0})
    setAnchor(setPos(addSprite(bg, "images/land5.png"), {0, 722}), {0, 0})
    return bg
end


CastlePage = class()
function CastlePage:ctor(scene)
    self.scene = scene
    self.bg = CCLayer:create()
    setPos(setContentSize(self.bg, {MapWidth, MapHeight}), {global.director.disSize[1]/2-MapWidth/2, global.director.disSize[2]/2-MapHeight/2})
    local sky = Sky()
    self.bg:addChild(sky, -2)

    local temp = FarmLand()
    self.bg:addChild(temp)

    local temp = BuildLand()
    self.bg:addChild(temp)

    local temp = TrainLand()
    self.bg:addChild(temp)

    self.touchDelegate = StandardTouchHandler.new()
    self.touchDelegate.bg = self.bg

    self.buildLayer = BuildLayer.new()
    self.bg:addChild(self.buildLayer.bg)
    
    registerEnterOrExit(self)
    registerMultiTouch(self)
end
function CastlePage:receiveMsg(name, msg)
    if name == EVENT_TYPE.DO_MOVE then
        self.blockMove = true
    elseif name == EVENT_TYPE.FINISH_MOVE then
        self.blockMove = false
    end
end
function CastlePage:enterScene()
    Event:registerEvent(EVENT_TYPE.DO_MOVE, self)
    Event:registerEvent(EVENT_TYPE.FINISH_MOVE, self)
end
function CastlePage:exitScene()
    Event:unregisterEvent(EVENT_TYPE.DO_MOVE, self)
    Event:unregisterEvent(EVENT_TYPE.FINISH_MOVE, self)
end

function CastlePage:initDataOver()
    print("CastlePage initDataOver!!!!!!!!!!!!!!")
    self.buildLayer:initDataOver()
end
function CastlePage:touchesBegan(touches)
    if not self.blockMove then
        self.touchDelegate:tBegan(touches)
        if self.movToAni == nil then
            self.scene:closeGlobalMenu(self)
        end
    end
end

function CastlePage:touchesMoved(touches)
    if not self.blockMove then
        self.touchDelegate:tMoved(touches)
    end
end
function CastlePage:touchesEnded(touches)
    --move距离小于一定的值
    local acMov = self.touchDelegate.accMove or 0
    if BattleLogic.inBattle and  acMov < 20 then

        local curChoose = self.scene.ml:getCurSol()
        if curChoose ~= nil then
            local n = getDefault(global.user.soldiers, curChoose, 0)
            if n > 0 then
                local temp = convertMultiToArr(touches)
                local temp = self.bg:convertToNodeSpace(ccp(temp[0][1], temp[0][2]))
                BattleLogic.updateKill(curChoose)
                self.scene.ml:updateKill(curChoose)
                print("curChoose", curChoose)
                self.buildLayer:addSoldier(curChoose, temp.x, temp.y) 

                local ani = CCAnimationCache:sharedAnimationCache():animationByName("tx2")
                local sp = setPos(CCSprite:create(string.format("tx2_%d.png", 0)), {temp.x, temp.y})
                self.bg:addChild(sp)
                sp:setScale(0.0)
                sp:runAction(repeatForever(CCAnimate:create(ani)))
                sp:runAction(sequence({fadein(0.2), delaytime(0.2), fadeout(0.2), callfunc(nil, removeSelf, sp)}))
                sp:runAction(sequence({scaleto(0.2, 0.2, 0.2)}))

                self.scene.state = BATTLE_STATE.IN_BATTLE
                self.scene.ml:startBattle()
            end

        end
    end

    if not self.blockMove then
        self.touchDelegate:tEnded(touches)
    end
end

function CastlePage:beginBuild(building)
    self.curBuild = Building.new(self.buildLayer, building, {})
    self.curBuild:setBid(global.user:getNewBid())
    self.buildLayer:addBuilding(self.curBuild, MAX_BUILD_ZORD)
    self.oldScale = self.bg:getScale()
    self.oldPos = getPos(self.bg)

    local kind = building['kind']
    local x, y = self.curBuild.bg:getPosition()
    self:moveToPoint(x, y)
    return self.curBuild
end
function CastlePage:clearAnimation()
    if self.movToAni ~= nil then
        self.bg:stopAction(self.movToAni)
        self.movToAni = nil
    end
end
function CastlePage:moveToPoint(tarX, tarY)
    print('moveToPoint', tarX, tarY)
    local worldPos = self.bg:convertToWorldSpace(ccp(tarX, tarY))
    local sSize = global.director.disSize

    local difx = sSize[1]/2-worldPos.x
    local dify = sSize[2]/2-worldPos.y

    local curPos = getPos(self.bg)
    curPos[1] = curPos[1] + difx
    curPos[2] = curPos[2] + dify

    print('world Pos', worldPos.x, worldPos.y)
    print('move to curPos', curPos[1], curPos[2])

    local backSize = self.bg:getContentSize()
    self.bg:setPosition(ccp(0, 0))
    local maxX = 0
    local maxY = 0
    local w2 = self.bg:convertToWorldSpace(ccp(backSize.width, backSize.height))
    local minX = sSize[1]-w2.x
    local minY = sSize[2]-w2.y

    curPos[1] = math.min(math.max(minX, curPos[1]), maxX)
    curPos[2] = math.min(math.max(minY, curPos[2]), maxY)
    
    local newScale = self.bg:getScale()
    self.bg:setScale(self.oldScale)
    setPos(self.bg, self.oldPos)

    self:clearAnimation()
    self.movToAni = sequence({spawn({expout(scaleto(0.5, newScale, newScale)), expout(moveto(0.5, curPos[1], curPos[2]))}), callfunc(self, self.finishMove)})
    print("scaleto, moveto", newScale, curPos[1], curPos[2])
    self.bg:runAction(self.movToAni)
end
function CastlePage:finishMove()
    self.movToAni = nil
end

function CastlePage:finishBuild()
    self.curBuild:finishBuild()
    self.curBuild = nil
end
function CastlePage:cancelBuild()
    self.buildLayer:removeBuilding(self.curBuild)
    --self.curBuild:cancelBuild()
    self.curBuild = nil
end

function CastlePage:moveToBuild(build)
    self.oldScale = self.bg:getScale()
    local sm = 1.5
    self.touchDelegate:scaleToMax(sm)

    self.oldPos = getPos(self.bg)
    local bSize = build.bg:getContentSize()
    local bPos = getPos(build.bg)
    bPos[2] = bPos[2]+bSize.width/2
    self:moveToPoint(bPos[1], bPos[2])
end
    
function CastlePage:closeGlobalMenu()
    if self.oldScale ~= nil then
        self.movToAni = sequence({spawn({scaleto(0.5, self.oldScale, self.oldScale), moveto(0.5, self.oldPos[1], self.oldPos[2])}), callfunc(self, self.finishMove)})
        self.bg:runAction(self.movToAni)
        self.oldScale = nil
        self.oldPos = nil
    end
end
