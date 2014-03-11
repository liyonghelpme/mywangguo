require "Miao.FightLayer2"
require "Miao.FightMenu2"
FightScene = class()
function FightScene:ctor()
    self.name = "FightScene"
    if DEBUG_SOL then
        local sf = CCSpriteFrameCache:sharedSpriteFrameCache()
        sf:addSpriteFramesWithFile("uiOne.plist")
    end

    initCityData()
    --local testData = CityData[17]
    local ms = Logic.soldiers 
    initPlist()
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
    --
    --根据挑战胜利的村落数量调整士兵数值
    --挑战新手村 只有 英雄

    --村落的hero 使用自定义的
    local isVillage = false
    if not DEBUG_SOL then
        --新手村
        if Logic.newVillage then
            self.soldiers = {{0, 0, 0, 0}, {0, 0, 0, 0}}
        --竞技场
        elseif type(Logic.challengeCity) == 'table' and Logic.challengeCity.kind == 0 then
            local cityData = Logic.arena[math.min(#Logic.arena, Logic.arenaLevel)]
            self.soldiers = {{ms[1][2], ms[2][2], ms[3][2], ms[4][2]}, copyTable(cityData)}
        --城堡 或者 村落 根据 MapNode 里面的kind决定
        else
            local cityInfo = MapNode[Logic.challengeCity]
            local on
            if cityInfo[4] == 1 then
                on = #Logic.ownCity
                local cn = copyTable(Logic.challengeNum)
                cn[1] = math.floor(cn[1]*math.pow(1.1, on))
                cn[2] = math.floor(cn[2]*math.pow(1.1, on))
                cn[3] = math.floor(cn[3]*math.pow(1.1, on))
                cn[4] = math.floor(cn[4]*math.pow(1.1, on))
                self.soldiers = {{ms[1][2], ms[2][2], ms[3][2], ms[4][2]}, cn}
            --挑战村落 我方只有英雄
            --村落兵力不会增长
            elseif cityInfo[4] == 4 then
                --self.soldiers = {{0, 0, 0, 0}, {0, 0, 0, 0}}
                isVillage = true

                on = #Logic.ownVillage
                local cn = copyTable(Logic.challengeNum)
                self.soldiers = {{0, 0, 0, 0}, cn}
                print("village challenge num is ", simple.encode(Logic.challengeNum))
            end
        end
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
    --self.soldiers = {{0, 0, 0, 0}, {5, 0, 0, 0}}
    --self.soldiers = {{0, 0, 0, 90}, {90, 0, 0, 0}}
    --self.soldiers = {{0, 0, 90, 0}, {9, 90, 0, 0}}
    --self.soldiers = {{9, 90, 0, 0}, {0, 0, 90, 0}}
    --调试弓箭手 攻击 目标
    if DEBUG_SOL then
        self.soldiers = {{18, 15, 15, 15}, {18, 15, 15, 15}}
        --self.soldiers = {{10, 0, 0, 0}, {50, 0, 0, 0}}
    end
    --attack defense health 前 中 后 默认都在前方布局  技能属性
    --一个 装备上 铜甲 头巾 防御力 22 远高于一些攻击力 
    
    --self.heros = {{{attack=6*5, defense=0, health=66*5, skill=6} }, {{attack=6*5, defense=0, health=66*5} }, {{attack=6*5, defense=0, health=66*5}}, {{attack=6*5, defense=0, health=66*5}}}
    --self.heros = {{{attack=6*5, defense=0, health=66*5, skill=41} }, {{attack=6*5, defense=0, health=66*5, skill=38} }, {{attack=6*5, defense=0, health=66*5}}, {{attack=6*5, defense=0, health=66*5}}}
    
    --self.heros = {{{attack=6*5, defense=0, health=66*5, skill=45} }, {{attack=6*5, defense=0, health=66*5, skill=38} }, {{attack=6*5, defense=0, health=66*5}}, {{attack=6*5, defense=0, health=66*5}}}

    --self.heros = {{{attack=6*5, defense=0, health=66*5} }, {{attack=6*5, defense=0, health=66*5} }, {{attack=6*5, defense=0, health=66*5}}, {{attack=6*5, defense=0, health=66*5}}}
    --self.heros = {{{attack=6*5, defense=0, health=66*5} }, {{attack=6*5, defense=0, health=66*5} }, {}, {{attack=6*5, defense=0, health=66*5}}}

    --self.heros = {{}, {}, {}, {{attack=6*5, defense=0, health=66*5}}}
    --self.heros = {{}, {}, {{attack=6*5, defense=0, health=66*5}}, {}}
    --self.heros = {{}, {}, {}, {}}
    self.otherHeros = {{}, {}, {}, {}}
    if DEBUG_SOL then
        --self.heros = {{{attack=6*5, defense=0, health=66*5} }, {{attack=6*5, defense=0, health=66*5} }, {{attack=6*5, defense=0, health=66*5}}, {{attack=6*5, defense=0, health=66*5}}}
        self.heros = {{}, {}, {}, {{attack=6*5, defense=0, health=66*5}}}
        self.heros = {{}, {}, {}, {}}
    end
    
    if not DEBUG_SOL then
        self.heros = {{}, {}, {}, {}}
        --对方英雄 otherHeros
        if Logic.newVillage then
            self.otherHeros = simple.decode(simple.encode(Logic.villagePower[Logic.curVillage]))
            print("other heri is", simple.encode(self.otherHeros))
        end

        --设置参战士兵属性
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
                local edata = Logic.equip[equip.spe]
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
            --步兵 弓箭 魔法 骑兵
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
    end

    --将英雄也算入到 maxSoldier中去 
    self.maxSoldier = simple.decode(simple.encode(self.soldiers))
    self.mySoldier = self.maxSoldier[1]
    print("oldMySoldierNum", simple.encode(self.mySoldier))
    self.mySoldier[1] = self.mySoldier[1]+#self.heros[1]
    self.mySoldier[2] = self.mySoldier[2]+#self.heros[2]
    self.mySoldier[3] = self.mySoldier[3]+#self.heros[3]
    self.mySoldier[4] = self.mySoldier[4]+#self.heros[4]
    print("maxSoldierNum is", simple.encode(self.mySoldier))

    self.eneSoldier = self.maxSoldier[2]
    self.eneSoldier[1] = self.eneSoldier[1]+#self.otherHeros[1]
    self.eneSoldier[2] = self.eneSoldier[2]+#self.otherHeros[2]
    self.eneSoldier[3] = self.eneSoldier[3]+#self.otherHeros[3]
    self.eneSoldier[4] = self.eneSoldier[4]+#self.otherHeros[4]

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
