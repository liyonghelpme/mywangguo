RoleName = class()
function RoleName:ctor()
    self.bg = CCNode:create()
    local vs = getVS()
    local temp = setPos(addSprite(self.bg, "parchment.png"), {vs.width/2, vs.height/2})
    
    local sz = temp:getContentSize()
    local lab = ui.newTTFLabel({text=getStr("newName", nil), color={109,170,44}, size=20})
    setAnchor(setPos(lab, {137, fixY(sz.height, 74)}), {0, 0.5})
    temp:addChild(lab)

    --setPos(addSprite(temp, "roleNameDia.png"), {sz.width/2, fixY(sz.height, 131)})
    local eb = ui.newEditBox({image="roleNameDia.png", imagePressed="roleNameDia.png", imageDiabled="roleNameDia.png", listener=self, size={245, 42}})
    setPos(eb, {sz.width/2, fixY(sz.height, 131)})
    temp:addChild(eb)
    self.editBox = eb

    local but = ui.newButton({image="roleNameBut0.png", text=getStr("ok", nil), size=30, conSize={200, 50}, callback=self.onName, delegate=self})
    setPos(but.bg, {sz.width/2, fixY(sz.height, 260)})
    but:setAnchor(0.5, 0.5)
    temp:addChild(but.bg)

end
function RoleName:onName()
    local name = self.editBox:getText()
    print("name", name)
    if name ~= "" then
        global.director:popView()
        sendReq("rename", dict({{"uid", global.user.uid}, {"name", name}}))
        global.user:setValue("name", name)
        Event:sendMsg(EVENT_TYPE.CHANGE_NAME)
    end
end
function RoleName:onEditBoxBegan()
end
function RoleName:onEditBoxEnded()
end
function RoleName:onEditBoxReturn()
end
function RoleName:onEditBoxChanged()
end
