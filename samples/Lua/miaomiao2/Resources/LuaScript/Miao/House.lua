House = class(FuncBuild)

function House:initWork()
    self.bg = CCNode:create()
    local banner, pro = createFacBanner()
    self.pro = pro
    self.banner = banner
    self.banner:setVisible(false)
    setPos(self.banner, {0, 240})
    self.bg:addChild(self.banner)
    self.baseBuild.heightNode:addChild(self.bg)
    registerEnterOrExit(self)
end
function House:enterScene()
    registerUpdate(self)
end
function House:update(diff)
    --print("update House diff", diff)
    --生命值一旦慢的状态就不是在home了
    if self.baseBuild.owner ~= nil then
        local owner = self.baseBuild.owner
        if owner.state == PEOPLE_STATE.IN_HOME then
            self.banner:setVisible(true)
            setFacProNum(self.pro, owner.health, owner.maxHealth)
        else
            self.banner:setVisible(false)
        end
    end
end

function House:removeSelf()
    if self.baseBuild.owner ~= nil then
        self.baseBuild.owner:clearHouse()
        self.baseBuild.owner = nil
    end
end
function House:finishMove()
    --[[
    if self:checkBuildable() then
        self.baseBuild:doMyEffect()
    end
    if self.owner ~= nil then
        self.owner:clearHouse()
        self.owner = nil
    end
    --]]
end
--[[
function House:showInfo()
    local bi
    bi = HouseInfo.new(self.baseBuild)
    global.director:pushView(bi, 1, 0)
    global.director.curScene.menu:setMenu(bi)
end
--]]
function House:getIncWord()
    return "回复"
end
--[[
function House:showIncrease(n)
    local sp = ui.newButton({image="info.png", conSize={100, 45}, text="回复 +"..n, color={0, 0, 0}, size=25})
    self.baseBuild.map.bg:addChild(sp.bg)
    local wp = self.baseBuild.heightNode:convertToWorldSpace(ccp(0, 100))
    local np = self.baseBuild.map.bg:convertToNodeSpace(wp)
    setPos(sp.bg, {np.x, np.y})
    sp.bg:runAction(sequence({moveby(1, 0, 20), callfunc(nil, removeSelf, sp.bg)}))
    self.baseBuild.productNum = self.baseBuild.productNum+n
end
function House:showDecrease(n)
    local sp = ui.newButton({image="info.png", conSize={100, 45}, text="回复 -"..n, color={102, 10, 10}, size=25})
    self.baseBuild.map.bg:addChild(sp.bg)
    local wp = self.baseBuild.heightNode:convertToWorldSpace(ccp(0, 100))
    local np = self.baseBuild.map.bg:convertToNodeSpace(wp)
    setPos(sp.bg, {np.x, np.y})
    sp.bg:runAction(sequence({moveby(1, 0, 20), callfunc(nil, removeSelf, sp.bg)}))
    self.baseBuild.productNum = self.baseBuild.productNum-n
end
--]]


--之前的主人 不为nil 且 之前的主人 不等于 当前新主人
function House:setOwner(s)
    if self.baseBuild.owner ~= nil and self.baseBuild.owner ~= s then
        self.baseBuild.owner.myHouse = nil
    end
end
function House:detailDialog()
    global.director:pushView(StoreInfo2.new(self.baseBuild), 1)
end
