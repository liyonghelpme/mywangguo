PeopleMenu2 = class()
function PeopleMenu2:ctor()
    local vs = getVS()
    self.bg = CCNode:create()
    self.temp = setPos(addNode(self.bg), {213, fixY(vs.height, 187)})
    local sz = {width=199, height=291}
    
    local sp = setSize(setPos(addSprite(self.temp, "mainBoard.png"), {99, fixY(sz.height, 145)}), {199, 291})
    local sp = setSize(setPos(addSprite(self.temp, "mainBa.png"), {99, fixY(sz.height, 112)}), {181, 60})
    local sp = setSize(setPos(addSprite(self.temp, "mainBa.png"), {99, fixY(sz.height, 42)}), {181, 60})
    local sp = setSize(setPos(addSprite(self.temp, "mainBa.png"), {99, fixY(sz.height, 180)}), {181, 60})
    local sp = setSize(setPos(addSprite(self.temp, "mainBa.png"), {99, fixY(sz.height, 249)}), {181, 60})
end
