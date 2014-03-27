TMXLayer = class(MoveMap)
function TMXLayer:ctor(s)
    self.scene = s
    self.moveZone = {{0, 0, 3136, 1568}}
    self.buildZone = {{0, 0, 3136, 1568}}

    self.bg = CCLayer:create()
end
