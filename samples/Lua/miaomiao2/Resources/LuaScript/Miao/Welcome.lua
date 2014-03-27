Welcome = class()
function Welcome:ctor()
    self.bg = CCNode:create()
    local vs = getVS()
    local temp = setPos(setContentSize(addChild(self.bg, display.newScale9Sprite("tabback.jpg")), {407, 240}), {vs.width/2, vs.height/2})
    self.temp = temp
    
    --local con = ui.newTTFLabel({text=StoryWord[Logic.story], size=15, color={0, 0, 0}})
    local con = colorLine({text=StoryWord[Logic.story], color={0, 0, 0}, size=15, width=341}) 
    setAnchor(setPos(addChild(temp, con), {27, fixY(240, 43)}), {0, 0})
    self.con = con

    local but = ui.newButton({image="tabbut.png", text="开始游戏", size=15, color={0, 0, 0}, callback=self.onOk, delegate=self})
    setPos(but.bg, {203, fixY(240, 216)})
    temp:addChild(but.bg)
end
function Welcome:onOk()
    --global.director:popView()
    Logic.story = Logic.story+1
    if Logic.story >= #StoryWord then
        global.director:popView()
        return
    end

    removeSelf(self.con)
    local con = colorLine({text=StoryWord[Logic.story], color={0, 0, 0}, size=15, width=341}) 
    setAnchor(setPos(addChild(self.temp, con), {27, fixY(240, 43)}), {0, 1})
    self.con = con
end
