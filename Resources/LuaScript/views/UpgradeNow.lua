UpgradeNow = class()
--可以上下拖动的新手对话框 
--在手机上面测试哪些图片没有
function UpgradeNow:ctor(build)
    self.build = build
    self.bg = CCNode:create()
    local vs = getVS()
    local temp = setPos(addSprite(self.bg, "parchment.png"), {vs.width/2, vs.height/2})
    self.pic = temp
    print("temp pos")

    local sz = self.pic:getContentSize()
    setPos(addSprite(self.pic, "girl.png"), {11, fixY(sz.height, 51)})

    local but = ui.newButton({image="roleNameBut0.png", callback=self.onOk, delegate=self, conSize={100, 40}, text=getStr("ok"), size=30})
    setPos(but.bg, {sz.width/2-70, fixY(sz.height, 259)})
    self.pic:addChild(but.bg)
    but:setAnchor(0.5, 0.5)

    local but = ui.newButton({image="roleNameBut0.png", callback=self.onCancel, delegate=self, conSize={100, 40}, text=getStr("cancel"), size=30})
    setColor(but.sp, {128, 128, 128})
    setPos(but.bg, {sz.width/2+70, fixY(sz.height, 259)})
    self.pic:addChild(but.bg)
    but:setAnchor(0.5, 0.5)
    
    local cost = getCost(GOODS_KIND.BUILD, build.kind)
    local ck, cv
    for k, v in pairs(cost) do
        ck = k
        cv = v
        break
    end
    self.content = ui.newTTFLabel({text=getStr("upgradeBuild", {"[NUM]", str(cv), "[KIND]", getStr(ck), "[NAME]", self.build:getName(), "[LEVEL]", str(self.build.level+2)}), font="", size=20, color={48, 52, 109}, dimensions={278, 0}})
    setAnchor(setPos(self.content, {122, fixY(sz.height, 142)}), {0, 0.5})
    self.pic:addChild(self.content)
end
function UpgradeNow:onCancel()
    global.director:popView()
end
--每次点击一下 进入下一个步骤
function UpgradeNow:onOk()
    global.director:popView()
    local cost = getCost(GOODS_KIND.BUILD, self.build.kind)
    local buyable = global.user:checkCost(cost)
    if buyable.ok == 0 then
        addBanner(getStr("resNot"))
    else
        global.user:doCost(cost)
        self.build:doUpgrade()
        sendReq("upgradeBuild", dict({{"uid", global.user.uid}, {"bid", self.build.bid}, {"cost", simple.encode(cost)}}))
    end
end
