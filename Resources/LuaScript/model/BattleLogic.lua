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
BattleLogic.paused = false

function BattleLogic.prepareState()
    BattleLogic.quitBattle = false
    BattleLogic.gameOver = false
    BattleLogic.inBattle = false
    BattleLogic.paused = false
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
end
function BattleLogic.clearBattle()
    BattleLogic.inBattle = false
    --BattleLogic.gameOver = true
    --BattleLogic.killedSoldier = {}
end
function BattleLogic.updateKill(kind)
    local n = getDefault(BattleLogic.killedSoldier, kind, 0)
    n = n+1
    BattleLogic.killedSoldier[kind] = n
    global.user:killSoldier(kind)
end

