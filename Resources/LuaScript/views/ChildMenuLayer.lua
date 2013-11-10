require "views.Cloud"
require "views.FriendDialog"
require "views.BigMap"
require "views.Rank"
ChildMenuLayer = class()
function ChildMenuLayer:ctor(index, funcs, s, otherFunc, menu)
    self.buts = dict({
    {"photo", {"menu_button_photo.png", self.onPhoto}},
    {"drug", {"menu_button_drug.png", self.onDrug}},


    {"map", {"menu_button_map.png", self.onMap}},
    {"friend", {"menu_button_friend.png", self.onFriend}},
    {"mail", {"menu_button_mail.png", self.onMail}},
    {"plan", {"menu_button_plan.png", self.onPlan}},
    {"planMine", {"menu_button_plan.png", self.onPlanMine}},
    {"rank", {"menu_button_rank.png", self.onRank}},
    {"setting", {"menu_button_setting.png", self.onSetting}},
    {"store", {"menu_button_store.png", self.onStore}},
    {"attack", {"menu_button_attack.png", self.onAttack}},


    {"acc", {"menu_button_acc.png", self.onAcc}},
    {"sell", {"menu_button_sell.png", self.onSell}},

    {"story", {"menu_button_story.png", self.onStory}},
    {"soldier", {"menu_button_soldier.png", self.onSoldier}},
    {"collection", {"menu_button_collection.png", self.onCollection}},
    {"tip", {"menu_button_tip.png", self.onTip}},

    {"relive", {"menu_button_relive.png", self.onRelive}},
    {"transfer", {"menu_button_transfer.png", self.onTransfer}},

    {"forge", {"menu_button_forge.png", self.onForge}},
    {"makeDrug", {"menu_button_makeDrug.png", self.onMakeDrug}},

    {"equip", {"menu_button_equip.png", self.onEquip}},
    {"gather", {"menu_button_gather.png", self.onGather}},
    {"upgrade", {"menu_button_upgrade.png", self.onUpgrade}},

    {"allDrug", {"menu_button_allDrug.png", self.onAllDrug}},
    {"allEquip", {"menu_button_allEquip.png", self.onAllEquip}},

    {"menu1", {"menu1.png", self.onHeart}},
    {"menu2", {"menu2.png", self.onTranStatus}},

    {"menu10", {"menu_button_game0.png", self.onInspire}},
    {"menu11", {"menu_button_game1.png", self.onMoney}},

    {"invite", {"menu_button_invite.png", self.onInvite}},

    {"upgradeBuild", {"menu_button_upgrade_build.png", self.onUpgrade}},

    {"call", {"menu_button_call.png", self.onCall}},
    })
    
    self.position = index
    self.scene = s
    self.functions = funcs
    self.menu = menu
    
    self.OFFY = 100
    self.MIDY = 200
    --需要根据屏幕尺寸调整高度比例 占当前屏幕高度的%
    self.DARK_WIDTH = 128 
    
    local height = #self.functions*self.OFFY
    local h2 = #otherFunc*self.OFFY
    local mH = math.max(height, h2)

    local offset = self.MIDY-mH/2
    self.offset = offset
    
    self.bg = CCNode:create()
    self.sp = setSize(addSprite(self.bg, "dark0.png"), {self.DARK_WIDTH, height})
    if index == 0 then
        setPos(setAnchor(self.sp, {0, 1}), {-self.DARK_WIDTH, fixY(nil, offset, nil, 1)})
    else
        setPos(setAnchor(self.sp, {1, 1}), {global.director.disSize[1]+self.DARK_WIDTH, fixY(nil, offset, nil, 1)})
    end

    if self.position == 0 then
        addAction(self.sp, expout(moveto(0.3, 0, fixY(nil, offset, nil, 1))))
    else
        addAction(self.sp, expout(moveto(0.3, global.director.disSize[1], fixY(nil, offset, nil, 1))))
    end
    
    self.allButtons = {}
    for i=1, #self.functions, 1 do
        local model = self.buts[self.functions[i]]
        local button = ui.newButton({image=model[1], delegate=self, callback=model[2]}):setAnchor(0.5, 0.5)
        setPos(button.bg, {self.DARK_WIDTH/2, self.OFFY/2+self.OFFY*(i-1)})
        self.sp:addChild(button.bg)
        self.allButtons[self.functions[i]] = button
    end

    registerEnterOrExit(self)
end
function ChildMenuLayer:enterScene()
    --生成时就开始接受消息
    Event:registerEvent(EVENT_TYPE.TAP_STORE, self)
    Event:registerEvent(EVENT_TYPE.BATTLE, self)
end
function ChildMenuLayer:receiveMsg(name, msg)
    if name == EVENT_TYPE.TAP_STORE then
        local b = self.allButtons['store']
        print("tap store", b)
        if b ~= nil then
            local h = Hint.new()
            b.bg:addChild(h.bg)
            --setPos(h, {50, 50})
            NewLogic.setHint(h)
        end
    elseif name == EVENT_TYPE.BATTLE then
        local b = self.allButtons['attack']
        if b ~= nil then
            local h = Hint.new()
            b.bg:addChild(h.bg)
            --setPos(h, {50, 50})
            NewLogic.setHint(h)
        end
    end
end
function ChildMenuLayer:exitScene()
    Event:unregisterEvent(EVENT_TYPE.BATTLE, self)
    Event:unregisterEvent(EVENT_TYPE.TAP_STORE, self)
end
function ChildMenuLayer:removeSelf()
    if self.position == 0 then
        addAction(self.sp, sequence({expin(moveto(0.3, -self.DARK_WIDTH-5, fixY(nil, self.offset, nil, 1))), itintto(0, 0, 0, 0)}))
    else
        addAction(self.sp, sequence({expin(moveto(0.3, global.director.disSize[1]+self.DARK_WIDTH+5, fixY(nil, self.offset, nil, 1))), itintto(0, 0, 0, 0)}))
    end
end


function ChildMenuLayer:onStore()
    self.menu:cancelAllMenu()
    MyPlugins:getInstance():sendCmd("hideAds", "");
    global.director:pushView(Store.new(self.scene), 1, 0)
    --NewLogic.nextStep()
    NewLogic.triggerEvent(NEW_STEP.STORE)
end
function ChildMenuLayer:onPlan()
    global.director.curScene:closeGlobalMenu(self)
    global.director.curScene:doPlan()
end
function ChildMenuLayer:onSell()
    global.director.curScene:closeGlobalMenu(self)
    global.director.curScene:doSell()
end

function ChildMenuLayer:onFriend()
    global.director.curScene:closeGlobalMenu(self)
    MyPlugins:getInstance():sendCmd("share", "")

    local r = math.random(2)
    local reward = {}
    if r == 1 then
        reward.silver = 10
        addBanner(getStr("shareReward", {"[NUM]", str(10), "[KIND]", getStr("silver")}))
    else 
        reward.crystal = 10
        addBanner(getStr("shareReward", {"[NUM]", str(10), "[KIND]", getStr("crystal")}))
    end
    sendReq("killMonster", dict({{"uid", global.user.uid}, {"gain", reward}}))
    global.user:doAdd(reward)
end
function ChildMenuLayer:onSetting()
    global.director.curScene:closeGlobalMenu(self)
    addBanner(getStr("noFunc"))
end
function ChildMenuLayer:onMap()
    global.director.curScene:closeGlobalMenu(self)
    global.director:pushView(BigMap.new(), 1, 0)
end
function ChildMenuLayer:onRank()
    global.director.curScene:closeGlobalMenu(self)
    global.director:pushView(Rank.new(), 1, 0)
end

function ChildMenuLayer:onMail()
    global.director.curScene:closeGlobalMenu(self)
    MyPlugins:getInstance():sendCmd("feedback", "")
end


--切换场景之前保证当前场景的 所有dialog都关闭了
function ChildMenuLayer:onAttack()
    global.director.curScene:closeGlobalMenu(self)
    BattleLogic.prepareState()
    global.director:pushView(Cloud.new(), 1, 0)
end
