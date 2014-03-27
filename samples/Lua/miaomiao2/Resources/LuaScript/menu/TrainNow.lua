require "menu.TrainOver"
TrainNow = class()
function TrainNow:ctor()
    local vs = getVS()

    self.bg = CCNode:create()
    local temp = display.newScale9Sprite("tabback.jpg")
    temp:setContentSize(CCSizeMake(526, 370))
    self.bg:addChild(temp)
    setPos(temp, {vs.width/2, vs.height/2})
    self.temp = temp

    local tit = setPos(addSprite(temp, "title.png"), {263, fixY(370, 31)})
    local w = ui.newTTFLabel({text="村民的情报", font="msyhbd.ttf", size=15, color={0,0,0}})
    temp:addChild(w)
    setAnchor(setPos(w, {263, fixY(370, 31)}), {0.5, 0.5})
    self.title = w

    local w = ui.newTTFLabel({text="万米授田", font="msyhbd.ttf", size=15, color={0,0,0}})
    temp:addChild(w)
    setAnchor(setPos(w, {184, fixY(370, 71)}), {0.5, 0.5})

    local w = ui.newTTFLabel({text="Lv", font="msyhbd.ttf", size=15, color={0,0,0}})
    temp:addChild(w)
    setAnchor(setPos(w, {413, fixY(370, 71)}), {0, 0.5})

    local w = ui.newTTFLabel({text="16", font="msyhbd.ttf", size=15, color={0,0,0}})
    temp:addChild(w)
    setAnchor(setPos(w, {472, fixY(370, 71)}), {1, 0.5})

    local head = setSize(setPos(addSprite(temp, "business_trader_1.png"), {116, fixY(370, 116)}), {40, 40})

    local w = ui.newTTFLabel({text="武", font="msyhbd.ttf", size=15, color={8,20,176}})
    temp:addChild(w)
    setAnchor(setPos(w, {58, fixY(370, 176)}), {0.5, 0.5})
    
    local w = ui.newTTFLabel({text="长刀", font="msyhbd.ttf", size=15, color={8,20,176}})
    temp:addChild(w)
    setAnchor(setPos(w, {139, fixY(370, 176)}), {0.5, 0.5})

    local w = ui.newTTFLabel({text="头", font="msyhbd.ttf", size=15, color={8,20,176}})
    temp:addChild(w)
    setAnchor(setPos(w, {58, fixY(370, 206)}), {0.5, 0.5})

    local w = ui.newTTFLabel({text="头巾", font="msyhbd.ttf", size=15, color={8,20,176}})
    temp:addChild(w)
    setAnchor(setPos(w, {139, fixY(370, 206)}), {0.5, 0.5})


    local w = ui.newTTFLabel({text="体", font="msyhbd.ttf", size=15, color={8,20,176}})
    temp:addChild(w)
    setAnchor(setPos(w, {58, fixY(370, 236)}), {0.5, 0.5})
    
    local w = ui.newTTFLabel({text="桶甲", font="msyhbd.ttf", size=15, color={8,20,176}})
    temp:addChild(w)
    setAnchor(setPos(w, {139, fixY(370, 236)}), {0.5, 0.5})

    local w = ui.newTTFLabel({text="体", font="msyhbd.ttf", size=15, color={8,20,176}})
    temp:addChild(w)
    setAnchor(setPos(w, {58, fixY(370, 236)}), {0.5, 0.5})
    
    local w = ui.newTTFLabel({text="桶甲", font="msyhbd.ttf", size=15, color={8,20,176}})
    temp:addChild(w)
    setAnchor(setPos(w, {139, fixY(370, 236)}), {0.5, 0.5})

    local w = ui.newTTFLabel({text="体", font="msyhbd.ttf", size=15, color={8,20,176}})
    temp:addChild(w)
    setAnchor(setPos(w, {58, fixY(370, 236)}), {0.5, 0.5})
    
    local w = ui.newTTFLabel({text="桶甲", font="msyhbd.ttf", size=15, color={8,20,176}})
    temp:addChild(w)
    setAnchor(setPos(w, {139, fixY(370, 236)}), {0.5, 0.5})

    local w = ui.newTTFLabel({text="特", font="msyhbd.ttf", size=15, color={8,20,176}})
    temp:addChild(w)
    setAnchor(setPos(w, {58, fixY(370, 266)}), {0.5, 0.5})
    
    local w = ui.newTTFLabel({text="草药", font="msyhbd.ttf", size=15, color={8,20,176}})
    temp:addChild(w)
    setAnchor(setPos(w, {139, fixY(370, 266)}), {0.5, 0.5})

    local w = ui.newTTFLabel({text="技", font="msyhbd.ttf", size=15, color={8,20,176}})
    temp:addChild(w)
    setAnchor(setPos(w, {58, fixY(370, 296)}), {0.5, 0.5})
    
    local w = ui.newTTFLabel({text="物资搬运", font="msyhbd.ttf", size=15, color={10,10,10}})
    temp:addChild(w)
    setAnchor(setPos(w, {139, fixY(370, 296)}), {0.5, 0.5})


    local w = ui.newTTFLabel({text="攻击", font="msyhbd.ttf", size=15, color={8,20,176}})
    temp:addChild(w)
    setAnchor(setPos(w, {258, fixY(370, 119)}), {0, 0.5})

    local banner = setSize(CCSprite:create("probg.png"), {150, 29})
    local pro = display.newScale9Sprite("pro.png")
    banner:addChild(pro)
    setAnchor(setPos(pro, {27, fixY(76, 40)}), {0, 0.5})
    setPos(banner, {370, fixY(370, 119)})
    temp:addChild(banner)
    
    local w = ui.newTTFLabel({text="41", font="msyhbd.ttf", size=15, color={8,20,176}})
    temp:addChild(w)
    setAnchor(setPos(w, {483, fixY(370, 119)}), {1, 0.5})


    local w = ui.newTTFLabel({text="防御", font="msyhbd.ttf", size=15, color={8,20,176}})
    temp:addChild(w)
    setAnchor(setPos(w, {258, fixY(370, 149)}), {0, 0.5})

    local banner = setSize(CCSprite:create("probg.png"), {150, 29})
    local pro = display.newScale9Sprite("pro.png")
    banner:addChild(pro)
    setAnchor(setPos(pro, {27, fixY(76, 40)}), {0, 0.5})
    setPos(banner, {370, fixY(370, 149)})
    temp:addChild(banner)
    
    local w = ui.newTTFLabel({text="41", font="msyhbd.ttf", size=15, color={8,20,176}})
    temp:addChild(w)
    setAnchor(setPos(w, {483, fixY(370, 149)}), {1, 0.5})
    

    local w = ui.newTTFLabel({text="体力", font="msyhbd.ttf", size=15, color={8,20,176}})
    temp:addChild(w)
    setAnchor(setPos(w, {258, fixY(370, 179)}), {0, 0.5})

    local banner = setSize(CCSprite:create("probg.png"), {150, 29})
    local pro = display.newScale9Sprite("pro.png")
    banner:addChild(pro)
    setAnchor(setPos(pro, {27, fixY(76, 40)}), {0, 0.5})
    setPos(banner, {370, fixY(370, 179)})
    temp:addChild(banner)
    
    local w = ui.newTTFLabel({text="167", font="msyhbd.ttf", size=15, color={8,20,176}})
    temp:addChild(w)
    setAnchor(setPos(w, {483, fixY(370, 179)}), {1, 0.5})


    local w = ui.newTTFLabel({text="腕力", font="msyhbd.ttf", size=15, color={8,20,176}})
    temp:addChild(w)
    setAnchor(setPos(w, {258, fixY(370, 209)}), {0, 0.5})

    local banner = setSize(CCSprite:create("probg.png"), {150, 29})
    local pro = display.newScale9Sprite("pro.png")
    banner:addChild(pro)
    setAnchor(setPos(pro, {27, fixY(76, 40)}), {0, 0.5})
    setPos(banner, {370, fixY(370, 209)})
    temp:addChild(banner)
    
    local w = ui.newTTFLabel({text="45", font="msyhbd.ttf", size=15, color={8,20,176}})
    temp:addChild(w)
    setAnchor(setPos(w, {483, fixY(370, 209)}), {1, 0.5})


    local w = ui.newTTFLabel({text="射击", font="msyhbd.ttf", size=15, color={8,20,176}})
    temp:addChild(w)
    setAnchor(setPos(w, {258, fixY(370, 239)}), {0, 0.5})

    local banner = setSize(CCSprite:create("probg.png"), {150, 29})
    local pro = display.newScale9Sprite("pro.png")
    banner:addChild(pro)
    setAnchor(setPos(pro, {27, fixY(76, 40)}), {0, 0.5})
    setPos(banner, {370, fixY(370, 239)})
    temp:addChild(banner)
    
    local w = ui.newTTFLabel({text="7", font="msyhbd.ttf", size=15, color={8,20,176}})
    temp:addChild(w)
    setAnchor(setPos(w, {483, fixY(370, 239)}), {1, 0.5})


    local w = ui.newTTFLabel({text="劳动", font="msyhbd.ttf", size=15, color={8,20,176}})
    temp:addChild(w)
    setAnchor(setPos(w, {258, fixY(370, 269)}), {0, 0.5})

    local banner = setSize(CCSprite:create("probg.png"), {150, 29})
    local pro = display.newScale9Sprite("pro.png")
    banner:addChild(pro)
    setAnchor(setPos(pro, {27, fixY(76, 40)}), {0, 0.5})
    setPos(banner, {370, fixY(370, 269)})
    temp:addChild(banner)
    
    local w = ui.newTTFLabel({text="38", font="msyhbd.ttf", size=15, color={8,20,176}})
    temp:addChild(w)
    setAnchor(setPos(w, {483, fixY(370, 269)}), {1, 0.5})


    local w = ui.newTTFLabel({text="费用", font="msyhbd.ttf", size=15, color={8,20,176}})
    temp:addChild(w)
    setAnchor(setPos(w, {258, fixY(370, 299)}), {0, 0.5})

    local w = ui.newTTFLabel({text="2820贯", font="msyhbd.ttf", size=15, color={8,20,176}})
    temp:addChild(w)
    setAnchor(setPos(w, {483, fixY(370, 299)}), {1, 0.5})

    local but = ui.newButton({image="tabbut.png", text="进行修习", size=18, color={10, 10, 10}, callback=self.onTrain, delegate=self})
    setPos(but.bg, {263, fixY(370, 350)})
    addChild(temp, but.bg)
end

function TrainNow:onTrain()
    global.director:popView()
    global.director:pushView(TrainOver.new(), 1, 0)
end
