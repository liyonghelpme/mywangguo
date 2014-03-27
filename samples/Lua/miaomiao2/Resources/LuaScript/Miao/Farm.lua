
Farm = class(FuncBuild)
--workNum 有个最大值
function Farm:ctor()
    self.bg = CCNode:create()
    self.baseBuild.bg:addChild(self.bg)
    registerEnterOrExit(self)
    self.state = 0
    self.baseBuild.maxNum = 6
end

function Farm:initView()
    local bd = Logic.buildings[self.baseBuild.id]
    local sz = self.baseBuild.changeDirNode:getContentSize()
    setScale(setPos(setAnchor(self.baseBuild.changeDirNode, {248.8/sz.width, (sz.height-236)/sz.height}), {0, SIZEY}), 1.25)
end

function Farm:enterScene()
    registerUpdate(self)
end
function Farm:update(diff)
    --print("farm update", diff, self.baseBuild.workNum)
    --0 1 
    --2 3 
    --4 5
    --6
    if self.baseBuild.workNum >0 and self.baseBuild.workNum < 2 then
        if self.state < 1 then
            self.state = 1
            if self.fn == nil then
                self.fn = createSprite("p0.png")
                self.baseBuild.heightNode:addChild(self.fn)
                local sz = self.fn:getContentSize() 
                setScale(setPos(setAnchor(self.fn, {248.8/sz.width, (sz.height-236)/sz.height}), {0, SIZEY}), 1.25)
            else
                setDisplayFrame(self.fn, "p0.png")
            end
        end
    elseif self.baseBuild.workNum >= 2 and self.baseBuild.workNum < 4 then
        if self.state < 2 then
            self.state = 2
            if self.fn == nil then
                self.fn = createSprite("p1.png")
                self.baseBuild.heightNode:addChild(self.fn)
                local sz = self.fn:getContentSize() 
                setScale(setPos(setAnchor(self.fn, {248.8/sz.width, (sz.height-236)/sz.height}), {0, SIZEY}), 1.25)
            else
                setDisplayFrame(self.fn, "p1.png")
            end
        end
    elseif self.baseBuild.workNum >= 4 and self.baseBuild.workNum < 6 then
        if self.state < 3 then
            self.state = 3
            if self.fn == nil then
                self.fn = createSprite("p2.png")
                self.baseBuild.heightNode:addChild(self.fn)
                local sz = self.fn:getContentSize() 
                setScale(setPos(setAnchor(self.fn, {248.8/sz.width, (sz.height-236)/sz.height}), {0, SIZEY}), 1.25)
            else
                setDisplayFrame(self.fn, "p2.png")
            end
        end
    elseif self.baseBuild.workNum >= 6  then
        if self.state < 4 then
            self.state = 4
            if self.fn == nil then
                self.fn = createSprite("p3.png")
                self.baseBuild.heightNode:addChild(self.fn)
                local sz = self.fn:getContentSize() 
                setScale(setPos(setAnchor(self.fn, {248.8/sz.width, (sz.height-236)/sz.height}), {0, SIZEY}), 1.25)
            else
                setDisplayFrame(self.fn, "p3.png")
            end
        end
    elseif self.baseBuild.workNum == 0 then
        self.state = 0
        if self.fn ~= nil then
            removeSelf(self.fn)
            self.fn = nil
        end
    end
end

function Farm:exitScene()
end

function Farm:initState()
end
function Farm:removeSelf()
    if self.baseBuild.owner ~= nil then
        self.baseBuild.owner:clearWork()
        self.baseBuild.owner = nil
    end
end
--移动结束 清理持有者的工作状态
function Farm:finishMove()
    --[[
    if self:checkBuildable() then
        self.baseBuild:doMyEffect()
    end
    if self.owner ~= nil then
        self.owner:clearWork()
        self.owner = nil
    end
    --]]
end

function Farm:setBuyer(b)
    self.buyer = b
end
function Farm:clearBuyer()
    self.buyer = nil
end
--农田没有购买者
function Farm:checkBuyer()
    return self.buyer == nil
end

function Farm:getIncWord()
    return "生产"
end
--[[
function Farm:showIncrease(n)
    local sp = ui.newButton({image="info.png", conSize={100, 45}, text="生产 +"..n, color={0, 0, 0}, size=25})
    self.baseBuild.map.bg:addChild(sp.bg)
    local wp = self.baseBuild.heightNode:convertToWorldSpace(ccp(0, 100))
    local np = self.baseBuild.map.bg:convertToNodeSpace(wp)
    setPos(sp.bg, {np.x, np.y})
    sp.bg:runAction(sequence({moveby(1, 0, 20), callfunc(nil, removeSelf, sp.bg)}))
    self.baseBuild.productNum = self.baseBuild.productNum+n
end

function Farm:showDecrease(n)
    local sp = ui.newButton({image="info.png", conSize={100, 45}, text="生产 -"..n, color={0, 0, 0}, size=25})
    self.baseBuild.map.bg:addChild(sp.bg)
    local wp = self.baseBuild.heightNode:convertToWorldSpace(ccp(0, 100))
    local np = self.baseBuild.map.bg:convertToNodeSpace(wp)
    setPos(sp.bg, {np.x, np.y})
    sp.bg:runAction(sequence({moveby(1, 0, 20), callfunc(nil, removeSelf, sp.bg)}))
    self.baseBuild.productNum = self.baseBuild.productNum-n
end
--]]


function Farm:getProductName()
    return "食材"
end
function Farm:getProductPrice()
    return "3贯"
end

function Farm:detailDialog()
    global.director:pushView(StoreInfo2.new(self.baseBuild), 1)   
end
