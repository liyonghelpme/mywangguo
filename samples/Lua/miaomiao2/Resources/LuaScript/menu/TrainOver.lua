TrainOver = class()
function TrainOver:ctor()
    local vs = getVS()

    self.bg = CCNode:create()
    local temp = display.newScale9Sprite("tabback.jpg")
    temp:setContentSize(CCSizeMake(406, 230))
    self.bg:addChild(temp)
    setPos(temp, {vs.width/2, vs.height/2})
    self.temp = temp

    local tit = setPos(addSprite(temp, "title.png"), {203, fixY(230, 31)})
    local w = ui.newTTFLabel({text="修行", font="msyhbd.ttf", size=15, color={0,0,0}})
    temp:addChild(w)
    setAnchor(setPos(w, {203, fixY(230, 31)}), {0.5, 0.5})
    self.title = w


    local w = ui.newTTFLabel({text="夏天春福", font="msyhbd.ttf", size=15, color={0,0,0}})
    temp:addChild(w)
    setAnchor(setPos(w, {103, fixY(230, 67)}), {0.5, 0.5})

    local w = ui.newTTFLabel({text="Lv", font="msyhbd.ttf", size=15, color={0,0,0}})
    temp:addChild(w)
    setAnchor(setPos(w, {278, fixY(230, 67)}), {0.5, 0.5})

    local w = ui.newTTFLabel({text="16", font="msyhbd.ttf", size=15, color={0,0,0}})
    temp:addChild(w)
    setAnchor(setPos(w, {328, fixY(230, 67)}), {0.5, 0.5})

    local head = setPos(setSize(addSprite(temp, "business_trader_2.png"), {100, 100}), {91, fixY(230, 155)})

    local w = ui.newTTFLabel({text="修行中", font="msyhbd.ttf", size=15, color={8,20,176}})
    temp:addChild(w)
    setAnchor(setPos(w, {268, fixY(230, 129)}), {0.5, 0.5})

    local banner = setSize(CCSprite:create("probg.png"), {190, 36})
    local pro = display.newScale9Sprite("pro1.png")
    banner:addChild(pro)
    setAnchor(setPos(pro, {27, fixY(76, 40)}), {0, 0.5})
    setPos(banner, {278, fixY(230, 164)})
    temp:addChild(banner)

    self.pro = pro
    setContentSize(self.pro, {28, 29})
    
    registerEnterOrExit(self)
    self.passTime = 0
    self.curP = 0
end
function TrainOver:enterScene()
    registerUpdate(self)
end
--339 - 29 = 310/100 = 3.1
function TrainOver:update(diff)
    setContentSize(self.pro, {3.1*self.curP, 29})
    self.curP = self.curP+1
    if self.curP >= 100 then
        global.director:popView()
        global.director:pushView(TrainNow.new(), 1, 0)
    end
end
