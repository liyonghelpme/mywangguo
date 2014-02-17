require "Miao.FightLayer2"
require "Miao.FightMenu2"
FightScene = class()
function FightScene:ctor()
    initCityData()
    --local testData = CityData[17]
    local ms = Logic.soldiers 
    --self.soldiers = {{ms[1][2], ms[2][2], ms[3][2], ms[4][2]}, copyTable(Logic.challengeNum)}
    --self.soldiers = {{testData[1], testData[2]-5, testData[3], testData[4]}, testData}
    --self.soldiers = {{10, 0, 0, 0}, {10, 0, 0, 0}}
    --找到一排的感觉
    --self.soldiers = {{25, 0, 0, 0}, {25, 0, 0, 0}}
    --self.soldiers = {{0, 5, 0, 0}, {0, 5, 0, 0}}
    --self.soldiers = {testData, testData}
    --self.soldiers = {{10, 40, 0, 0}, {15, 5, 0, 0}}
    --self.soldiers = {{50, 40, 0, 0}, {40, 50, 0, 0}}
    --self.soldiers = {{50, 40, 0, 0}, {40, 50, 0, 0}}
    --是因为左右使用了相同的数据修改的数组导致的问题
    --self.soldiers = {copyTable(testData), copyTable(testData)}
    
    --[[
    self.soldiers = {{5, 0, 0, 0}, {5, 0, 0, 0}}
    self.soldiers = {{25, 0, 0, 0}, {25, 0, 0, 0}}
    --self.soldiers = {{50, 0, 0, 0}, {50, 0, 0, 0}}
    self.soldiers = {{50, 0, 0, 0}, {25, 20, 0, 0}}
    self.soldiers = {{140, 0, 0, 0}, {50, 50, 0, 0}}
    self.soldiers = {copyTable(testData), copyTable(testData)}
    self.soldiers = {{15, 10, 0, 0}, {10, 18, 0, 0}}
    --]]

    --挑战竞技场 
    --挑战竞技场胜利 kind == 0 奖励物品 提升竞技场 
    --[[
    --]]
    --挑战新手村 只有 英雄
    if Logic.newVillage then
        self.soldiers = {{0, 0, 0, 0}, copyTable(Logic.villagePower[Logic.curVillage])}
    elseif type(Logic.challengeCity) == 'table' and Logic.challengeCity.kind == 0 then
        local cityData = Logic.arena[math.min(#Logic.arena, Logic.arenaLevel)]
        self.soldiers = {{ms[1][2], ms[2][2], ms[3][2], ms[4][2]}, copyTable(cityData)}
    else
        self.soldiers = {{ms[1][2], ms[2][2], ms[3][2], ms[4][2]}, copyTable(Logic.challengeNum)}
    end
    
    --self.soldiers = {{0, 0, 5, 0}, {0, 10, 0, 0}}
    --self.soldiers = {{0, 0, 0, 5}, {0, 0, 0, 5}}
    --self.soldiers = {{35, 0, 0, 5}, {0, 0, 0, 40}}
    --self.soldiers = {{25, 10, 0, 0}, {5, 40, 0, 0}}
    --self.soldiers = {{0, 0, 0, 30}, {0, 0, 0, 30}}

    --self.soldiers = {{70, 0, 0, 50}, {70, 0, 0, 50}}
    --self.soldiers = {{70, 0, 0, 50}, {70, 0, 0, 50}}
    --self.soldiers = {{0, 5, 0, 0}, {0, 0, 0, 5}}
    --self.soldiers = {{0, 0, 30, 0}, {0, 0, 0, 30}}
    --self.soldiers = {{0, 0, 33, 0}, {80, 0, 0, 0}}
    --self.soldiers = {{10, 5, 5, 5}, {10, 5, 5, 5}}
    --self.soldiers = {{10, 10, 10, 10}, {10, 10, 10, 10}}
    --self.soldiers = {{10, 20, 10, 10}, {15, 10, 10, 10}}
    --self.soldiers = {{20, 20, 20, 20}, {20, 20, 20, 20}}
    
    --attack defense health 前 中 后 默认都在前方布局  技能属性
    --一个 装备上 铜甲 头巾 防御力 22 远高于一些攻击力 
    --self.heros = {{{attack=6*5, defense=0, health=66*5, skill=2} }, {{attack=6*5, defense=0, health=66*5} }, {{attack=6*5, defense=0, health=66*5}}, {{attack=6*5, defense=0, health=66*5}}}
    
    --self.heros = {{{attack=6*5, defense=0, health=66*5, skill=6} }, {{attack=6*5, defense=0, health=66*5} }, {{attack=6*5, defense=0, health=66*5}}, {{attack=6*5, defense=0, health=66*5}}}
    --self.heros = {{{attack=6*5, defense=0, health=66*5, skill=41} }, {{attack=6*5, defense=0, health=66*5, skill=38} }, {{attack=6*5, defense=0, health=66*5}}, {{attack=6*5, defense=0, health=66*5}}}
    --self.heros = {{{attack=6*5, defense=0, health=66*5, skill=45} }, {{attack=6*5, defense=0, health=66*5, skill=38} }, {{attack=6*5, defense=0, health=66*5}}, {{attack=6*5, defense=0, health=66*5}}}
    self.heros = {{}, {}, {}, {}}
    for k, v in ipairs(Logic.attendHero) do
        local pdata = Logic.farmPeople[v.id]
        local equip = pdata
        local weapKind = 0 
        local ride = false
        if equip.weapon ~= nil then
            local edata = Logic.equip[equip.weapon]
            --兵器
            if edata.kind == 0 then
                --近战 远战
                if edata.subKind == 0 or edata.subKind == 1 or edata.subKind == 4 then
                    weapKind = 0
                elseif edata.subKind == 2 then
                    weapKind = 1
                elseif edata.subKind == 3 then
                    weapKind = 2
                end
            end
        end
        local equipSkill
        if equip.spe ~= nil then
            local edata = Logic.equip[equip.weapon]
            ride = edata.ride == 1
            if edata.skillId ~= 0 then
                equipSkill = edata.skillId
            end
        end
        
        local attr = calAttr(pdata.id, pdata.level, pdata) 
        local sid = getPeopleSkill(pdata.id, pdata.level)
        local skllId
        if equipSkill ~= nil then
            skillId = equipSkill
        else
            skillId = sid
        end
        if skillId == 0 then
            skillId = nil
        end
        if ride then
            table.insert(self.heros[4], {attack=attr.attack, defense=attr.defense, health=attr.health, skill=skillId, pos=v.pos})
        elseif weapKind == 0 then
            table.insert(self.heros[1], {attack=attr.attack, defense=attr.defense, health=attr.health, skill=skillId, pos=v.pos})
        elseif weapKind == 1 then
            table.insert(self.heros[2], {attack=attr.attack, defense=attr.defense, health=attr.health, skill=skillId, pos=v.pos})
        elseif weapKind == 2 then
            table.insert(self.heros[3], {attack=attr.attack, defense=attr.defense, health=attr.health, skill=skillId, pos=v.pos})
        end
    end
    print("attendSoldier", simple.encode(self.soldiers))
    print("attendHero", simple.encode(Logic.attendHero))
    print(simple.encode(self.heros))

    --将英雄也算入到 maxSoldier中去 
    self.maxSoldier = simple.decode(simple.encode(self.soldiers))
    self.mySoldier = self.maxSoldier[1]
    self.mySoldier[1] = self.mySoldier[1]+#self.heros[1]
    self.mySoldier[2] = self.mySoldier[2]+#self.heros[2]
    self.mySoldier[3] = self.mySoldier[3]+#self.heros[3]
    self.mySoldier[4] = self.mySoldier[4]+#self.heros[4]
    print("maxSoldierNum is", simple.encode(self.maxSoldier))

    self.menuSoldier = simple.decode(simple.encode(self.maxSoldier))
    
    self.bg = CCScene:create()
    self.dialogController = DialogController.new(self)
    self.bg:addChild(self.dialogController.bg)
    
    --initDataFromServer()
    self.initYet = true
    self.needUpdate = true
    registerEnterOrExit(self)
end
function FightScene:update(diff)
    --print("init Fight View", Logic.initYet)
    if self.initYet then
        self.initYet = false
        self.layer = FightLayer2.new(self, self.soldiers[1], self.soldiers[2])
        self.bg:addChild(self.layer.bg)
        self.menu = FightMenu2.new(self)
        self.bg:addChild(self.menu.bg)

    end
end
