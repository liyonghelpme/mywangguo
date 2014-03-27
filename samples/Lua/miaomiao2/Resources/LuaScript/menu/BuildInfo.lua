--显示农田的信息
require "menu.MatInfo"
BuildInfo = class()
function BuildInfo:ctor(b)
    self.build = b
    local vs = getVS()

    self.bg = CCNode:create()
    local temp = display.newScale9Sprite("tabback.jpg")
    temp:setContentSize(CCSizeMake(407, 280))
    self.bg:addChild(temp)
    setPos(temp, {vs.width/2, vs.height/2})
    self.temp = temp

    local sz = temp:getContentSize()

    local tit = setPos(addSprite(temp, "title.png"), {sz.width/2, fixY(280, 31)})
    local w = ui.newTTFLabel({text="建筑情报", font="msyhbd.ttf", size=15, color={0,0,0}})
    temp:addChild(w)
    setAnchor(setPos(w, {sz.width/2, fixY(280, 31)}), {0.5, 0.5})
    self.title = w

    local w = ui.newTTFLabel({text="维修费", color={10, 20, 176}, size=14})
    setAnchor(setPos(addChild(temp, w), {314, fixY(280, 54)}), {1, 0.5})
    
    local w = ui.newTTFLabel({text="2贯", color={10, 10, 10}, size=14})
    setAnchor(setPos(addChild(temp, w), {367, fixY(280, 54)}), {1, 0.5})

    local head = setPos(addSprite(temp, "build2.png"), {83, fixY(280, 146)})
    
    local w = ui.newTTFLabel({text="在库", color={10, 20, 176}, size=14})
    setAnchor(setPos(addChild(temp, w), {213, fixY(280, 91)}), {1, 0.5})
    
    local banner = setSize(CCSprite:create("probg.png"), {100, 27})
    local pro = display.newScale9Sprite("pro1.png")
    banner:addChild(pro)
    setAnchor(setPos(pro, {27, fixY(76, 40)}), {0, 0.5})
    setPos(banner, {271, fixY(280, 91)})
    temp:addChild(banner)
    setProNum(pro, self.build.workNum, self.build.maxNum)
    
    local w = ui.newTTFLabel({text=self.build.workNum.."个", color={0, 0, 0}, size=14})
    setAnchor(setPos(addChild(temp, w), {366, fixY(280, 91)}), {1, 0.5})
    
    local w = ui.newTTFLabel({text="生产", color={10, 20, 176}, size=14})
    setAnchor(setPos(addChild(temp, w), {215, fixY(280, 126)}), {0, 0.5})

    local w = ui.newTTFLabel({text=self.build.funcBuild:getProductName(), color={0, 0, 0}, size=14})
    setAnchor(setPos(addChild(temp, w), {215, fixY(280, 152)}), {0, 0.5})

    local w = ui.newTTFLabel({text="价格", color={10, 20, 176}, size=14})
    setAnchor(setPos(addChild(temp, w), {315, fixY(280, 126)}), {0, 0.5})

    local w = ui.newTTFLabel({text=self.build.funcBuild:getProductPrice(), color={0, 0, 0}, size=14})
    setAnchor(setPos(addChild(temp, w), {315, fixY(280, 152)}), {0, 0.5})

    local w = ui.newTTFLabel({text="生产力", color={10, 20, 176}, size=14})
    setAnchor(setPos(addChild(temp, w), {224, fixY(280, 195)}), {0.5, 0.5})

    local w = ui.newTTFLabel({text=self.build.productNum, color={0, 0, 0}, size=14})
    setAnchor(setPos(addChild(temp, w), {327, fixY(280, 195)}), {0.5, 0.5})

    local but = ui.newButton({image="tabbut.png", text="查看材料情报", callback=self.onView, delegate=self, color={0, 0, 0}, size=14})
    setPos(addChild(temp, but.bg), {sz.width/2, fixY(sz.height, 247)})
end
function BuildInfo:onView()
    global.director:popView()
    global.director:pushView(MatInfo.new(), 1, 0)
end
--设定食材的数量
function BuildInfo:setNum(n)
end
