SellMenu = class()
function SellMenu:ctor(s)
    self.scene = s
    self.bg = CCNode:create()
    local scaX = global.director.disSize[1]/global.director.designSize[1]
    setScale(self.bg, scaX)
    self.sp = setAnchor(setPos(addSprite(self.bg, "buildMenuBack.png"), {0, 0}), {0, 0})
    self.buttonNode = addNode(self.bg)

    local label = ui.newTTFLabel({text=getStr("toSell"), font="", size=22})
    setPos(setAnchor(label, {0, 0.5}), {24, 32})
    self.buttonNode:addChild(label)

    local but0 = ui.newButton({image="buildOk0.png", delegate=self, callback=self.onOk})
    self.buttonNode:addChild(but0.bg)
    but0:setContentSize(60, 68)
    setPos(but0.bg, {669, 15})
end

function SellMenu:onOk()
    self.scene:finishSell()
end

