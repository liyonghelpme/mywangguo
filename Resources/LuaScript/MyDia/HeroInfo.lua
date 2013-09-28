local simple = require "dkjson"
HeroInfo = class()

function HeroInfo:goBack()
    Event:sendMsg(EVENT_TYPE.UPDATE_HERO)
    global.director:popView()
    return true
end
function HeroInfo:levelSuc()
end
function HeroInfo:transferJob()
end
function HeroInfo:fastSuc()
end
function HeroInfo:levelup()
    self.hero['level'] = self.hero['level']+1
    self:initData()
    global.httpController:addRequest("levelup", dict({{"uid",1}, {"hid", self.hero["hid"]}}), self.levelSuc, nil, self)
    return false
end
function HeroInfo:transferJob()
    self.hero['job'] = self.hero['job']+1
    self:initData()
    global.httpController:addRequest("transferJob", dict({{"uid",1}, {"hid", self.hero["hid"]}}), self.transferSuc, nil, self)
    return false
end
function HeroInfo:fastJob()
    self.hero['job'] = self.hero['job']+1
    self:initData()
    global.httpController:addRequest("fastJob", dict({{"uid",1}, {"hid", self.hero["hid"]}}), self.fastSuc, nil, self)
    return false
end

function HeroInfo:ctor(hero)
    self.INIT_X = 0
    self.INIT_Y = 0
    self.WIDTH = 457
    self.HEIGHT = 70
    self.BACK_HEI = global.director.disSize[2]
    self.INITOFF = self.BACK_HEI-80
    self.content = {{'返回', self.goBack}, {"100金币升级", self.levelup},  {'100金币普通转职', self.transferJob}, {'100宝石快速转职', self.fastJob}}
    self.TabNum = #self.content
    self.data = {}
    self.hero = hero

    self.bg = CCLayer:create()
    self.flowTab = setPos(addNode(self.bg), {20, self.INITOFF})

    self:initTabs()
    
    self.touch = ui.newTouchLayer({size={self.WIDTH, self.BACK_HEI}, delegate=self, touchBegan=self.touchBegan, touchMoved=self.touchMoved, touchEnded=self.touchEnded})

    self.bg:addChild(self.touch.bg)
    self:initLeftTop()
    self:initData()
end
function HeroInfo:updateTab()
    removeSelf(self.flowTab)
    self.flowTab = setPos(addNode(self.bg), {20, self.INITOFF})
    self:initTabs()
end

function HeroInfo:initLeftTop()
    local vs = getVs()
    local lt = addNode(self.bg)
    setPos(lt, {vs.width-236, vs.height-33})
    
    local temp = setPos(setAnchor(addLabel(lt, getStr("name"), "", 18), {0, 0.5}), {0, 0})
    self.name = temp
    temp = setPos(setAnchor(addLabel(lt, getStr("level"), "", 18), {0, 0.5}), {0, -30})
    self.level = temp
    temp = setPos(setAnchor(addLabel(lt, getStr("job"), "", 18), {0, 0.5}), {0, -60})
    self.job = temp
    temp = setPos(setAnchor(addLabel(lt, getStr("attack"), "", 18), {0, 0.5}), {0, -90})
    self.attack = temp
    temp = setPos(setAnchor(addLabel(lt, getStr("health"), "", 18), {0, 0.5}), {0, -120})
    self.health = temp
    temp = setPos(setAnchor(addLabel(lt, getStr("magicDef"), "", 18), {0, 0.5}), {0, -150})
    self.magicDef = temp
    temp = setPos(setAnchor(addLabel(lt, getStr("physicDef"), "", 18), {0, 0.5}), {0, -180})
    self.physicDef = temp
    temp = setPos(setAnchor(addLabel(lt, getStr("attSpeed"), "", 18), {0, 0.5}), {0, -210})
    self.attSpeed = temp
    temp = setPos(setAnchor(addLabel(lt, getStr("move"), "", 18), {0, 0.5}), {0, -240})
    self.move = temp
    temp = setPos(setAnchor(addLabel(lt, getStr("skill"), "", 18), {0, 0.5}), {0, -270})
    self.skill = temp
    temp = setPos(setAnchor(addLabel(lt, getStr("equip"), "", 18), {0, 0.5}), {0, -300})
    self.equip = temp
end
function HeroInfo:initData()
    local name = Logic.allHeroData[self.hero['kind']]['name']
    self.name:setString("名称:"..name)
    self.level:setString("等级"..self.hero['level'])
    self.job:setString("职业"..self.hero["job"])
    self.attack:setString("攻击"..getAttack(self.hero['hid']))
    self.health:setString("生命值"..getHealth(self.hero['hid']))
    self.magicDef:setString("魔法防御"..getMagicDef(self.hero['hid']))
    self.physicDef:setString("物理防御"..getPhysicDef(self.hero['hid']))
    self.attSpeed:setString("攻击速度"..getAttSpeed(self.hero['hid']))
    self.move:setString("行动值"..getMove(self.hero['hid']))
    self.skill:setString("技能"..getSkill(self.hero['hid']))
    self.equip:setString("装备"..getEquip(self.hero['hid']))
end

function HeroInfo:touchBegan(x, y)
    self.accMove = 0
    self.lastPoints = {x, y}

    local child = checkInChild(self.flowTab, self.lastPoints)
    if child ~= nil then
        local sp = self.data[child:getTag()][1]
        print('touchBegan', sp, sp.setTexture)
        setTexture(sp, 'red.png')
        self.selected = sp
    end
end

function HeroInfo:moveBack(dify)
    local oldPos = getPos(self.flowTab)
    setPos(self.flowTab, {oldPos[1], oldPos[2]+dify})
    self.accMove = self.accMove+math.abs(dify)
end
function HeroInfo:touchMoved(x, y)
    local oldPos = self.lastPoints
    self.lastPoints = {x, y}
    local dify = self.lastPoints[2]-oldPos[2]
    self:moveBack(dify)
end

function HeroInfo:getOutSoldier()
    local temp = {}
    for k, v in ipairs(Logic.heroes) do
        if v['sell'] then
            table.insert(temp, v['hid'])
        end
    end
    return temp
end
function HeroInfo:touchEnded(x, y)
    local newPos = {x, y}
    if self.accMove < 10 then
        local child = checkInChild(self.flowTab, newPos)
        if child ~= nil then
            local i = child:getTag()
            print(i)
            --if i == 0 then
            local ret = self.content[i][2](self, self.content[i][3], self.content[i][4])
            if ret then
                return
            end
        end
    end

    local curPos = getPos(self.flowTab)
    local k = round((curPos[2]-self.INITOFF)/self.HEIGHT)
    local maxK = math.max(0, math.ceil((self.TabNum*self.HEIGHT-self.BACK_HEI)/self.HEIGHT))
    k = math.min(math.max(0, k), maxK)
    setPos(self.flowTab, {curPos[1], self.INITOFF+self.HEIGHT*k})

    if self.selected ~= nil then
        setTexture(self.selected, 'green.png')
        self.selected = nil
    end
end

function HeroInfo:initTabs()
    self.tabArray = {}
    for i=1, self.TabNum, 1 do 
        local t = setContentSize(setAnchor(setPos(addNode(self.flowTab), {0, -(i-1)*self.HEIGHT}), {0, 0}), {400, 60})
        local sp = setAnchor(addSprite(t, "green.png"), {0, 0})
        --table.insert(self.tabArray, {sp, i-1})
        t:setTag(i)
        local sz = sp:getContentSize()
        local w = setColor(setPos(addLabel(sp, self.content[i][1], "", 33), {sz.width/2, sz.height/2}), {0, 0, 0})
        self.data[i] = {sp, w}
    end
end
