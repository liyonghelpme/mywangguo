--控制战斗逻辑的全局对象
BattleLogic = {}
BattleLogic.inBattle = false
BattleLogic.curUser = nil
--所有服务器返回的 可以攻击的用户列表
BattleLogic.allUsers = {}
BattleLogic.uid = nil
BattleLogic.buildings = {}
BattleLogic.soldiers = {}
BattleLogic.cloud = nil
BattleLogic.finishInitBuild = false
BattleLogic.killedSoldier = {}
--所有建筑物被摧毁 的时候 true
BattleLogic.gameOver = false
BattleLogic.resource = {}
--用户要退出 战斗场景 cancel 或者 战斗胜利点击ok
BattleLogic.quitBattle = false
BattleLogic.endDialog = nil
--出现游戏结束对话框的时候 paused = true 关闭之后 pause = false
BattleLogic.paused = false

--用户当前掠夺到的资源
BattleLogic.silver = 0
BattleLogic.crystal = 0
BattleLogic.exp = 0
BattleLogic.farmNum = 0
BattleLogic.mineNum = 0

BattleLogic.challengeWho = nil
BattleLogic.challengeLevel = nil
BattleLogic.levels = nil

function BattleLogic.prepareState()
    BattleLogic.quitBattle = false
    BattleLogic.gameOver = false
    BattleLogic.inBattle = false
    BattleLogic.paused = false
    BattleLogic.challengeWho = nil
    BattleLogic.challengeLevel = nil
end
function BattleLogic.addSilver(v)
    BattleLogic.silver = BattleLogic.silver+v
    BattleLogic.exp = BattleLogic.exp+v
    Event:sendMsg(EVENT_TYPE.ROB_RESOURCE)
end
function BattleLogic.addCrystal(v)
    BattleLogic.crystal = BattleLogic.crystal+v
    BattleLogic.exp = BattleLogic.exp+v
    Event:sendMsg(EVENT_TYPE.ROB_RESOURCE)
end

function BattleLogic.killKind(kind)
    local v = getDefault(BattleLogic.killedSoldier, kind, 0)
    v = v+1
    BattleLogic.killedSoldier[kind] = v
end
function BattleLogic.getKilled()
    local temp = {}
    for k, v in pairs(BattleLogic.killedSoldier) do
        table.insert(temp, {k, v})
    end
    return temp
end
function BattleLogic.startBattle()
    print("startBattle", BattleLogic.inBattle)
    BattleLogic.gameOver = false
    BattleLogic.quitBattle = false
    BattleLogic.inBattle = true
    BattleLogic.endDialog = nil
    BattleLogic.killedSoldier = {}
    BattleLogic.silver = 0
    BattleLogic.crystal = 0
    BattleLogic.exp = 0
    BattleLogic.finishInitBuild = false
end
function BattleLogic.clearBattle()
    BattleLogic.inBattle = false
    --BattleLogic.gameOver = true
    --BattleLogic.killedSoldier = {}
end
--只有士兵死亡了才算挂掉
function BattleLogic.updateKill(kind)
    local n = getDefault(BattleLogic.killedSoldier, kind, 0)
    n = n+1
    BattleLogic.killedSoldier[kind] = n
    global.user:killSoldier(kind)
end

--高级防御塔 
BattleLogic.levelData = {
    {name="初试牛刀", crystal=1000, silver=1000},
    {name="密不透风", crystal=2000, silver=2000},
    {name="水晶之塔", crystal=3000, silver=3000},
    {name="圈地运动", crystal=4000, silver=4000},
    {name="魔鬼风车", crystal=5000, silver=5000},
    {name="宝贝矿藏", crystal=10000, silver=5000},
    {name="高级防御", cyrstal=20000, silver=10000},
}
