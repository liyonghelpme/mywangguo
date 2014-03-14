require "menu.SessionMenu"
require "myMap.FightPage"
require "myMap.FightMenu"
FightMap = class()
function FightMap:ctor()
    self.name = "FightMap"

    initPlist()

    self.bg = CCScene:create()

    self.dialogController = DialogController.new(self)
    self.bg:addChild(self.dialogController.bg)
    
    self.page = FightPage.new()
    self.bg:addChild(self.page.bg)
    
    self.tempNode = addNode(self.bg)
    setVisible(self.tempNode, false)


    self.mist = createSprite("mist.png")
    local vs = getVS()
    setScaleX(self.mist, vs.width/128)
    setScaleY(self.mist, vs.height/128)
    setPos(addChild(self.tempNode, self.mist), {vs.width/2, vs.height/2})


    self.mistRender = CCRenderTexture:create(vs.width, vs.height)
    self.bg:addChild(self.mistRender)
    setPos(self.mistRender, {vs.width/2, vs.height/2})
    --setVisible(self.mistRender)
    local sp = self.mistRender:getSprite()
    local bf = ccBlendFunc()
    

    self.menu = FightMenu.new(self)
    self.bg:addChild(self.menu.bg)
    --initDataFromServer()
    --Logic.initYet = true
    self.needUpdate = true
    registerEnterOrExit(self)
end

function FightMap:update(diff)
    self.mistRender:beginWithClear(0, 0, 0, 0)
    self.mist:visit()
    local p = getPos(self.page.bg)
    local sca = getScale(self.page.bg)
    setScale(setPos(self.page.lightNode, p), sca)

    self.page.lightNode:visit()
    self.mistRender:endToLua()

end


function FightMap:checkWin()
    print("FightMenu checkWin", Logic.challengeCity)
    --addBanner("FightMap checkWin")
    --挑战竞技场胜利
    if type(Logic.challengeCity) == 'table' and Logic.challengeCity.kind == 0 then
        if Logic.winArena then
            Logic.winArena = false
            --global.director:pushView(, 1, 0)
            addDialog(SessionMenu.new("挑战竞技场胜利了", nil, nil, {butOk=true}))
            Logic.lastArenaTime = Logic.date
            --士兵数量
            local cityData = Logic.arena[math.min(#Logic.arena, Logic.arenaLevel)]
            local reward = Logic.arenaReward[Logic.arenaLevel]
            local silver = (Logic.arenaLevel-1)*50+500
            --难度提升1
            Logic.arenaLevel = Logic.arenaLevel+1
            if reward[1] == 'equip' then
                --出现在商店里面
                if reward[4] then
                    table.insert(Logic.ownGoods, {0, reward[2]})
                    Logic.ownGoodsDirty = true
                end
                --持有数量增加
                changeEquip(reward[2], reward[3])
                local edata = Logic.equip[reward[2]]
                addBanner("获得物品"..edata.name..reward[3])
            elseif reward[1] == 'goods' then
                --兵法书
                if reward[2] == 39 then
                    Logic.fightNum = Logic.fightNum+1
                    addBanner("合战人数增加1")
                else
                end
            elseif reward[1] == 'build' then
                addNewBuild(reward[2])
                local bd = Logic.buildings[reward[2]]
                addBanner("获得建筑物"..bd.name)
            elseif reward[1] == 'gold' then
                silver = silver+reward[3]
            end
            --获得银币
            doGain(silver)
            addBanner("获得银币"..silver)
        end
    --挑战普通城堡胜利
    elseif Logic.ownCity[Logic.challengeCity] ~= nil then
        --addBanner("获取 胜利奖励！")
        --global.director:pushView(, 1, 0)
        addDialog(SessionMenu.new("合战胜利了!", nil, nil, {butOk=true}))
        local city = self.page.cidToCity[Logic.challengeCity]
        city:setColor(0)
        --城堡
        if city.kind == 1 then
            --城堡数据
            local cp = Logic.castlePeople[city.realId]
            if cp ~= nil then
                addNewPeople(cp)
                showPeopleInfo(cp)
            end

            local cg = Logic.cityGoods[city.realId]
            print("wingoods", simple.encode(cg))

            if cg ~= nil then
                cg = cg.goods
                --买一个装备就没有了 不能重复购买
                for k, v in ipairs(cg.equip) do
                    local edata = Logic.equip[v]
                    addBanner("获得了装备"..edata.name)
                    --table.insert(Logic.ownGoods, {0, edata.id})
                    --装备只可以获得1个不能从商店购买
                    changeEquip(edata.id, 1)
                end
                --研究用的书籍 可以 研究新装备
                for k, v in ipairs(cg.goods) do
                    local edata = GoodsName[v]
                    addBanner("获得新物品"..edata.name)
                    local findTech = false
                    for tk, tv in pairs(Logic.techId) do
                        if tv == v then
                            Logic.ownTech[tk] = Logic.ownTech[tk]+1
                            Logic.ownTechDirty = true
                            addBanner("技能书获得"..edata.name.."lv"..Logic.ownTech[tk])
                            local eq = checkTechNewEquip(tk, Logic.ownTech[tk])
                            for ek, ev in ipairs(eq) do
                                local equipData = Logic.equip[ev]
                                addBanner("可以研究新的物品了"..equipData.name)
                                table.insert(Logic.researchGoods, {0, ev})
                                Logic.researchGoodsDirty = true
                            end
                            findTech = true
                            break
                        end
                    end
                    --不是技术书籍 兵种数据 和 土地证书
                    if not findTech then
                        if v == 46 then
                            Logic.soldiers[2] = {1, 30} 
                            addBanner("获得新兵种 弓兵")
                        elseif v == 47 then
                            Logic.soldiers[3] = {1, 20} 
                            addBanner("获得新兵种 魔法兵")
                        elseif v == 48 then
                            Logic.soldiers[4] = {1, 10} 
                            addBanner("获得新兵种 骑兵")
                        elseif v == 38 then
                            Logic.landBook = Logic.landBook+1 
                            addBanner("获得土地产权证书")
                        elseif v == 39 then
                            Logic.fightNum = Logic.fightNum+1
                            addBanner("合战人数增加1")
                        end
                    end
                end
                
                for k, v in ipairs(cg.build) do
                    local edata = Logic.buildings[v]
                    addBanner("获得新建筑物"..edata.name)
                    addNewBuild(edata.id)
                end
                local silver = cg.silver
                doGain(silver)
                addBanner("获得银币"..silver)
            end
            
            self.page:showNewCity()
        --村落
        elseif city.kind == 4 then
            Logic.ownCity[Logic.challengeCity] = nil
            Logic.ownVillage[Logic.challengeCity] = true
            Logic.ownVillageDirty = true
            local cp = Logic.villagePeople[city.realId]
            if cp ~= nil then
                addNewPeople(cp)
                showPeopleInfo(cp)
            end
            print("village people", cp)

            local cg = Logic.villageGoods[city.realId]
            print("wingoods", simple.encode(cg))

            if cg ~= nil then
                cg = cg.goods
                --买一个装备就没有了 不能重复购买
                for k, v in ipairs(cg.equip) do
                    local edata = Logic.equip[v]
                    addBanner("获得了装备"..edata.name)
                    --table.insert(Logic.ownGoods, {0, edata.id})
                    --装备只可以获得1个不能从商店购买
                    changeEquip(edata.id, 1)
                end
                --研究用的书籍 可以 研究新装备
                for k, v in ipairs(cg.goods) do
                    local edata = GoodsName[v]
                    addBanner("获得新物品"..edata.name)
                    local findTech = false
                    for tk, tv in pairs(Logic.techId) do
                        if tv == v then
                            Logic.ownTech[tk] = Logic.ownTech[tk]+1
                            Logic.ownTechDirty = true
                            addBanner("技能书获得"..edata.name.."lv"..Logic.ownTech[tk])
                            local eq = checkTechNewEquip(tk, Logic.ownTech[tk])
                            for ek, ev in ipairs(eq) do
                                local equipData = Logic.equip[ev]
                                addBanner("可以研究新的物品了"..equipData.name)
                                table.insert(Logic.researchGoods, {0, ev})
                                Logic.researchGoodsDirty = true
                            end
                            findTech = true
                            break
                        end
                    end
                    --不是技术书籍 兵种数据 和 土地证书
                    if not findTech then
                        if v == 46 then
                            Logic.soldiers[2] = {1, 30} 
                            addBanner("获得新兵种 弓兵")
                        elseif v == 47 then
                            Logic.soldiers[3] = {1, 20} 
                            addBanner("获得新兵种 魔法兵")
                        elseif v == 48 then
                            Logic.soldiers[4] = {1, 10} 
                            addBanner("获得新兵种 骑兵")
                        elseif v == 38 then
                            Logic.landBook = Logic.landBook+1 
                            addBanner("获得土地产权证书")
                        elseif v == 39 then
                            Logic.fightNum = Logic.fightNum+1
                            addBanner("合战人数增加1")
                        end
                    end
                end
                
                for k, v in ipairs(cg.build) do
                    local edata = Logic.buildings[v]
                    addBanner("获得新建筑物"..edata.name)
                    addNewBuild(edata.id)
                end
                local silver = cg.silver
                doGain(silver)
                addBanner("获得银币"..silver)
            end
        --新手村不在这里处理
        end
    else
        --global.director:pushView(, 1, 0)
        addDialog(SessionMenu.new("合战失败了!", nil, nil, {butOk=true}))
    end
end
--显示可以启用的人才
function showPeopleInfo(c)
    for k, v in ipairs(c) do
        local pd = Logic.people[v]
        addBanner("可以启用"..pd.name)
    end
end

