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
BattleLogic.gameOver = false

function BattleLogic.startBattle()
    BattleLogic.gameOver = false
    BattleLogic.inBattle = true
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

