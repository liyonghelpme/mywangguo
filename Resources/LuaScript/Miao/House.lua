House = class(FuncBuild)
function House:finishBuild()
    self.baseBuild:doMyEffect()
end
function House:initWork()
    self.bg = CCNode:create()
    local banner = setSize(CCSprite:create("probg.png"), {100, 19})
    local pro = display.newScale9Sprite("pro.png")
    banner:addChild(pro)
    setAnchor(setPos(pro, {27, fixY(76, 40)}), {0, 0.5})
    self.pro = pro
    self.banner = banner
    self.banner:setVisible(false)
    setPos(self.banner, {0, 94})
    self.bg:addChild(self.banner)
    self.baseBuild.bg:addChild(self.bg)
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
            local l = owner.health/owner.maxHealth*339
            setContentSize(self.pro, {l, 29})
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
    if self.owner ~= nil then
        self.owner:clearHouse()
        self.owner = nil
    end
end
