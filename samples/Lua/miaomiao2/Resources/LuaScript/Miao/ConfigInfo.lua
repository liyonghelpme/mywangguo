ConfigInfo = class()
function ConfigInfo:ctor()
    self.bg = CCNode:create()
    local vs = getVS()
    local temp = setPos(setContentSize(addChild(self.bg, display.newScale9Sprite("tabback.jpg")), {500, 325}), {vs.width/2, vs.height/2})
    local tit = setPos(addSprite(temp, "title.png"), {250, fixY(325, 26)})
    local tw = setPos(addChild(temp, ui.newTTFLabel({text="部队配置", size=15, color={10, 10, 10}})), {250, fixY(325, 29)})
    
    local lv = setPos(addChild(temp, ui.newBMFontLabel({text="Lv", font="bound.fnt", size=20, color={0,0,0}})), {74, fixY(325,60)})

    local lv = setPos(addChild(temp, ui.newTTFLabel({text="配置场地", font="bound.fnt", size=20, color={10,76,176}})), {385, fixY(325, 60)})

    
    self.HEIGHT = 222

    self.touch = ui.newTouchLayer({size={500, self.HEIGHT}, delegate=self, touchBegan=self.touchBegan, touchMoved=self.touchMoved, touchEnded=self.touchEnded})
    temp:addChild(self.touch.bg)
    setPos(self.touch.bg, {9, fixY(325, 285)})
    
    self.cl = Scissor:create()
    temp:addChild(self.cl)
    setContentSize(setPos(self.cl, {9, fixY(325, 285)}), {477, self.HEIGHT})
    self.flowNode = setPos(addNode(self.cl), {0, self.HEIGHT})
    
    self:updateTab()

    local w = setAnchor(setPos(addChild(temp, ui.newTTFLabel({text="体力", size=15, color={10, 76, 176}})), {16, fixY(325, 302)}), {0, 0.5})

    local w = setAnchor(setPos(addChild(temp, ui.newBMFontLabel({text="126", font="fonts.fnt", size=15, color={10, 10, 10}})), {83, fixY(325, 302)}), {1,0.5})

    local w = setAnchor(setPos(addChild(temp, ui.newTTFLabel({text="攻击", size=15, color={10, 76, 176}})), {104, fixY(325, 302)}), {0, 0.5})
    
    local w = setAnchor(setPos(addChild(temp, ui.newBMFontLabel({text="45", font="fonts.fnt", size=15, color={10, 10, 10}})), {161, fixY(325, 302)}), {1, 0.5})

    local p = setPos(setSize(addSprite(temp, "talent_item3.png"), {30, 30}), {308, fixY(325, 302)})
    local w = setAnchor(setPos(addChild(temp, ui.newTTFLabel({text="盗窃财产", size=15, color={10, 10, 10}})), {328, fixY(325, 302)}), {0, 0.5})

end
function ConfigInfo:updateTab()
    self.flowHeight = 0
    local offY = 44
    local n = 1
    self.data = {}

    local tem = {{1, 1, 1, 1}, {1, 1, 1, 1}, {1, 1, 1, 1}, {1, 1, 1, 1}}
    self.data = {}
    for k, v in ipairs(tem) do
        local panel = CCNode:create()
        self.flowNode:addChild(panel)
        setContentSize(setPos(panel, {0, -offY*n}), {472, 44})
        panel:setTag(k)

        local temp = CCSprite:create("psel.png")
        panel:addChild(temp)
        setPos(setSize(temp, {450, 27}), {472/2, 22})
        
        local w = setPos(addChild(panel, ui.newTTFLabel({text="步卒", size=15, color={10, 10, 10}})), {472/2, 22})
        self.flowHeight = self.flowHeight+offY
        n = n+1
        local pp = {}
        table.insert(self.data, pp)
        for tk, tv in ipairs(v) do
            local panel = CCNode:create()
            self.flowNode:addChild(panel)
            setContentSize(setPos(panel, {0, -offY*n}), {485, 49})
            panel:setTag(k)

            local temp = CCSprite:create("psel.png")
            panel:addChild(temp)
            setPos(setSize(temp, {420, 27}), {485/2, 21})

            local head = setPos(setSize(addSprite(panel, "king1.png"), {30, 30}), {15, 21})
            local lev = setAnchor(setPos(addChild(panel, ui.newBMFontLabel({text="30", font="bound.fnt", size=15, color={52,101,36}})), {71, 21}), {1, 0.5})
            local name = setPos(setAnchor(addChild(panel, ui.newTTFLabel({text="小王", size=15, font="msyhbd.ttf", color={0,0,0}})), {1, 0.5}), {116, 21})
            local arrow = setPos(setSize(addSprite(panel, "selArrow.png"), {60, 41}), {228, 21})

            local arrow = setScaleX(setPos(setSize(addSprite(panel, "selArrow.png"), {60, 41}), {426, 21}), -1)
            
            local but = ui.newButton({image="greenBall.png", conSize={30, 30}, text="后", color={0, 0, 0}, size=15, callback=self.onPos, delegate=self, param={k, tk, 1}})
            setPos(addChild(panel, but.bg), {286, 21})
            local but1 = but
            local but = ui.newButton({image="greenBall.png", conSize={30, 30}, text="中", color={0, 0, 0}, size=15, callback=self.onPos, delegate=self, param={k, tk, 2} })
            but.sp:setOpacity(0)
            setPos(addChild(panel, but.bg), {331, 21})
            local but2 = but
            local but = ui.newButton({image="greenBall.png", conSize={30, 30}, text="前", color={0, 0, 0}, size=15, callback=self.onPos, delegate=self, param={k, tk, 3}})
            but.sp:setOpacity(0)
            setPos(addChild(panel, but.bg), {368, 21})
            local but3 = but

            self.flowHeight = self.flowHeight+offY
            n = n + 1
            table.insert(pp, {but1, but2, but3})
        end
    end
end
function ConfigInfo:onPos(p)
    local ab = self.data[p[1]][p[2]]
    for k, v in ipairs(ab) do
        v.sp:setOpacity(0)
    end
    ab[p[3]].sp:setOpacity(255)
end
function ConfigInfo:onClose()
    local fin = FightInfo.new()
    global.director.curScene.menu.menu = fin
    global.director:pushView(fin)
end

function ConfigInfo:touchBegan(x, y)
    self.lastPoints = {x, y}
    self.accMove = 0
    self.curSel = nil

end
function ConfigInfo:moveBack(dify)
    local ox, oy = self.flowNode:getPosition()
    self.flowNode:setPosition(ccp(ox, oy+dify))
end

function ConfigInfo:touchMoved(x, y)
    local oldPoints = self.lastPoints
    self.lastPoints = {x, y}
    local dify = self.lastPoints[2]-oldPoints[2]
    self.accMove = self.accMove+math.abs(dify)
    self:moveBack(dify)
end
function ConfigInfo:touchEnded(x, y)
    local newPos = {x, y}
    if self.accMove < 10 then
        local child = checkInChild(self.flowNode, newPos)
        if child ~= nil then
            print("touch child", child:getTag())
            local t = child:getTag()
            --[[
            if self.data[t][4] == false then
                self.data[t][3]:setVisible(true)
                setPos(self.data[t][2], {28, 21})
                self.data[t][4] = true
            else
                self.data[t][3]:setVisible(false)
                setPos(self.data[t][2], {15, 21})
                self.data[t][4]= false
            end
            --]]
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
