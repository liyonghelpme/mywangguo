require "views.Bomb"
TestBomb = class()
function TestBomb:ctor()
    self.bg = CCScene:create()
    self:initMagic()
    local sol = {}
    sol.bg = CCNode:create()
    self.bg:addChild(sol.bg)
    local bomb = Bomb.new(sol)
    setPos(sol.bg, {400, 240})
    sol.map = self

    local function att() 
        bomb:doAttack()
    end
    delayCall(0.5, att)
end
function TestBomb:initMagic()
        local tex = CCTextureCache:sharedTextureCache():addImage("fig7.png")
        local ca = CCSpriteFrameCache:sharedSpriteFrameCache()
        for i=0, 1 do
            for j=0, 3 do
                local r = CCRectMake(120*j, 120*i, 120, 120)
                local sp = CCSpriteFrame:createWithTexture(tex, r)
                ca:addSpriteFrame(sp, "ball"..i*10+j)
            end
        end

        local r = CCRectMake(0, 240, 240, 60)
        local sp = CCSpriteFrame:createWithTexture(tex, r)
        ca:addSpriteFrame(sp, "arrow0")

        local r = CCRectMake(0, 300, 240, 60)
        local sp = CCSpriteFrame:createWithTexture(tex, r)
        ca:addSpriteFrame(sp, "arrow1")

        local r = CCRectMake(0, 360, 240, 60)
        local sp = CCSpriteFrame:createWithTexture(tex, r)
        ca:addSpriteFrame(sp, "arrow2")

        local r = CCRectMake(360, 240, 120, 120)
        local sp = CCSpriteFrame:createWithTexture(tex, r)
        ca:addSpriteFrame(sp, "bombCircle")
end
