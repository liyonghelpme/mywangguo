require 'myMap.FightPath'
MAP_STATE = {
    FREE = 0,
    IN_FIND = 1,
    MOVE = 2,
}
MapCat = class()
function MapCat:ctor(s, st, ed, fake)
    self.scene = s
    self.start = st
    self.endCity = ed
    self.fake = fake
    self.state = MAP_STATE.FREE
    self.speed = CAT_SPEED

    if not self.fake then
        self.bg = CCSprite:create("soldier3.png")
        local p = getPos(self.start.bg)
        setPos(self.bg, p)
        self.moveTime = 0
        self.curPoint = 1
        self.path = {self.start.cid, self.endCity.cid}
        self.needUpdate = true
        self.endCid = self.endCity.cid
        self.fightPath = FightPath.new(self)
        registerEnterOrExit(self)
        Logic.challengeCity = self.endCity.cid
        Logic.challengeNum = self.endCity.cityData
    else
        --self.bg = CCNode:create()
        self.endCid = self.endCity
    end
end

function MapCat:doFind(diff)
    self.fightPath:update()
    if self.fightPath.searchYet then
        self.path = self.fightPath:getPath()
        self.state = MAP_STATE.MOVE
    end
end

--退出场景
--经营页面的伪造猫咪 退出场景 也要保存数据 到catData 中这样在pushScene的时候加载这个数据
--经营页面push 的时候 主动保存数据即可
function MapCat:exitScene()
    --没有到达目的地呢
    --if not self.showYet then
    --    self:storeData()
    --end
end
function MapCat:storeData()
    Logic.catData = {path=self.path, curPoint=self.curPoint, moveTime=self.moveTime}
end

function MapCat:restoreData()
    local lc = Logic.catData
    self.path = lc.path
    self.curPoint = lc.curPoint
    self.moveTime = lc.moveTime
    --计算位置 初始化位置
    --加载一个移动函数
    --可能的bug 当前目标点 moveTime > dis 怎么办呢？
    if self.curPoint > 1 and self.curPoint <= #self.path then
        local lastPos = self.path[self.curPoint-1]
        lastPos = {MapNode[lastPos][1], MapNode[lastPos][2]}
        local xy =  self.path[self.curPoint]
        xy = {MapNode[xy][1], MapNode[xy][2]}
        local dis = distance(lastPos, xy)/self.speed
        self.moveTime = math.min(self.moveTime, dis)
        local np = lerp(lastPos, xy, self.moveTime/dis)
        setPos(self.bg, np)
        self.bg:runAction(moveto(self.moveTime, xy[1], xy[2]))
        self.state = MAP_STATE.MOVE
    elseif self.curPoint == 1 then
        local lastPos =  self.path[self.curPoint]
        lastPos = {MapNode[lastPos][1], MapNode[lastPos][2]}
        self.curPoint = self.curPoint+1
        local xy =  self.path[self.curPoint]
        xy = {MapNode[xy][1], MapNode[xy][2]}
        local dis = distance(lastPos, xy)/self.speed
        self.moveTime = math.min(self.moveTime, dis)
        setPos(self.bg, lastPos)
        self.bg:runAction(moveto(self.moveTime, xy[1], xy[2]))
        self.state = MAP_STATE.MOVE 
    else
        self.curPoint = #self.path
        local lastPos =  self.path[self.curPoint]
        lastPos = {MapNode[xy][1], MapNode[xy][2]}
        self.moveTime = 0
        setPos(self.bg, lastPos)
        self.state = MAP_STATE.MOVE 
    end
end
function MapCat:update(diff)
    --只更新猫位置 
    if self.fake then
        --load data from Logic 
        if self.state == MAP_STATE.FREE then
            local ld = Logic.catData
            self.pos = ld.pos
            self.path = ld.path
            self.curPoint = ld.curPoint
            self.moveTime = ld.moveTime
            self.state = MAP_STATE.MOVE
        elseif self.state == MAP_STATE.MOVE then
            self.moveTime = self.moveTime-diff
            if self.moveTime <= 0 then
                local nextPoint = self.curPoint+1
                if nextPoint > #self.path then
                    if not self.showYet then
                        self.showYet = true
                        addBanner("部队到达了")
                        --对话框提示用户点击 就进入战斗场景
                        --返回回来 之后需要 显示Fight Map 场景
                        global.director:pushScene(FightScene.new())
                        removeSelf(self.bg)
                        clearFight()
                    end
                else
                    local lastPos = self.path[self.curPoint]
                    lastPos = {MapNode[lastPos][1], MapNode[lastPos][2]} 
                    local xy = self.path[nextPoint]
                    xy = {MapNode[xy][1], MapNode[xy][2]}
                    local dis = distance(lastPos, xy)/self.speed
                    self.moveTime = dis
                    self.curPoint = nextPoint
                end
            end
        end
    else
        if self.state == MAP_STATE.FREE then
            if Logic.catData ~= nil then
                self:restoreData()
            else
                self.state = MAP_STATE.IN_FIND
                self.fightPath:init(self.start.cid, self.endCid)
            end
        elseif self.state == MAP_STATE.IN_FIND then
            self:doFind(diff)
        elseif self.state == MAP_STATE.MOVE then
            --print("cat Update", self.moveTime, self.curPoint, #self.path)
            self.moveTime = self.moveTime-diff
            if self.moveTime <= 0 then
                local nextPoint = self.curPoint+1
                --print("self path")
                if nextPoint > #self.path then
                    if not self.showYet then
                        self.showYet = true
                        addBanner("部队到达目标 开战了")
                        global.director:pushScene(FightScene.new())
                        removeSelf(self.bg)
                        clearFight()
                    end
                else
                    local xy =  self.path[nextPoint]
                    --local sz = getContentSize(self.scene.bg)
                    --sz[2]-
                    xy = {MapNode[xy][1], MapNode[xy][2]}
                    local p = getPos(self.bg)
                    local dis = distance(p, xy)/self.speed
                    self.bg:runAction(moveto(dis, xy[1], xy[2]))
                    self.moveTime = dis
                    self.curPoint = nextPoint
                end
            end
            --没有到达终点则 保存猫咪数据
            if not self.showYet then
                self:storeData()
            end
        end
    end
end

