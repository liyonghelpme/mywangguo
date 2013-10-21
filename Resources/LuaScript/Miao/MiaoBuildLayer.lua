require "model.MapGridController"
MiaoBuildLayer = class(MoveMap)
function MiaoBuildLayer:ctor(s)
    self.scene = s
    self.moveZone = {{0, 0, 1000, 1000}}
    self.buildZone = {{0, 0, 1000, 1000}}
    self.staticObstacle = {}

    
    self.bg = CCLayer:create()
    self.mapGridController = MapGridController.new(self)

    self.gridLayer = CCLayer:create()
    self.bg:addChild(self.gridLayer)
    self.cellLayer = CCLayer:create()
    self.bg:addChild(self.cellLayer)
    self.pathLayer = CCNode:create()
    self.bg:addChild(self.pathLayer)
end
