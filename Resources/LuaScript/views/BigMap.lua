BigMap = class()
function BigMap:ctor()
    self.bg = CCNode:create()
    setDesignXY(self.bg)
    setMidPos(self.bg)
    
    local temp = CCSprite:create("back.png")
    self.bg:addChild(temp)
    setAnchor(temp, {0, 0})
    local temp = addSprite(self.bg, "rightBack.png")
    setPos(setSize(temp, {754, 391}), {400, fixY(480, 66+391/2)})
    local temp = setPos(addSprite(self.bg, "map_label.png"), {400, fixY(480, 28)})
    
    local flowNode = addNode(self.bg)
    self.flowNode = flowNode
    local temp = ui.newButton({image="scroll.png", callback=self.onScroll, delegate=self, param=0})
    temp:setAnchor(0.5, 0.5)
    setPos(temp.bg, {400, fixY(480, 123)})
    flowNode:addChild(temp.bg)

    local lab = ui.newTTFLabel({text="1 挑战自我", size=18, color={0, 0, 0}})
    temp.bg:addChild(lab)
    setPos(setAnchor(lab, {0, 0.5}), {40-541/2, 0})
end
function BigMap:onScroll()
    global.director:popView()
    BattleLogic.prepareState()
    --挑战自我功能
    BattleLogic.challengeWho = global.user.uid
    global.director:pushView(Cloud.new(), 1, 0)
end
