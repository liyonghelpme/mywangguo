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
    self.speed = 20

    if not self.fake then
        self.bg = CCSprite:create("soldier3.png")
        local p = getPos(self.start.bg)
        setPos(self.bg, p)
        self.moveTime = 0
        self.curPoint = 1
        self.path = {self.start.cid, self.endCity.cid}
        self.needUpdate = true
        self.fightPath = FightPath.new(self)
        registerEnterOrExit(self)
        Logic.challengeCity = self.endCity.cid
    else
        self.bg = CCNode:create()
    end
end

function MapCat:doFind(diff)
    self.fightPath:update()
    if self.fightPath.searchYet then
        self.path = self.fightPath:getPath()
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
            self.state = MAP_STATE.IN_FIND
            self.fightPath:init(self.start.cid, self.endCity.cid)
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
        end
    end
end

