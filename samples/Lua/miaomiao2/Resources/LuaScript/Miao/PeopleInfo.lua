PeopleInfo = class()
--增加一个flowNode 的模板
function PeopleInfo:ctor(s)
    self.scene = s
    local vs = getVS()

    self.bg = CCNode:create()
    local temp = display.newScale9Sprite("tabback.jpg")
    temp:setContentSize(CCSizeMake(526, 370))
    self.bg:addChild(temp)
    setPos(temp, {vs.width/2, vs.height/2})

    local tit = setPos(addSprite(temp, "title.png"), {263, fixY(370, 31)})
    local w = ui.newTTFLabel({text="合战部队的编成", font="msyhbd.ttf", size=15, color={0,0,0}})
    temp:addChild(w)
    setAnchor(setPos(w, {263, fixY(370, 31)}), {0.5, 0.5})

    local lv = ui.newBMFontLabel({text="Lv", font="bound.fnt", size=20, color={0,0,0}})
    temp:addChild(lv)
    setAnchor(setPos(lv, {74, fixY(370, 63)}), {0.5, 0.5})
    
    local wl = ui.newTTFLabel({text="配置于", font="msyhbd.ttf", size=15, color={0,0,0}})
    temp:addChild(wl)
    setAnchor(setPos(wl, {297, fixY(370, 63)}), {0.5, 0.5})

    local wl = ui.newTTFLabel({text="费用", font="msyhbd.ttf", size=15, color={0,0,0}})
    temp:addChild(wl)
    setAnchor(setPos(wl, {297, fixY(451, 63)}), {0.5, 0.5})


    self.HEIGHT = 221

    self.touch = ui.newTouchLayer({size={500, self.HEIGHT}, delegate=self, touchBegan=self.touchBegan, touchMoved=self.touchMoved, touchEnded=self.touchEnded})
    temp:addChild(self.touch.bg)
    setPos(self.touch.bg, {27, fixY(370, 296)})

    self.cl = Scissor:create()
    temp:addChild(self.cl)
    setContentSize(setPos(self.cl, {27, fixY(370, 296)}), {485, self.HEIGHT})
    self.flowNode = setPos(addNode(self.cl), {0, self.HEIGHT})
    
    self:updateTab()
    local num = setPos(addChild(temp, ui.newTTFLabel({text="计", size=15, color={10, 76, 186}})), {41, fixY(370, 312)})

    local num = setAnchor(setPos(addChild(temp, ui.newTTFLabel({text="4 / 4 人", size=15, color={10, 10, 10}})), {124, fixY(370, 312)}), {1, 0.5})

    local num = setAnchor(setPos(addChild(temp, ui.newTTFLabel({text="435贯", size=15, color={10, 10, 10}})), {481, fixY(370, 312)}), {1, 0.5})

    local num = setAnchor(setPos(addChild(temp, ui.newTTFLabel({text="请选择要参加的人", size=15, color={10, 76, 176}})), {263, fixY(370, 350)}), {0.5, 0.5})
end
function PeopleInfo:updateTab()
    self.flowHeight = 0
    local offY = 43
    local n = 1
    local tall = {1, 1, 1, 1}
    self.data = {}
    for k, v in ipairs(tall) do
        local panel = CCNode:create()
        self.flowNode:addChild(panel)
        setContentSize(setPos(panel, {0, -offY*n}), {485, 49})
        panel:setTag(k)

        local temp = CCSprite:create("psel.png")
        panel:addChild(temp)
        setPos(setSize(temp, {420, 27}), {485/2, 21})
        
        --28 21
        local head = setSize(setPos(addSprite(panel, "king1.png"), {15, 21}), {30, 30})
        local att = setPos(addChild(panel, ui.newTTFLabel({text="参", size=15, color={0, 0, 0}})), {7, 21})
        setVisible(att, false)

        local lev = ui.newBMFontLabel({text="16", font="bound.fnt", size=18, color={0,0,0}})

        setPos(lev, {56, 21})
        panel:addChild(lev)
        
        local name = ui.newTTFLabel({text="小明", size=18, font="msyhbd.ttf", color={0,0,0}})
        setPos(name, {114, 21})
        panel:addChild(name)

        local physic = ui.newTTFLabel({text="步卒", size=18, font="bound.fnt", color={0,0,0}})
        setAnchor(setPos(physic, {276, 21}), {1, 0.5})
        panel:addChild(physic)
        
        local physic = ui.newTTFLabel({text="80贯", size=18, font="bound.fnt", color={0,0,0}})
        setAnchor(setPos(physic, {437, 21}), {1, 0.5})
        panel:addChild(physic)

        table.insert(self.data, {panel, head, att, false})

        self.flowHeight = self.flowHeight+offY
        n = n + 1
    end
end
function PeopleInfo:onClose()
    local fin = FightInfo.new()
    global.director.curScene.menu.menu = fin
    global.director:pushView(fin)
end

function PeopleInfo:touchBegan(x, y)
    self.lastPoints = {x, y}
    self.accMove = 0
    self.curSel = nil

end
function PeopleInfo:moveBack(dify)
    local ox, oy = self.flowNode:getPosition()
    self.flowNode:setPosition(ccp(ox, oy+dify))
end

function PeopleInfo:touchMoved(x, y)
    local oldPoints = self.lastPoints
    self.lastPoints = {x, y}
    local dify = self.lastPoints[2]-oldPoints[2]
    self.accMove = self.accMove+math.abs(dify)
    self:moveBack(dify)
end
function PeopleInfo:touchEnded(x, y)
    local newPos = {x, y}
    if self.accMove < 10 then
        local child = checkInChild(self.flowNode, newPos)
        if child ~= nil then
            print("touch child", child:getTag())
            local t = child:getTag()
            if self.data[t][4] == false then
                self.data[t][3]:setVisible(true)
                setPos(self.data[t][2], {28, 21})
                self.data[t][4] = true
            else
                self.data[t][3]:setVisible(false)
                setPos(self.data[t][2], {15, 21})
                self.data[t][4]= false
            end
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
