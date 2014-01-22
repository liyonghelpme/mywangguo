require "myMap.FightPage"
require "myMap.FightMenu"
FightMap = class()
function FightMap:ctor()
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
    addBanner("FightMap checkWin")
    if Logic.ownCity[Logic.challengeCity] ~= nil then
        addBanner("获取 胜利奖励！")
        local city = self.page.cidToCity[Logic.challengeCity]
        city:setColor(0)
        if city.kind == 1 then
            --城堡数据
            local cp = Logic.castlePeople[city.realId]
            if cp ~= nil then
                Logic.ownPeople = concateTable(Logic.ownPeople, cp)
                showPeopleInfo(cp)
            end
        elseif city.kind == 2 then
            local cp = Logic.villagePeople[city.realId]
            if cp ~= nil then
                Logic.ownPeople = concateTable(Logic.ownPeople, cp)
                showPeopleInfo(cp)
            end
        --新手村不在这里处理
        end
    end
end
function showPeopleInfo(c)
    for k, v in ipairs(c) do
        local pd = Logic.people[v]
        addBanner("可以启用"..pd.name)
    end
end

