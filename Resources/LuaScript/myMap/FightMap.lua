require "menu.SessionMenu"
require "myMap.FightPage"
require "myMap.FightMenu"
FightMap = class()
function FightMap:ctor()
    initPlist()

    self.bg = CCScene:create()
    self.page = FightPage.new()
    self.bg:addChild(self.page.bg)
    self.menu = FightMenu.new(self)
    self.bg:addChild(self.menu.bg)

    self.dialogController = DialogController.new(self)
    self.bg:addChild(self.dialogController.bg)
end
function FightMap:checkWin()
    print("FightMenu checkWin", Logic.challengeCity)
    --addBanner("FightMap checkWin")
    if Logic.ownCity[Logic.challengeCity] ~= nil then
        --addBanner("获取 胜利奖励！")
        global.director:pushView(SessionMenu.new("合战胜利了!"), 1, 0)
        local city = self.page.cidToCity[Logic.challengeCity]
        city:setColor(0)
        if city.kind == 1 then
            --城堡数据
            local cp = Logic.castlePeople[city.realId]
            if cp ~= nil then
                Logic.ownPeople = concateTable(Logic.ownPeople, cp)
                showPeopleInfo(cp)
            end

            local cg = Logic.cityGoods[city.realId]
            if cg ~= nil then
                cg = cg.goods
                --买一个装备就没有了 不能重复购买
                for k, v in ipairs(cg.equip) do
                    local edata = Logic.equip[v]
                    addBanner("获得了装备"..edata.name)
                    table.insert(Logic.ownGoods, {0, edata.id})
                end
                --研究用的书籍 可以 研究新装备
                for k, v in ipairs(cg.goods) do
                    local edata = GoodsName[v]
                    addBanner("获得新物品"..edata.name)
                end
                
                for k, v in ipairs(cg.build) do
                    local edata = Logic.buildings[v]
                    addBanner("获得新建筑物"..edata.name)
                end
            end
        elseif city.kind == 2 then
            local cp = Logic.villagePeople[city.realId]
            if cp ~= nil then
                Logic.ownPeople = concateTable(Logic.ownPeople, cp)
                showPeopleInfo(cp)
            end
        --新手村不在这里处理
        end
    else
        global.director:pushView(SessionMenu.new("合战失败了!"), 1, 0)
    end
end
--显示可以启用的人才
function showPeopleInfo(c)
    for k, v in ipairs(c) do
        local pd = Logic.people[v]
        addBanner("可以启用"..pd.name)
    end
end

