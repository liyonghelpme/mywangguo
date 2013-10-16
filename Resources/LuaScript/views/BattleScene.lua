--战斗士兵选择 菜单 
--敌对势力
require "model.BattleLogic"
require "views.BattleMenu"
BattleScene = class()
function BattleScene:ctor()
    --退出战斗时候 inBattle = false
    BattleLogic.inBattle = true
    self.bg = CCScene:create()
    self.ml = BattleMenu.new(self)
    self.mc = CastlePage.new(self)
    self.bg:addChild(self.ml.bg)
    self.bg:addChild(self.mc.bg)
    self.dialogController = DialogController.new(self)
    self.bg:addChild(self.dialogController.bg)
    --CastlePage 需要新的结构中初始化数据
    sendReq("getRandomOther", dict({{"uid", global.user.uid}}), self.initData, nil, self)
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
