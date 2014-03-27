MenuBase = class()
function MenuBase:setHeight()
    self.backHeight = 370
end
function MenuBase:ctor()
    local vs = getVS()

    self.bg = CCNode:create()
    local temp = display.newScale9Sprite("tabback.jpg")
    temp:setContentSize(CCSizeMake(526, 370))
    self.bg:addChild(temp)
    setPos(temp, {vs.width/2, vs.height/2})
    self.temp = temp

    local tit = setPos(addSprite(temp, "title.png"), {263, fixY(370, 31)})
    local w = ui.newTTFLabel({text="标题", font="msyhbd.ttf", size=15, color={0,0,0}})
    temp:addChild(w)
    setAnchor(setPos(w, {263, fixY(370, 31)}), {0.5, 0.5})
    self.title = w


    self:setItemList()

    self.HEIGHT = 247
    self.touch = ui.newTouchLayer({size={500, self.HEIGHT+43}, delegate=self, touchBegan=self.touchBegan, touchMoved=self.touchMoved, touchEnded=self.touchEnded})
    temp:addChild(self.touch.bg)
    setPos(self.touch.bg, {0, 0})

    self.cl = Scissor:create()
    temp:addChild(self.cl)
    setContentSize(setPos(self.cl, {27, fixY(370, 335)}), {479, self.HEIGHT})
    self.flowNode = setPos(addNode(self.cl), {0, self.HEIGHT})
    self:updateTab()
end


function MenuBase:touchBegan(x, y)
    self.lastPoints = {x, y}
    self.accMove = 0
    self.curSel = nil
end

function MenuBase:moveBack(dify)
    local ox, oy = self.flowNode:getPosition()
    self.flowNode:setPosition(ccp(ox, oy+dify))
end

function MenuBase:touchMoved(x, y)
    local oldPoints = self.lastPoints
    self.lastPoints = {x, y}
    local dify = self.lastPoints[2]-oldPoints[2]
    self.accMove = self.accMove+math.abs(dify)
    self:moveBack(dify)
end
function MenuBase:onChild(c)
    print("onChild!!!!!!!!!!!!!!!!!!!! ", c)
end
function MenuBase:touchEnded(x, y)
    local newPos = {x, y}
    if self.accMove < 10 then
        local child = checkInChild(self.flowNode, newPos)
        if child ~= nil then
            print("touch child", child:getTag())
            self:onChild(child:getTag())
            return 
        end
    end

    if self.flowHeight < self.HEIGHT then
        self.minPos = 0
    else
        self.minPos = self.flowHeight-self.HEIGHT
    end
    local oldPos = getPos(self.flowNode)
    oldPos[2] = oldPos[2]-self.HEIGHT
    oldPos[2] = math.max(0, math.min(self.minPos, oldPos[2]))
    self.flowNode:setPosition(ccp(oldPos[1], oldPos[2]+self.HEIGHT))
    print("flowHeight ", self.flowHeight, self.minPos, self.HEIGHT, oldPos[2])

end

function MenuBase:setTitle(w)
    self.title:setString(w)
end
function MenuBase:setItemList()
    local lv = ui.newBMFontLabel({text="Lv", font="bound.fnt", size=20, color={0,0,0}})
    self.temp:addChild(lv)
    setAnchor(setPos(lv, {74, fixY(370, 83)}), {0.5, 0.5})

    local lv = ui.newTTFLabel({text="体力", size=18, color={0,0,0}})
    self.temp:addChild(lv)
    setAnchor(setPos(lv, {144, fixY(370, 83)}), {0.5, 0.5})

    local lv = ui.newTTFLabel({text="攻击", size=18, color={0,0,0}})
    self.temp:addChild(lv)
    setAnchor(setPos(lv, {199, fixY(370, 83)}), {0.5, 0.5})

    local lv = ui.newTTFLabel({text="防御", size=18, color={0,0,0}})
    self.temp:addChild(lv)
    setAnchor(setPos(lv, {250, fixY(370, 83)}), {0.5, 0.5})

    local lv = ui.newTTFLabel({text="武", size=18, color={0,0,0}})
    self.temp:addChild(lv)
    setAnchor(setPos(lv, {316, fixY(370, 83)}), {0.5, 0.5})

    local lv = ui.newTTFLabel({text="头", size=18, color={0,0,0}})
    self.temp:addChild(lv)
    setAnchor(setPos(lv, {361, fixY(370, 83)}), {0.5, 0.5})

    local lv = ui.newTTFLabel({text="体", size=18, color={0,0,0}})
    self.temp:addChild(lv)
    setAnchor(setPos(lv, {412, fixY(370, 83)}), {0.5, 0.5})

    local lv = ui.newTTFLabel({text="特", size=18, color={0,0,0}})
    self.temp:addChild(lv)
    setAnchor(setPos(lv, {466, fixY(370, 83)}), {0.5, 0.5})
end
function MenuBase:updateTab()
    self.flowHeight = 0
end
