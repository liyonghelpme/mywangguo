require 'myMap.FightPath'
MAP_STATE = {
    FREE = 0,
    IN_FIND = 1,
    MOVE = 2,
}
MapCat = class()
function MapCat:ctor(s, st, ed)
    self.scene = s
    self.start = st
    self.endCity = ed
    self.bg = CCSprite:create("soldier3.png")
    local p = getPos(self.start.bg)
    setPos(self.bg, p)
    self.state = MAP_STATE.FREE
    self.moveTime = 0
    self.curPoint = 1
    self.path = {{0, 0}, getPos(self.endCity.bg)}
    self.needUpdate = true
    self.fightPath = FightPath.new(self)
    registerEnterOrExit(self)
end
function MapCat:doFind(diff)
    self.fightPath:update()
    if self.fightPath.searchYet then
        self.state = MAP_STATE.MOVE
    end
end
function MapCat:update(diff)
    if self.state == MAP_STATE.FREE then
        self.state = MAP_STATE.IN_FIND
        self.fightPath:init()
    elseif self.state == MAP_STATE.IN_FIND then
        self:doFind(diff)
    elseif self.state == MAP_STATE.MOVE then
        print("cat Update", self.moveTime, self.curPoint, #self.path)
        self.moveTime = self.moveTime-diff
        if self.moveTime <= 0 then
            local nextPoint = self.curPoint+1
            print("self path")
            if nextPoint > #self.path then

            else
                local xy =  self.path[nextPoint]
                local p = getPos(self.bg)
                local dis = distance(p, xy)/10 
                self.bg:runAction(moveto(dis, xy[1], xy[2]))
                self.moveTime = dis
                self.curPoint = nextPoint
            end
        end
    end
end

