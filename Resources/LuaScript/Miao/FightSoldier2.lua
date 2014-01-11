FIGHT_SOL_STATE = {
    FREE=0,
    START_ATTACK=1,
    IN_ATTACK=2,
}

FightSoldier2 = class()
function FightSoldier2:ctor(m, id, col, row, data)
    self.id = id
    self.map = m
    --所在列
    self.col = col
    self.row = row
    --相当于几个士兵的能力
    self.data = data
    --地图记录每个网格状态 
     
    self.bg = CCNode:create()
    self.changeDirNode = CCSprite:createWithSpriteFrameName("cat_foot_idle_0.png")
    self.bg:addChild(self.changeDirNode)
    setAnchor(self.changeDirNode, {0.5, 0})
end

