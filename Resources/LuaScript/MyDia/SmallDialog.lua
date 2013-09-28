SmallDialog = class()
function SmallDialog:ctor()
    self.bg = CCLayer:create()
    self:initCenter()
end
function SmallDialog:onOK()
end
function SmallDialog:onCancel()
end
function SmallDialog:close()
    global.director:popView()
end
function SmallDialog:initCenter()
    local vs = getVs()
    local temp = setPos(addSprite(self.bg, "smallDiaBack.png"), {vs.width/2, vs.height/2})
    local but = ui.newButton({image="blueBut.png", delegate=self, callback=self.onOK})
    temp:addChild(but.bg)
    setPos(but.bg, {117, 48})

    but = ui.newButton({image="blueBut.png", delegate=self, callback=self.onCancel})
    temp:addChild(but.bg)
    setPos(but.bg, {297, 48})

    but = ui.newButton({image="closeBut.png", delegate=self, callback=self.close})
    temp:addChild(but.bg)
    setPos(but.bg, {354, 226})


end
