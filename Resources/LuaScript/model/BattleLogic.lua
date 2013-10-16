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
