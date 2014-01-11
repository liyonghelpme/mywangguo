require "Miao.FightSoldier2"

FIGHT_STATE = {
    FREE=0,
    MOVE=1,
    FINISH_MOVE=2,
    GUN = 3,
    ARROW = 4,
    INFANTRY = 5,
    CAVALRY = 6,

    WAIT = 7,
    FIGHT_OVER = 8,
    FIGHT_OVER2 = 9,

    FIGHT_OVER3 = 10,
}
FightLayer2 = class()

--Invisible 背后的场景 battleScene 上所有的东西 
--但是update 还是会调用的 
--3:7 战斗场景高度位置
--菜单的位置
--我方士兵数量 和 敌方士兵状态
--[num, num, num, num]
--将士兵数量转化成 5 列 5 行的士兵
--单个士兵的战斗力等级[0, 1, 2, 3] 或者战斗力数量
--阶梯 方式 来表现士兵数量
--超过2000个最多25个 每个能力平均 
function FightLayer2:convertNumToSoldier(n)
    local temp = {}
    local num
    local pow
    if n < 100 then
        num = math.max(math.floor(n/5), 1)
        pow = 5
    --5 * 5 = 25 最多士兵数量
    elseif n < 250 then
        num = math.floor(n/10)
        pow = 10 
    elseif n < 500 then
        num = math.floor(n/20)
        pow = 20
    elseif n < 1000 then
        num = math.floor(n/40)
        pow = 40
    elseif n < 2000 then
        num = math.floor(n/80)
        pow = 80
    else
        pow = math.floor(n/25)
        num = 25
    end

    local curCol
    for i =0, num-1, 1 do
        local col = math.floor(i/5)
        local row = math.floor(i%5)
        if row == 0 then
            curCol = {}
            table.insert(temp, curCol)
        end
        --每个士兵实力5
        table.insert(curCol, pow)
    end
    return temp
end

function FightLayer2:ctor(s, my, ene)
    self.scene = s 
    local vs = getVS()
    print("FightLayer2")

    self.myFootNum = self:convertNumToSoldier(my[1])
    self.eneFootNum = self:convertNumToSoldier(ene[1])
    local leftWidth = #self.myFootNum*FIGHT_OFFX
    self.leftWidth = leftWidth
    local rightWidth = #self.eneFootNum*FIGHT_OFFX
    self.rightWidth = rightWidth
    --单张战斗图调整为 self.HEIGHT
    --战斗场景高度不变 483 高度
    self.HEIGHT = FIGHT_HEIGHT
    self.bg = setPos(CCLayer:create(), {0, vs.height-self.HEIGHT})
    self.battleScene = CCNode:create()
    self.bg:addChild(self.battleScene)

    --场景宽度受士兵的数量决定 1:1的士兵
    --刚开始 1: 0.618 
    --战斗高度不变 但是宽度可以自由增加
    --比屏幕宽一点这样就不能同时看到 左右两边的士兵了
    self.WIDTH = vs.width+leftWidth+rightWidth

    setContentSize(self.bg, {self.WIDTH, self.HEIGHT})
    local tex = CCTextureCache:sharedTextureCache():addImage("battle_bg5.jpg")
    local tsz = tex:getContentSize()
    local tsca = self.HEIGHT/tsz.height
    self.oneWidth = tsca*tsz.width

    local n = math.ceil(self.WIDTH/self.oneWidth)
    for i=1, n, 1 do
        local sp = setAnchor(setPos(setSize(CCSprite:create("battle_bg5.jpg"), {self.oneWidth, self.HEIGHT}), {(i-1)*self.oneWidth, 0}), {0, 0})
        self.battleScene:addChild(sp)
        if (i-1)%2 == 1 then
            local scax = sp:getScaleX()
            setAnchor(setScaleX(sp, -scax), {1, 0})
        end
    end
    self:initPic()
    self:initSoldier()
end
function FightLayer2:initPic()
    local sf = CCSpriteFrameCache:sharedSpriteFrameCache()
    sf:addSpriteFramesWithFile("cat_foot.plist")
end
--输入参数 各种士兵
function FightLayer2:initSoldier()
    print("left Num")
    print(simple.encode(self.myFootNum))
    print(simple.encode(self.eneFootNum))
    --每一列 每一行
    for k, v in ipairs(self.myFootNum) do
        for ck, cv in ipairs(v) do
            local sp = FightSoldier2.new(self, 0, k-1, ck-1, cv) 
            self.battleScene:addChild(sp.bg)
            --setPos(sp, {self.leftWidth-(k-1)*FIGHT_COL_OFFX, 40+(ck-1)*FIGHT_ROW_OFFY})
            setPos(ps, {0, 0})
        end
    end
end

