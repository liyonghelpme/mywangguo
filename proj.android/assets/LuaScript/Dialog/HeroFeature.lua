HeroFeature = class()
function HeroFeature:ctor(hid)
    self.hid = hid 
    self:initView()
end
function HeroFeature:initView()

self.bg = CCLayer:create()
self.bg:addChild(FullScreen.new().bg)
local temp
local menu
local vs = CCDirector:sharedDirector():getVisibleSize()
temp = CCLabelTTF:create("phyDef2", "", 18, CCSizeMake(0, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentBottom)
temp:setAnchorPoint(ccp(0.00, 0.00))
temp:setPosition(ccp(146+vs.width/2, -55+vs.height/2))
self.bg:addChild(temp)
self.phyDef2 = temp
temp = CCSprite:create("images/heroBlock.png")
temp:setPosition(ccp(-198+vs.width/2, 18+vs.height/2))
temp:setAnchorPoint(ccp(0.50, 0.50))
self.bg:addChild(temp)
self.heroBlock = temp
temp = ui.newTTFLabel({text=""..self.hid, size=50})
temp:setAnchorPoint(ccp(0.5, 0.5))
temp:setPosition(ccp(-198+vs.width/2, 18+vs.height/2))
self.bg:addChild(temp)

temp = CCLabelTTF:create("attack1", "", 18, CCSizeMake(0, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentBottom)
temp:setAnchorPoint(ccp(0.00, 0.00))
temp:setPosition(ccp(-11+vs.width/2, 85+vs.height/2))
self.bg:addChild(temp)
self.attack1 = temp
temp = CCLabelTTF:create("attack2", "", 18, CCSizeMake(0, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentBottom)
temp:setAnchorPoint(ccp(0.00, 0.00))
temp:setPosition(ccp(146+vs.width/2, 85+vs.height/2))
self.bg:addChild(temp)
self.attack2 = temp
temp = CCLabelTTF:create("health1", "", 18, CCSizeMake(0, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentBottom)
temp:setAnchorPoint(ccp(0.00, 0.00))
temp:setPosition(ccp(-12+vs.width/2, 12+vs.height/2))
self.bg:addChild(temp)
self.health1 = temp
temp = CCLabelTTF:create("health2", "", 18, CCSizeMake(0, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentBottom)
temp:setAnchorPoint(ccp(0.00, 0.00))
temp:setPosition(ccp(146+vs.width/2, 14+vs.height/2))
self.bg:addChild(temp)
self.health2 = temp
temp = CCLabelTTF:create("phyDef1", "", 18, CCSizeMake(0, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentBottom)
temp:setAnchorPoint(ccp(0.00, 0.00))
temp:setPosition(ccp(-12+vs.width/2, -58+vs.height/2))
self.bg:addChild(temp)
self.phyDef1 = temp
temp = CCLabelTTF:create("magDef2", "", 18, CCSizeMake(0, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentBottom)
temp:setAnchorPoint(ccp(0.00, 0.00))
temp:setPosition(ccp(149+vs.width/2, -119+vs.height/2))
self.bg:addChild(temp)
self.magDef2 = temp
temp = CCLabelTTF:create("magDef1", "", 18, CCSizeMake(0, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentBottom)
temp:setAnchorPoint(ccp(0.00, 0.00))
temp:setPosition(ccp(-13+vs.width/2, -121+vs.height/2))
self.bg:addChild(temp)
self.magDef1 = temp
temp = CCMenuItemImage:create("images/close.png", "images/closeOn.png")
temp:setPosition(ccp(vs.width-64, vs.height-36))
local close = temp
local function onClose()
    self.bg:removeFromParentAndCleanup(true)
end
close:registerScriptTapHandler(onClose)
self.close = temp

--[[
temp = CCMenuItemImage:create("images/block.png", "images/blockOn.png")
temp:setPosition(ccp(128+vs.width/2, -187+vs.height/2))
local block = temp
local function onLevelUp(data)
    menu:setEnabled(true)
    HeroData:updateLevel(self.hid)
    local hero = HeroData:getHero(self.hid)
    self.level:setString(""..hero.level)
end
local function onBlock()
    local hero = HeroData:getHero(self.hid)
    Network.postData('levelUpHero', onLevelUp, {uid=User.uid, hid=self.hid, level=hero.level+1})
    menu:setEnabled(false)
end
block:registerScriptTapHandler(onBlock)
self.block = temp
--]]


temp = CCMenuItemImage:create("images/block.png", "images/blockOn.png")
temp:setPosition(ccp(33+vs.width/2, -186+vs.height/2))
local levelUp = temp
local label = CCLabelTTF:create("升级", "", 18, CCSizeMake(0, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
label:setAnchorPoint(ccp(0.5, 0.5))
label:setPosition(ccp(45, 24))
temp:addChild(label)
local function finishLevelUp(data, param)
    menu:setEnabled(true)
    HeroData:updateLevel(self.hid)
    local hero = HeroData:getHero(self.hid)
    self.level:setString(""..hero.level)
end
local function onLevelup()
    local hero = HeroData:getHero(self.hid)
    Network.postData('levelUpHero', finishLevelUp, {uid=User.uid, hid=self.hid, level=hero.level+1})
    menu:setEnabled(false)
end
levelUp:registerScriptTapHandler(onLevelup)
self.levelUp = temp

temp = CCMenuItemImage:create("images/block.png", "images/blockOn.png")
temp:setPosition(ccp(244+vs.width/2, -184+vs.height/2))

local label = CCLabelTTF:create("转职", "", 18, CCSizeMake(0, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
label:setAnchorPoint(ccp(0.5, 0.5))
label:setPosition(ccp(45, 24))
temp:addChild(label)

local changeJob = temp
local function finishChangeJob(data, param)
    menu:setEnabled(true)
    HeroData:transferHero(self.hid)

end
local function onChangejob()
    local hero = HeroData:getHero(self.hid)
    Network.postData('transferHero', finishChangeJob, {uid=User.uid, hid=self.hid, job=hero.job+1})
    menu:setEnabled(false)
end
changeJob:registerScriptTapHandler(onChangejob)
self.changeJob = temp


temp = CCMenuItemImage:create("images/block.png", "images/blockOn.png")
temp:setPosition(ccp(140+vs.width/2, -184+vs.height/2))
local upgrade = temp
local label = CCLabelTTF:create("进化", "", 18, CCSizeMake(0, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
label:setAnchorPoint(ccp(0.5, 0.5))
label:setPosition(ccp(45, 24))
temp:addChild(label)
local function finishUpgrade(data)
    menu:setEnabled(true)
    HeroData:improveQuality(self.hid)
end
local function onUpgrade()
    local hero = HeroData:getHero(self.hid)
    Network.postData('improveQuality', finishUpgrade, {uid=User.uid, hid=self.hid, quality=hero.quality+1})
    menu:setEnabled(false)
end
upgrade:registerScriptTapHandler(onUpgrade)
self.upgrade = temp



local hero = HeroData:getHero(self.hid)
temp = CCLabelTTF:create(""..hero.level, "", 18, CCSizeMake(0, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentBottom)
temp:setAnchorPoint(ccp(0.50, 0.50))
temp:setPosition(ccp(203, 113))
self.bg:addChild(temp)
self.level = temp


menu = CCMenu:create()
menu:setPosition(ccp(0, 0))
self.bg:addChild(menu)
menu:addChild(close)
menu:addChild(levelUp)
menu:addChild(changeJob)
menu:addChild(upgrade)

end
