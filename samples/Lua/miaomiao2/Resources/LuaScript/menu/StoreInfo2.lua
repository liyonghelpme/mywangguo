require "menu.MatInfo3"
require "menu.ChangeGoods"
StoreInfo2 = class()
function StoreInfo2:ctor(b)
    self.build = b
    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=1024, height=768}
    self.temp = setPos(addNode(self.bg), {-13.5, fixY(sz.height, 0+sz.height)+4})

    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "dialogA.png"), {525, fixY(sz.height, 388)}), {693, 588}), {0.50, 0.50}), 255)
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "dialogB.png"), {523, fixY(sz.height, 418)}), {626, 358}), {0.50, 0.50}), 255)
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="维修费用"..self.build.data.repairCost.."银币", size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {1.00, 0.50}), {820, fixY(sz.height, 215)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text=self.build.data.name, size=26, color={32, 112, 220}, font="f2", shadowColor={255, 255, 255}})), {0.00, 0.50}), {259, fixY(sz.height, 215)})
    local but = ui.newButton({image="newClose.png", text="", font="f1", size=18, delegate=self, callback=closeDialog, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(80, 82)
    setPos(addChild(self.temp, but.bg), {848, fixY(sz.height, 112)})
    local but = ui.newButton({image="butc.png", text="更改商品", font="f1", size=27, delegate=self, callback=self.onBut, shadowColor={0, 0, 0}, color={255, 255, 255}})
    self.changeBut = but
    but:setContentSize(158, 50)
    setPos(addChild(self.temp, but.bg), {533, fixY(sz.height, 625)})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "buildInfo.png"), {531, fixY(sz.height, 148)}), {212, 42}), {0.50, 0.50}), 255)


    local sp = setAnchor(setSize(setPos(addSprite(self.temp, "storeTable.png"), {629, fixY(sz.height, 424)}), {325, 153}), {0.50, 0.50})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text=self.build.data.des, size=28, color={255, 255, 255}, font="f2"})), {0.50, 0.50}), {544, fixY(sz.height, 557)})
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="商品", size=28, color={255, 255, 255}, font="f2"})), {0.50, 0.50}), {568, fixY(sz.height, 371)})
    self.goodsW = w 
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="价格", size=28, color={255, 255, 255}, font="f2"})), {0.50, 0.50}), {733, fixY(sz.height, 371)})
    self.priceW = w
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="贩卖力", size=25, color={248, 181, 81}, font="f2"})), {0.50, 0.50}), {569, fixY(sz.height, 479)})
    self.ability = w
    local gn = '--'
    local price = '--'
    if self.build.goodsKind ~= nil then
        gn = GoodsName[self.build.goodsKind].name
        price = GoodsName[self.build.goodsKind].price
    end
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text=gn, size=25, color={248, 181, 81}, font="f2"})), {0.50, 0.50}), {568, fixY(sz.height, 415)})
    self.goodName = w

    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text=price.."银币", size=25, color={248, 181, 81}, font="f2"})), {0.50, 0.50}), {731, fixY(sz.height, 416)})
    self.price = w
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text=self.build.productNum, size=25, color={248, 181, 81}, font="f2"})), {0.50, 0.50}), {736, fixY(sz.height, 481)})
    local sp = setAnchor(setPos(addChild(self.temp, CCSprite:create("build"..self.build.id..".png")), {346, fixY(sz.height, 427)}), {0.50, 0.50})
    local sca = getSca(sp, {210, 210})
    setScale(sp, sca)

    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text=self.build.workNum.."个", size=25, color={248, 181, 81}, font="f2"})), {1.00, 0.50}), {791, fixY(sz.height, 301)})
    self.workNum = w
    local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="在库", size=28, color={255, 255, 255}, font="f2"})), {0.00, 0.50}), {468, fixY(sz.height, 302)})
    self.inGoods = w



    local banner = setAnchor(setSize(setPos(addSprite(self.temp, "probackC.png"), {617, fixY(sz.height, 301)}), {140, 29}), {0.50, 0.50})
    self.banner = banner
    local sp = setAnchor(setPos(addSprite(banner, "procolC.png"), {4, fixY(29, 24)}), {0.00, 0.00})
    self.pro = sp
    storeProNum(sp, self.build.workNum, self.build.maxNum)
    self:initFarm()
    self:initFactory()
    self:initHouse()

    centerUI(self)
end

function storeProNum(banner, n, max)
    if n <= 0 then
        banner:setVisible(false)
    else
        banner:setVisible(true)
        local wid = math.floor((n/max)*130)
        wid = math.max(0, wid)
        setSize(banner, {wid, 20})
    end
end

function StoreInfo2:onBut()
    global.director:pushView(ChangeGoods.new(self.build), 1)
end

function StoreInfo2:refreshData()
    local gn = '--'
    local price = '--'
    if self.build.goodsKind ~= nil then
        gn = GoodsName[self.build.goodsKind].name
        price = GoodsName[self.build.goodsKind].price
    end
    self.workNum:setString(self.build.workNum..'个')
    self.goodName:setString(gn)
    self.price:setString(price)
    storeProNum(self.pro, self.build.workNum, self.build.maxNum)
end

require "menu.StoreInfo2Static"
