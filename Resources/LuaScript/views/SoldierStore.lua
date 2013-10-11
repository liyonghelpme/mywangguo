require "views.SoldierGoods"
SoldierStore = class()
function SoldierStore:ctor(s)
    self.scene = s
    self:initView()
end
function SoldierStore:onClose()
    global.director:popView()
end

--复用商店上半部分
function SoldierStore:initView()
    self.bg = CCLayer:create()
    local temp
    local but0
    local sz = {800, 480}

    temp = setPos(setAnchor(addSprite(self.bg, "back.png"), {0, 0}), {0, 0})
    temp = setPos(setAnchor(addSprite(self.bg, "diaBack.png"), {0, 0}), {38, 10})
    temp = setSize(setPos(setAnchor(addSprite(self.bg, "moneyBack.png"), {0, 0}), {274, 27}), {450, 33})
    but0 = ui.newButton({image="closeBut.png", delegate=self, callback=self.onClose})
    setPos(but0.bg, {772, 27})
    self.bg:addChild(but0.bg)
    

    temp = setPos(setAnchor(addSprite(self.bg, "rightBack.png"), {0, 1}), {252, fixY(sz[2], 77)})
    temp = setPos(setAnchor(addSprite(self.bg, "leftBack.png"), {0, 1}), {32, fixY(sz[2], 77)})
    --temp = setPos(setAnchor(addSprite(self.bg, "infoBack.png"), {0, 0}), {31, 246})
    temp = setSize(setPos(setAnchor(addSprite(self.bg, "gold.png"), {0, 1}), {439, fixY(sz[2], 28)}), {30, 30})
    temp = setSize(setPos(setAnchor(addSprite(self.bg, "crystal.png"), {0, 1}), {586, fixY(sz[2], 30)}), {30, 30})
    temp = setSize(setPos(setAnchor(addSprite(self.bg, "silver.png"), {0, 1}), {280, fixY(sz[2], 27)}), {30, 30})

    
    self.silverText = ui.newBMFontLabel({text="1", font="bound.fnt", size=23})
    setPos(setAnchor(self.silverText, {0, 0.5}), {318, fixY(sz[2], 43)})
    self.bg:addChild(self.silverText)
    
    self.goldText = ui.newBMFontLabel({text="1", font="bound.fnt", size=23})
    setPos(setAnchor(self.goldText, {0, 0.5}), {474, fixY(sz[2], 43)})
    self.bg:addChild(self.goldText)

    self.cryText = ui.newBMFontLabel({text="1", font="bound.fnt", size=23})
    setPos(setAnchor(self.cryText, {0, 0.5}), {621, fixY(sz[2], 43)})
    self.bg:addChild(self.cryText)
    

    temp = setPos(setAnchor(addSprite(self.bg, "titCamp.png"), {0, 1}), {71, fixY(sz[2], 10)})
    temp = setPos(addSprite(self.bg, "conTitSol.png"), {514, fixY(sz[2], 112)})

    self.goods = SoldierGoods.new(self)
    self.bg:addChild(self.goods.bg)

    --士兵商店第一个士兵
    self:setSoldier({self.goods.data[1], 1})
    --购买等级是否达标

end
function SoldierStore:setSoldier(idCan)
end

