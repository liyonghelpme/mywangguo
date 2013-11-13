FuncPeople = class()
function FuncPeople:ctor(s)
    self.people = s
end
function FuncPeople:initView()
    self.people.bg = CCNode:create()
    --不同人物动画的角度也有可能不同
    self.people.changeDirNode = addSprite(self.people.bg, "people"..self.people.id.."_lb_0.png")
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
