PeopleInTrain = class()
function PeopleInTrain:ctor(pid)

local vs = getVS()
self.bg = CCNode:create()
local sz = {width=1024, height=768}
self.temp = setPos(addNode(self.bg), {0, fixY(sz.height, 0+sz.height)+0})
local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "sdialoga.png"), {512, fixY(sz.height, 396)}), {633, 427}), {0.50, 0.50}), 255)
local sp = setAnchor(setPos(addChild(self.temp, createSmallDialogb()), {512, fixY(sz.height, 403)}), {0.50, 0.50})

--local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "dialogCat.png"), {749, fixY(sz.height, 500)}), {101, 157}), {0.50, 0.50}), 255)

local sp = setScale(setOpacity(setAnchor(setPos(addSprite(self.temp, "cat_"..pid.."_rb_0.png"), {329, fixY(sz.height, 401)}), {0.50, 0.50}), 255), 0.7)
local ani = createAnimation(string.format("people%d_rb", pid), "cat_"..pid.."_rb_%d.png", 0, 9, 2, aniTime, true)
sp:runAction(repeatForever(CCAnimate:create(ani)))


local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="修行中", size=25, color={10, 76, 176}, font="f1", shadowColor={0, 0, 0}})), {0.00, 0.50}), {482, fixY(sz.height, 356)})
local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="修行", size=35, color={10, 10, 10}, font="f1", shadowColor={0, 0, 0}})), {0.50, 0.50}), {516, fixY(sz.height, 231)})

    self.banner, self.pro = createFacBanner()
    setPos(self.banner, {565, fixY(sz.height, 402)})
    
    self.temp:addChild(self.banner) 
    setFacProNum(self.pro, 0, 10) 

    centerUI(self)
    self.needUpdate = true
    registerEnterOrExit(self)
    self.process = 0
end

function PeopleInTrain:update(diff)
    self.process = self.process+diff
    setFacProNum(self.pro, self.process, 2)
    if self.process >= 2 then
        global.director:popView()
    end
end
