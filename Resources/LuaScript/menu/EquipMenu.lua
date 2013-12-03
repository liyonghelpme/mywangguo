require "Menu.EquipChange"
EquipMenu = class()
function EquipMenu:ctor()
    local vs = getVS()

    self.bg = CCNode:create()
    local temp = display.newScale9Sprite("tabback.jpg")
    temp:setContentSize(CCSizeMake(526, 350))
    self.bg:addChild(temp)
    setPos(temp, {vs.width/2, vs.height/2})

    local tit = setPos(addSprite(temp, "title.png"), {263, fixY(350, 31)})
    local w = ui.newTTFLabel({text="合战部队的编成", font="msyhbd.ttf", size=15, color={0,0,0}})
    temp:addChild(w)
    setAnchor(setPos(w, {263, fixY(350, 31)}), {0.5, 0.5})

    local lv = ui.newBMFontLabel({text="Lv", font="bound.fnt", size=20, color={0,0,0}})
    temp:addChild(lv)
    setAnchor(setPos(lv, {74, fixY(350, 83)}), {0.5, 0.5})

    local lv = ui.newTTFLabel({text="体力", size=18, color={0,0,0}})
    temp:addChild(lv)
    setAnchor(setPos(lv, {144, fixY(350, 83)}), {0.5, 0.5})

    local lv = ui.newTTFLabel({text="攻击", size=18, color={0,0,0}})
    temp:addChild(lv)
    setAnchor(setPos(lv, {199, fixY(350, 83)}), {0.5, 0.5})

    local lv = ui.newTTFLabel({text="防御", size=18, color={0,0,0}})
    temp:addChild(lv)
    setAnchor(setPos(lv, {250, fixY(350, 83)}), {0.5, 0.5})

    local lv = ui.newTTFLabel({text="武", size=18, color={0,0,0}})
    temp:addChild(lv)
    setAnchor(setPos(lv, {316, fixY(350, 83)}), {0.5, 0.5})

    local lv = ui.newTTFLabel({text="头", size=18, color={0,0,0}})
    temp:addChild(lv)
    setAnchor(setPos(lv, {361, fixY(350, 83)}), {0.5, 0.5})

    local lv = ui.newTTFLabel({text="体", size=18, color={0,0,0}})
    temp:addChild(lv)
    setAnchor(setPos(lv, {412, fixY(350, 83)}), {0.5, 0.5})

    local lv = ui.newTTFLabel({text="特", size=18, color={0,0,0}})
    temp:addChild(lv)
    setAnchor(setPos(lv, {466, fixY(350, 83)}), {0.5, 0.5})
    

    self.HEIGHT = 247
    self.touch = ui.newTouchLayer({size={500, self.HEIGHT}, delegate=self, touchBegan=self.touchBegan, touchMoved=self.touchMoved, touchEnded=self.touchEnded})
    temp:addChild(self.touch.bg)
    setPos(self.touch.bg, {0, 0})

    self.cl = Scissor:create()
    temp:addChild(self.cl)
    setContentSize(setPos(self.cl, {27, fixY(350, 335)}), {479, self.HEIGHT})
    self.flowNode = setPos(addNode(self.cl), {0, self.HEIGHT})
    self:updateTab()
end

function EquipMenu:touchBegan(x, y)
    self.lastPoints = {x, y}
    self.accMove = 0
    self.curSel = nil
end

function EquipMenu:moveBack(dify)
    local ox, oy = self.flowNode:getPosition()
    self.flowNode:setPosition(ccp(ox, oy+dify))
end

function EquipMenu:touchMoved(x, y)
    local oldPoints = self.lastPoints
    self.lastPoints = {x, y}
    local dify = self.lastPoints[2]-oldPoints[2]
    self.accMove = self.accMove+math.abs(dify)
    self:moveBack(dify)
end
function EquipMenu:touchEnded(x, y)
    local newPos = {x, y}
    if self.accMove < 10 then
        local child = checkInChild(self.flowNode, newPos)
        if child ~= nil then
            print("touch child", child:getTag())
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
function EquipMenu:updateTab()
    self.flowHeight = 0
    local offY = 43
    local n = 1
    local tempData = {1, 1, 1, 1}
    for k, v in ipairs(tempData) do
        local panel = CCNode:create()
        self.flowNode:addChild(panel)
        setPos(panel, {0, -offY*n})

        local temp = CCSprite:create("psel.png")
        panel:addChild(temp)
        setPos(setSize(temp, {420, 27}), {479/2, 21})
        
        local head = setSize(setPos(addSprite(panel, "king1.png"), {18, 21}), {30, 30})
        local lev = ui.newBMFontLabel({text="16", font="bound.fnt", size=18, color={0,0,0}})
        setPos(lev, {56, 21})
        panel:addChild(lev)

        local name = ui.newTTFLabel({text="126", size=18, font="msyhbd.ttf", color={0,0,0}})
        setPos(name, {115, 21})
        panel:addChild(name)

        local physic = ui.newBMFontLabel({text="32", size=18, font="bound.fnt", color={0,0,0}})
        setAnchor(setPos(physic, {171, 21}), {0.5, 0.5})
        panel:addChild(physic)

        local name = ui.newTTFLabel({text="22", size=18, font="msyhbd.ttf", color={0,0,0}})
        setPos(name, {224, 21})
        panel:addChild(name)

        local ebut = ui.newButton({image="equip70.png", conSize={40, 40}, callback=self.onEq, delegate=self})
        setPos(ebut.bg, {287, 21})
        panel:addChild(ebut.bg)

        local eq = CCSprite:create("equip88.png")
        setSize(setPos(eq, {339, 21}), {40, 40})
        panel:addChild(eq)

        local eq = CCSprite:create("equip0.png")
        setSize(setPos(eq, {386, 21}), {40, 40})
        panel:addChild(eq)

        local eq = CCSprite:create("equip28.png")
        setSize(setPos(eq, {441, 21}), {40, 40})
        panel:addChild(eq)

        self.flowHeight = self.flowHeight+offY
        n = n + 1
    end 
end
function EquipMenu:onEq()
    global.director:popView()
    local ec = EquipChange.new()
    global.director.curScene.menu.menu = ec
    global.director:pushView(ec, 1, 0)
end
