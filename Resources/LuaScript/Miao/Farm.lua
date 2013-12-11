
Farm = class(FuncBuild)
--workNum 有个最大值
function Farm:ctor()
    self.bg = CCNode:create()
    self.baseBuild.bg:addChild(self.bg)
    registerEnterOrExit(self)
    self.state = 0
    self.baseBuild.maxNum = 6
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
        if self.state ~= 1 then
            self.state = 1
            if self.fn == nil then
                self.fn = CCSprite:create("p0.png")
                self.baseBuild.heightNode:addChild(self.fn)
                setPos(self.fn, {0, 40})
            else
                setTexture(self.fn, "p0.png")
            end
        end
    elseif self.baseBuild.workNum >= 2 and self.baseBuild.workNum < 4 then
        if self.state ~= 2 then
            self.state = 2
            if self.fn == nil then
                self.fn = CCSprite:create("p1.png")
                self.baseBuild.heightNode:addChild(self.fn)
                setPos(self.fn, {0, 40})
            else
                setTexture(self.fn, "p1.png")
            end
        end
    elseif self.baseBuild.workNum >= 4 and self.baseBuild.workNum < 6 then
        if self.state ~= 3 then
            self.state = 3
            if self.fn == nil then
                self.fn = CCSprite:create("p2.png")
                self.baseBuild.heightNode:addChild(self.fn)
                setPos(self.fn, {0, 40})
            else
                setTexture(self.fn, "p2.png")
            end
        end
    elseif self.baseBuild.workNum >= 6  then
        if self.state ~= 4 then
            self.state = 4
            if self.fn == nil then
                self.fn = CCSprite:create("p3.png")
                self.baseBuild.heightNode:addChild(self.fn)
                setPos(self.fn, {0, 40})
            else
                setTexture(self.fn, "p3.png")
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
function Farm:finishBuild()
    self.baseBuild:doMyEffect()
end
function Farm:removeSelf()
    if self.baseBuild.owner ~= nil then
        self.baseBuild.owner:clearWork()
        self.baseBuild.owner = nil
    end
end
function Farm:finishMove()
    if self.owner ~= nil then
        self.owner:clearWork()
        self.owner = nil
    end
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




