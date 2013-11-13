--战斗士兵选择 菜单 
--敌对势力
require "model.BattleLogic"
require "views.BattleMenu"
require "views.ChallengeOver"
BattleScene = class()
BATTLE_STATE = {
    PREPARE = 0,
    IN_BATTLE = 1,
}
function BattleScene:ctor()
    --退出战斗时候 inBattle = false
    --BattleLogic.startBattle()
    self.bg = CCScene:create()
    self.ml = BattleMenu.new(self)
    self.mc = CastlePage.new(self)
    self.bg:addChild(self.mc.bg)
    self.bg:addChild(self.ml.bg)
    self.dialogController = DialogController.new(self)
    self.bg:addChild(self.dialogController.bg)
    --CastlePage 需要新的结构中初始化数据
    self:initFx()
    registerUpdate(self)
    registerEnterOrExit(self)
    self.passTime = 0
    self.state = BATTLE_STATE.PREPARE
    self.show = false
end
function BattleScene:enterScene()
    --设置inBattle状态之后 再 获取游戏数据
    BattleLogic.startBattle()
    sendReq("getRandomOther", dict({{"uid", global.user.uid}}), self.initData, nil, self)
end
function BattleScene:exitScene()
end
function BattleScene:initFx()
    createAnimation("tx2", "tx2_%d.png", 0, 9, 1, 1, false)
end
function BattleScene:checkGameOver()
    if BattleLogic.gameOver  and BattleLogic.endDialog == nil then
        self.show = true
        local co = ChallengeOver.new(self, {suc=true})
        global.director:pushView(co, 1, 0)
    end
end
function BattleScene:update(diff)
    if self.state == BATTLE_STATE.IN_BATTLE then
        self.passTime = self.passTime+diff
        if self.passTime > 2 then
            self.passTime = 0
            local ab = self.mc.buildLayer.mapGridController.allBuildings 
            local count = 0
            for k, v in pairs(ab) do
                if k.broken == false then
                    count = 1
                    break
                end
            end
            if count == 0 then
                BattleLogic.gameOver = true
            end
        end
        self:checkGameOver()
    end
end

function BattleScene:initData(data, param)
    if data ~= nil then
        if data.code == 1 then
            BattleLogic.uid = data.uid 
            BattleLogic.buildings = {}
            for k, v in ipairs(data.builds) do
                BattleLogic.buildings[v['bid']] = v
                v.objectList = simple.decode(v.objectList)
            end

            BattleLogic.serverTime = data.serverTime
            BattleLogic.resource = data.resource
            BattleLogic.soldiers = {} 
            for k, v in ipairs(data.soldiers) do
                BattleLogic.soldiers[v.kind] = v.num
            end
            --Event:sendMsg(EVENT_TYPE.INIT_BATTLE)
            self.ml:initDataOver()
            self.mc:initDataOver() 
        else
        --搜索失败
        end
    else
    end
end
function BattleScene:finishInit()
end
function BattleScene:closeGlobalMenu()
end
