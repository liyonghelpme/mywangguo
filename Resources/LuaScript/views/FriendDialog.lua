FriendDialog = class()
function FriendDialog:ctor()
    self.bg = CCNode:create()
    setPos(setAnchor(addSprite(self.bg, "back.png"), {0, 0}), {0, 0})
    setPos(setAnchor(addSprite(self.bg, "diaBack.png"), {0, 1}), {38, fixY(nil, 10)})
    setPos(setAnchor(addSprite(self.bg, "loginBack.png"), {0, 1}), {30, fixY(nil, 79)})
    local but0 = ui.newButton({image="closeBut.png", callback=self.closeDialog, delegate=self})
    setPos(but0.bg, {752, fixY(nil, 47)})
    self.bg:addChild(but0.bg)

    but0 = ui.newButton({image="roleNameBut0.png", callback=self.refresh, delegate=self, conSize={87, 42}, text=getStr("refresh"), size=18})
    setPos(but0.bg, {570, fixY(nil, 42)})
    but0:setAnchor(0.5, 0.5)
    self.bg:addChild(but0.bg)
    --开始的时候 refresh 或者load一下friendList
    --随机加载几十个
    --
    setPos(setAnchor(addSprite(self.bg, "dialogFriendTitle.png"), {0, 1}), {65, fixY(nil, 10)})
    setPos(setAnchor(addSprite(self.bg, "dialogNeibor.png"), {0.5, 0.5}), {398, fixY(nil, 108)})

end
function FriendDialog:closeDialog()
    global.director:popView()
end
function FriendDialog:refresh()
end


