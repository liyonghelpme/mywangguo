BuildMenu = class()
function BuildMenu:ctor(s, b)
    self.scene = s
    self.building = b
    if self.building == nil then
        self.inPlan = 1
    end

    self.setYet = false
    self.bg = CCNode:create()
    self.sp = setSca(setAnchor(setPos(addSprite(self.bg, "buildMenuBack.png"), {0, 0}), {0, 0}), global.director.disSize[1]/global.director.designSize[1])
    self.buttonNode = nil
    self:setBuilding(b)
end
function BuildMenu:setBuilding(b)
    if b ~= nil then
        self.opKind = b[1]
        self.building = b[2].data
    else
        self.building = nil
    end
    if self.buttonNode ~= nil then
        self.setYet = true
        removeSelf(self.buttonNode)
    end
    self.buttonNode = addNode(self.bg)
    local buildOk = self.onOk
    local buildCancel = self.onCancel
    if self.inPlan == 1 then
        buildOk = self.finishPlan
        buildCancel = self.cancelPlan
    end
    local sz = self.sp:getContentSize()

    if self.building == nil then
        if self.setYet == true then
            local but0 = ui.newButton({image="buildOk0.png", delegate=self, callback=buildOk})
            self.buttonNode:addChild(but0.bg)
            but0:setContentSize(50, 48)
            setPos(but0.bg, {669, fixY(sz.height, 8, 48)})
        end
        local but1 = ui.newButton({image='buildCancel1.png', delegate=self, callback=buildCancel})
        setPos(but1.bg, {727, fixY(sz.height, 8, 45)})
        self.buttonNode:addChild(but1.bg)
        return 
    end
    
    if self.opKind == PLAN_KIND.PLAN_BUILDING then
        local kind = self.building["funcs"]
        local butNum = 2

        local but0 = ui.newButton({image="buildOk0.png", delegate=self, callback=buildOk})
        self.buttonNode:addChild(but0.bg)
        but0:setContentSize(50, 48)
        setPos(but0.bg, {611, fixY(sz.height, 8, 48)})

        local but1 = ui.newButton({image='images/buildCancel1.png', delegate=self, callback=buildCancel})
        setPos(but1.bg, {669, fixY(sz.height, 8, 45)})
        self.buttonNode:addChild(but1.bg)

        local label = ui.newTTFLabel({text=getStr("dragBuild", nil), font="", size=22})
        setPos(setAnchor(label, {0, 0.5}), {24, 32})
        self.buttonNode:addChild(label)
    end

end

function BuildMenu:onOk()
    self.scene:finishBuild()
end
function BuildMenu:onCancel()
    self.scene:cancelBuild()
end
function BuildMenu:finishPlan()
    self.scene:finishPlan()
end
function BuildMenu:cancelPlan()
    self.scene:cancelPlan()
end

