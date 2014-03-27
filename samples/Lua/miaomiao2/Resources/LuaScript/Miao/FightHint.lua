require "Miao.FightScene"
FightHint = class()
function FightHint:ctor()
    self.bg = CCNode:create()
    local vs = getVS()
    local temp = setPos(setContentSize(addChild(self.bg, display.newScale9Sprite("tabback.jpg")), {300, 240}), {vs.width/2, vs.height/2})
    local but = setPos(addChild(temp, ui.newButton({image="tabbut.png", text="进击", color={10, 10, 10}, size=15, delegate=self, callback=self.onFight}).bg), {150, fixY(240, 209)})
end
function FightHint:onFight()
    global.director:popView()
    global.director:pushScene(FightScene.new())
end
