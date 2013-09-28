require "views.Goods"
require "views.Choice"
Store = class()
function Store:ctor(s)
    self.scene = s
    self.allGoods = StoreGoods
    self.pics = {
     "goodTreasure.png", "goodBuild.png", "goodDecor.png",  "goodWeapon.png", "goodMagic.png",
    }
    self.titles = {
    "buyTreasure.png", "buyBuild.png", "buyDecor.png", "buyWeapon.png", "buyMagic.png",
    }
    self.bg = CCNode:create()
    setSize(setPos(setAnchor(addSprite(self.bg, "images/back.png"), {0, 0}), {0, 0}), global.director.disSize)
    setPos(setAnchor(addSprite(self.bg, "images/diaBack.png"), {0.5, 1}), {global.director.disSize[1]/2, global.director.disSize[2]-10})

    setPos(setAnchor(addSprite(self.bg, "images/rightBack.png"), {0, 0}), {254, fixY(nil, 79, 387)})
    setPos(setAnchor(addSprite(self.bg, "images/storeLeft.png"), {0, 0}), {34, fixY(nil, 79, 387)})

    local choose = setPos(setAnchor(CCSprite:create("images/instructArrow.png"), {0, 0}), {22, fixY(nil, 211, 117)})
    self.bg:addChild(choose, 1)

    setPos(setAnchor(addSprite(self.bg, "images/moneyBack.png"), {0, 0}), {274, fixY(nil, 28, 33)})
    setSize(setPos(setAnchor(addSprite(self.bg, "images/crystal.png"), {0, 0}), {586, fixY(nil, 30, 29)}), {31, 29})
    setSize(setPos(setAnchor(addSprite(self.bg, "images/gold.png"), {0, 0}), {439, fixY(nil, 30, 29)}), {31, 29})
    setSize(setPos(setAnchor(addSprite(self.bg, "images/silver.png"), {0, 0}), {280, fixY(nil, 30, 29)}), {31, 29})

    setPos(setAnchor(addSprite(self.bg, "images/storeTit.png"), {0, 0}), {76, fixY(nil, 7, 63)})

    self.goods = Goods.new(self)
    self.bg:addChild(self.goods.bg)

    self.tabs = Choice.new(self)
    self.bg:addChild(self.tabs.bg)

    setPos(setAnchor(addSprite(self.bg, "images/leftBoard.png"), {0, 0}), {29, fixY(nil, 74, 396)})
    local but0 = ui.newButton({image="images/closeBut.png", delegate=self, callback=self.closeDialog}):setAnchor(0.5, 0.5)
    setPos(but0.bg, {772, fixY(nil, 27, nil, 0.5)})
    self.bg:addChild(but0.bg)

    self:initData()
    self.curSel = -1
    self:changeTab(1)
    --self:setTab(1)
end
function Store:closeDialog()
    global.director:popView()
end
function Store:initData()
end
function Store:changeTab(i)
    self.tabs:changeTab(i);
end
function Store:setTab(i)
    if i >= 0 and i < #self.allGoods then
        if self.curSel ~= i then
            self.curSel = i
            self.goods:setTab(i)
        end
    end
end
function Store:buy(gi)
    print("Store buy", gi[1], gi[2])
    local item = self.allGoods[gi[1]+1][gi[2]+1]
    local kind = item[1]
    local id = item[2]
    local cost
    local buyable
    local ret

    if kind == GOODS_KIND.BUILD then
        global.director:popView()
        self.scene:beginBuild(id)
    end
end
