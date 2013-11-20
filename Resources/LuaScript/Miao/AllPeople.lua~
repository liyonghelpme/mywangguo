AllPeople = class()
function AllPeople:ctor(s)
    self.scene = s
    local vs = getVS()

    self.bg = CCNode:create()
    local temp = display.newScale9Sprite("tabback.jpg")
    temp:setContentSize(CCSizeMake(526, 350))
    self.bg:addChild(temp)
    setPos(temp, {vs.width/2, vs.height/2})

    local tit = setPos(addSprite(temp, "title.png"), {263, fixY(350, 31)})
    local w = ui.newTTFLabel({text="村民一览", font="msyhbd.ttf", size=20, color={0,0,0}})
    temp:addChild(w)
    setAnchor(setPos(w, {263, fixY(350, 31)}), {0.5, 0.5})

    local lv = ui.newBMFontLabel({text="Lv", font="bound.fnt", size=20, color={0,0,0}})
    temp:addChild(lv)
    setAnchor(setPos(lv, {74, fixY(350, 83)}), {0.5, 0.5})
    
    local wl = ui.newTTFLabel({text="体力", font="msyhbd.ttf", size=20, color={0,0,0}})
    temp:addChild(wl)
    setAnchor(setPos(wl, {298, fixY(350, 83)}), {0.5, 0.5})

    local wl = ui.newTTFLabel({text="腕力", font="msyhbd.ttf", size=20, color={0,0,0}})
    temp:addChild(wl)
    setAnchor(setPos(wl, {352, fixY(350, 83)}), {0.5, 0.5})

    local wl = ui.newTTFLabel({text="射击", font="msyhbd.ttf", size=20, color={0,0,0}})
    temp:addChild(wl)
    setAnchor(setPos(wl, {411, fixY(350, 83)}), {0.5, 0.5})

    local wl = ui.newTTFLabel({text="劳动", font="msyhbd.ttf", size=20, color={0,0,0}})
    temp:addChild(wl)
    setAnchor(setPos(wl, {470, fixY(350, 83)}), {0.5, 0.5})


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

function AllPeople:touchBegan(x, y)
    self.lastPoints = {x, y}
    self.accMove = 0
    self.curSel = nil

end
function AllPeople:moveBack(dify)
    local ox, oy = self.flowNode:getPosition()
    self.flowNode:setPosition(ccp(ox, oy+dify))
end

function AllPeople:touchMoved(x, y)
    local oldPoints = self.lastPoints
    self.lastPoints = {x, y}
    local dify = self.lastPoints[2]-oldPoints[2]
    self.accMove = self.accMove+math.abs(dify)
    self:moveBack(dify)
end
function AllPeople:touchEnded(x, y)
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

function AllPeople:updateTab()
    self.flowHeight = 0
    local offY = 43
    local n = 1
    for k, v in pairs(self.scene.page.buildLayer.mapGridController.allSoldiers) do
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
        local name = ui.newTTFLabel({text="小明", size=18, font="msyhbd.ttf", color={0,0,0}})
        setPos(name, {114, 21})
        panel:addChild(name)

        local physic = ui.newBMFontLabel({text="20", size=18, font="bound.fnt", color={0,0,0}})
        setAnchor(setPos(physic, {291, 21}), {1, 0.5})
        panel:addChild(physic)

        local brawn = ui.newBMFontLabel({text="126", size=18, font="bound.fnt", color={0,0,0}})
        setAnchor(setPos(brawn, {341, 21}), {1, 0.5})
        panel:addChild(brawn)

        local shoot = ui.newBMFontLabel({text="16", size=18, font="bound.fnt", color={0,0,0}})
        setAnchor(setPos(shoot, {391, 21}), {1, 0.5})
        panel:addChild(shoot)

        local labor = ui.newBMFontLabel({text="73", size=18, font="bound.fnt", color={0,0,0}})
        setAnchor(setPos(labor, {441, 21}), {1, 0.5})
        panel:addChild(labor)

        self.flowHeight = self.flowHeight+offY

        n = n + 1
    end 
end

