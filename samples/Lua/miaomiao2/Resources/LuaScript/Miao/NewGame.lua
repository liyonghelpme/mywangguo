require "Miao.Welcome"
NewGame = class()
function NewGame:ctor()
    self.bg = CCNode:create()
    local vs = getVS()
    local temp = setPos(setContentSize(addChild(self.bg, display.newScale9Sprite("tabback.jpg")), {407, 240}), {vs.width/2, vs.height/2})
    local but = ui.newButton({image="tabbut.png", text="开始游戏", size=15, color={0, 0, 0}, callback=self.onGo, delegate=self})
    setPos(but.bg, {203, fixY(240, 216)})
    temp:addChild(but.bg)
    
    local vname = setAnchor(setPos(addChild(temp, ui.newTTFLabel({text="村落名称", size=15, color={0, 0, 0}})), {102, fixY(240, 58)}), {1, 0.5})
    local edit = ui.newEditBox({image="input.png", size={184, 34}, listener = self.onEdit, delegate=self}) 
    temp:addChild(edit)
    setPos(edit, {238, fixY(240, 59)})

    local vname = setAnchor(setPos(addChild(temp, ui.newTTFLabel({text="家族姓氏", size=15, color={0, 0, 0}})), {102, fixY(240, 107)}), {1, 0.5})
    local edit = ui.newEditBox({image="input.png", size={184, 34}, listener = self.onEdit, delegate=self}) 
    temp:addChild(edit)
    setPos(edit, {238, fixY(240, 107)})

    local vname = setAnchor(setPos(addChild(temp, ui.newTTFLabel({text="村民名称", size=15, color={0, 0, 0}})), {102, fixY(240, 173)}), {1, 0.5})
    local edit = ui.newEditBox({image="input.png", size={184, 34}, listener = self.onEdit, delegate=self}) 
    temp:addChild(edit)
    setPos(edit, {238, fixY(240, 173)})
end
function NewGame:onGo()
    global.director:popView()
    global.director:pushView(Welcome.new(), 1, 0)
end
function NewGame:onEdit()
end
