FuncPeople = class()
function FuncPeople:ctor(s)
    self.people = s
end
function FuncPeople:initView()
    --不同人物动画的角度也有可能不同
    self.people.changeDirNode = CCSprite:create("people"..self.people.id.."_lb_0.png")
    local sz = self.people.changeDirNode:getContentSize()
    --人物图像向上偏移一半高度 到达块中心位置
    setAnchor(self.people.changeDirNode, {Logic.people[1].ax/sz.width, (sz.height-Logic.people[1].ay-SIZEY)/sz.height})
    self.people.stateLabel = ui.newBMFontLabel({text=str(self.people.state), size=20})
    setPos(self.people.stateLabel, {0, 100})
    self.people.bg:addChild(self.people.stateLabel)
    
    createAnimation("people"..self.people.id.."_lb", "people"..self.people.id.."_lb_%d.png", 0, 4, 1, 0.5, false)
    createAnimation("people"..self.people.id.."_lt", "people"..self.people.id.."_lt_%d.png", 0, 4, 1, 0.5, false)
    createAnimation("people"..self.people.id.."_rb", "people"..self.people.id.."_rb_%d.png", 0, 4, 1, 0.5, false)
    createAnimation("people"..self.people.id.."_rt", "people"..self.people.id.."_rt_%d.png", 0, 4, 1, 0.5, false)
    createAnimation("peopleSend", "people3_%d.png", 1, 11, 1, 1, false)
end
function FuncPeople:checkWork(k)
    return false
end
--必须使用 road来寻路
function FuncPeople:mustRoad()
    return true
end
function FuncPeople:findTarget()
end
function FuncPeople:setPos()
    local p = getPos(self.people.bg)
    local ax, ay = newCartesianToAffine(p[1], p[2], self.people.map.scene.width, self.people.map.scene.height, MapWidth/2, FIX_HEIGHT)
    local hei = adjustNewHeight(self.people.map.scene.mask, self.people.map.scene.width, ax, ay)
    print("adjust People Height !!!!!!!!!!!!!!!!!!!!!!!!!", ax, ay, hei)
    setPos(self.people.heightNode, {0, 103*hei})
end
function FuncPeople:updateState(diff)
end
function FuncPeople:findPathError()
end
function FuncPeople:checkMovable(k)
    return true
end

function FuncPeople:buildMove()
    self.people:clearStateStack()
    self.people:resetState()
end

function FuncPeople:workNow()
end
function FuncPeople:handleAction(diff)
end
