require "LuaScript.Dialog.HeroFeature"
HeroDialog = class()
function HeroDialog:ctor(scene)
    self.scene = scene
    self.itemWidth = 220
    self.heroId = {}
    self:initView()
    self:initHeros()
end
function HeroDialog:initHeros()
    local n = 0
    self.heros.width = 0
    local vs = CCDirector:sharedDirector():getVisibleSize()
    for k, v in ipairs(HeroData.heros) do
        local temp = CCSprite:create("images/heroBack.png")
        --print("init hero hid", v.hid)
        --temp.hid = v.hid
        self.heros:addChild(temp)
        table.insert(self.heroId, {v.hid, temp})
        temp:setPosition(ccp(100+n*self.itemWidth, vs.height/2))
        self.heros.width = self.heros.width + self.itemWidth

        local hero = CCSprite:create("images/hero.png")
        temp:addChild(hero)
        hero:setPosition(ccp(96, 135))

        local num = ui.newTTFLabel({text=''..v["hid"], size=40, align=ui.TEXT_ALIGN_CENTER, valign=ui.TEXT_VALIGN_CENTER})
        temp:addChild(num)
        num:setPosition(ccp(96, 135))

        n = n+1
    end
end
function HeroDialog:buyHero(param)
    local n = self.heros:getChildrenCount()
    local vs = CCDirector:sharedDirector():getVisibleSize()

    local temp = CCSprite:create("images/heroBack.png")
    --temp.hid = param.hid
    self.heros:addChild(temp)
    --保证有序 和 hid 存在
    table.insert(self.heroId, {param.hid, temp})
    temp:setPosition(ccp(100+n*self.itemWidth, vs.height/2))
    self.heros.width = self.heros.width + self.itemWidth

    local hero = CCSprite:create("images/hero.png")
    temp:addChild(hero)
    hero:setPosition(ccp(96, 135))

    local num = ui.newTTFLabel({text=''..param["hid"], size=40, align=ui.TEXT_ALIGN_CENTER, valign=ui.TEXT_VALIGN_CENTER})
    temp:addChild(num)
    num:setPosition(ccp(96, 135))
     
end
function HeroDialog:sellHero(param)
    local allChildren = self.heros:getChildren()
    local n = self.heros:getChildrenCount()
    local pos = nil
    local vs = CCDirector:sharedDirector():getVisibleSize()
    for k=1, n, 1 do
        --local hero = allChildren:objectAtIndex(k)
        local hid = self.heroId[k][1]
        print("check hero", hid, param.hid)
        if hid == param.hid then
            local hero = self.heroId[k][2] 
            hero:removeFromParentAndCleanup(true)
            table.remove(self.heroId, k)
            pos = k
            break
        end
    end
    if pos == nil then
        return 
    end

    for k=pos, n-1, 1 do
        local hero = self.heroId[k][2] 
        hero:setPosition(ccp(100+(k-1)*self.itemWidth, vs.height/2))
    end
    self.heros.width = self.heros.width-self.itemWidth
end

function HeroDialog:initView()
    self.bg = CCLayer:create()
    self.bg:addChild(FullScreen.new().bg)

local temp
local menu
local vs = CCDirector:sharedDirector():getVisibleSize()

local sci = Scissor:create()
sci:setContentSize(CCSizeMake(vs.width, vs.height))
sci:setPosition(ccp(0, 0))
self.bg:addChild(sci)

self.heros = CCNode:create()
sci:addChild(self.heros)

local touchScroll = {}
touchScroll.content = self.heros
touchScroll.width = vs.width
touchScroll.dialog = self

function touchScroll:onTouchBegan(x, y)
    self.moveAcc = 0
    self.lastPoint = {x, y}
    local sz = self.bg:getContentSize()
    local np = self.bg:convertToNodeSpace(ccp(x, y))

    print("touchScroll", x, y, sz.width, sz.height)
    if np.x >= 0 and np.x < sz.width and np.y > 0 and np.y < sz.height then
        return true
    end
    return false
end
function touchScroll:onTouchMoved(x, y)
    local difx = x - self.lastPoint[1]
    self.moveAcc = self.moveAcc+math.abs(difx)
    local px, py = self.content:getPosition()
    self.lastPoint = {x, y}
    self.content:setPosition(ccp(px+difx, py))
end
--min max 小端对齐 还是 大端对齐
--最大范围值 是多少 
--sci width 决定的 
--宽度太小 也可以居中显示 
function touchScroll:onTouchEnded(x, y)
    local px, py = self.content:getPosition()
    --小端对齐 则 自动移动到小部位
    px = math.max(math.min(0, px), math.min(0, self.width-self.content.width))
    self.content:setPosition(ccp(px, py))
    if self.moveAcc < 10 then
        local findHero = nil
        for k, v in ipairs(self.dialog.heroId) do
            local np = v[2]:convertToNodeSpace(ccp(x, y)) 
            local sz = v[2]:getContentSize()
            if np.x > 0 and np.x < sz.width and np.y > 0 and np.y < sz.height then
                findHero = v
                break
            end
        end
        if findHero ~= nil then
            local hb = HeroFeature.new(findHero[1])
            print("herofeature", hb, hb.bg)
            display.pushView(hb.bg)
            self.dialog.bg:removeFromParentAndCleanup(true)
        end
    end
end
local touchLayer = CCLayer:create()
touchScroll.bg = touchLayer

touchLayer:setContentSize(CCSizeMake(vs.width, 288))
touchLayer:setPosition(ccp(0, vs.height/2-144))
touchLayer:setAnchorPoint(ccp(0, 0))
local showBox = CCSprite:create("images/showBlock.png")
local sz = showBox:getContentSize()
showBox:setScaleX(vs.width/sz.width)
showBox:setScaleY(288/sz.height)
touchLayer:addChild(showBox)
showBox:setAnchorPoint(ccp(0, 0))

registerTouch(touchScroll)
touchLayer:setTouchPriority(kCCMenuHandlerPriority)
self.bg:addChild(touchScroll.bg)



temp = CCSprite:create("images/whitePoint.png")
temp:setPosition(ccp(-30+vs.width/2, 40))
self.bg:addChild(temp)
temp = CCSprite:create("images/halfWhitePoint.png")
temp:setPosition(ccp(-4+vs.width/2, 39))
self.bg:addChild(temp)
temp = CCSprite:create("images/whitePoint.png")
temp:setPosition(ccp(20+vs.width/2, 41))
self.bg:addChild(temp)


temp = CCMenuItemImage:create("images/close.png", "images/closeOn.png")
temp:setPosition(ccp(vs.width-61, vs.height-33))
local close = temp
local function onButton()
    self.bg:removeFromParentAndCleanup(true)
end
temp:registerScriptTapHandler(onButton)
temp = CCMenuItemImage:create("images/block.png", "images/blockOn.png")
temp:setPosition(ccp(208, vs.height-36))
local buy = temp
local function onBuyHero(data, param)
    menu:setEnabled(true)
    HeroData:addHero({hid=param.hid, level=0, quality=0, job=0, kind=param.kind})
    self:buyHero(param)
end

local function onButton()
    menu:setEnabled(false)
    local param = {hid=HeroData:getMaxHid(), kind=0} 
    Network.postData('buyHero', onBuyHero, {uid=User.uid, hid=param.hid, kind=param.kind}, param)
end
temp:registerScriptTapHandler(onButton)
temp = CCMenuItemImage:create("images/block.png", "images/blockOn.png")
temp:setPosition(ccp(321, vs.height-37))
local sell = temp
local function onSell(data, param)
    menu:setEnabled(true)
    HeroData:sellHero(param)
    self:sellHero(param)
end
local function onButton()
    menu:setEnabled(false)
    local param = {hid=HeroData.heros[1].hid} 
    Network.postData("sellHero", onSell, {uid=User.uid, hid=param.hid}, param)
end
temp:registerScriptTapHandler(onButton)
temp = CCMenuItemImage:create("images/block.png", "images/blockOn.png")
temp:setPosition(ccp(87, vs.height-36))
local fight = temp
local function onButton()
end
temp:registerScriptTapHandler(onButton)
menu = CCMenu:create()
menu:setPosition(ccp(0, 0))
self.bg:addChild(menu)
menu:addChild(close)
menu:addChild(buy)
menu:addChild(sell)
menu:addChild(fight)

end

