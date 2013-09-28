local simple = require "dkjson"
Formation = class()
function Formation:goBack()
    global.httpController:addRequest('setFormation', dict({{'uid',1}, {'formation', simple.encode(Logic.formation)}}) )
    global.director:popView()
    return true
end
function Formation:goFight(num, dataNum)
    global.httpController:addRequest('setFormation', dict({{'uid',1}, {'formation', simple.encode(Logic.formation)}}) )

    local ground = BattleGround.new()
    ground:initTest()
    ground:prepareBattle()
    local scene = {bg=CCScene:create()}
    scene.bg:addChild(ground:initView())
    
    CCDirector:sharedDirector():getScheduler():setTimeScale(2)
    global.director:pushScene(scene)
    return false 
end
function Formation:adjustHero()
    return false
end

function Formation:ctor(mainDialog, friendUid, enemyUser)
    self.INIT_X = 0
    self.INIT_Y = 0
    self.WIDTH = 457
    self.HEIGHT = 70
    self.BACK_HEI = global.director.disSize[2]
    self.INITOFF = self.BACK_HEI-80
    self.content = {{'返回', self.goBack}, {'开始战斗', self.goFight}, {'骑士1转1级', self.adjustHero}}
    self.TabNum = #self.content
    self.data = {}
    self.mainDialog = mainDialog
    self.friendUid = friendUid
    self.enemyUser = enemyUser

    self.bg = CCLayer:create()
    self.flowTab = setPos(addNode(self.bg), {20, self.INITOFF})

    self:initTabs()
    
    self.touch = ui.newTouchLayer({size={800, self.BACK_HEI}, delegate=self, touchBegan=self.touchBegan, touchMoved=self.touchMoved, touchEnded=self.touchEnded})

    self.bg:addChild(self.touch.bg)
    self:updateData()
end

function Formation:updateData()
    global.httpController:addRequest('getFormation', dict({{'uid', 1}}), self.getFormation, nil, self)
end
function Formation:getFormation(rep, param)
    Logic.formation = rep['formation']
    Logic.heroes = rep['heroes']
    self.content = {}
    local count = 0
    table.insert(self.content, {'返回', self.goBack})
    table.insert(self.content, {'开始战斗', self.goFight})
    count = #self.content
    for k, v in ipairs(Logic.formation) do
        count = count + 1
        local hdata
        for l, h in ipairs(Logic.heroes) do
            if h['hid'] == v then
                hdata = h
                break
            end
        end
        local name = Logic.allHeroData[hdata['kind']]['name']
        table.insert(self.content, {name..' '..hdata['job']..'转'..' '..hdata['level']..'级', self.adjustHero, count, k})
    end

    self.TabNum = #self.content

    removeSelf(self.flowTab)
    self.flowTab = setPos(addNode(self.bg), {20, self.INITOFF})
    self:initTabs()
end

function Formation:touchBegan(x, y)
    self.accMove = 0
    self.lastPoints = {x, y}

    self.selTag = nil
    local child = checkInChild(self.flowTab, self.lastPoints)
    if child ~= nil then
        local sp = self.data[child:getTag()][1]
        self.backNode = self.data[child:getTag()][2]
        print('touchBegan', sp, sp.setTexture, self.backNode)
        setTexture(sp, 'red.png')
        self.selected = sp
        self.oldPos = getPos(self.backNode)
        adjustZord(self.backNode, 999) 
        self.selTag = child:getTag()
    end
end

function Formation:moveBack(dify)
    local oldPos = getPos(self.flowTab)
    setPos(self.flowTab, {oldPos[1], oldPos[2]+dify})
    self.accMove = self.accMove+math.abs(dify)
end
function Formation:touchMoved(x, y)
    local oldPos = self.lastPoints
    self.lastPoints = {x, y}
    local dify = self.lastPoints[2]-oldPos[2]
    if self.selTag == nil then
        self:moveBack(dify)
    elseif self.selTag ~= nil and self.content[self.selTag][2] == self.adjustHero then
        local curPos = getPos(self.backNode)
        setPos(self.backNode, {curPos[1], curPos[2]+dify})
    end
end

function Formation:touchEnded(x, y)
    local newPos = {x, y}
    if self.selTag ~= nil and self.content[self.selTag][2] == self.adjustHero then
        if self.selected ~= nil then
            self.backNode:retain()
            removeSelf(self.backNode)
            local child = checkInChild(self.flowTab, newPos)
            self.flowTab:addChild(self.backNode)
            self.backNode:release()
            local bt = self.backNode:getTag()
            local ct
            if child ~= nil then
                ct = child:getTag()
            end

            if child ~= nil and ct ~= #self.content and ct ~= #self.content-1 then
                local cp = getPos(child)
                setPos(child, self.oldPos)
                setPos(self.backNode, cp)

                child:setTag(bt)
                self.backNode:setTag(ct)
                local tv = Logic.formation[ct]
                Logic.formation[ct] = Logic.formation[bt]
                Logic.formation[bt] = tv
                local bd = self.data[bt]
                local cd = self.data[ct]

                self.data[ct] = bd
                self.data[bt] = cd
            else
                setPos(self.backNode, self.oldPos)
            end

        end
    else
        local child = checkInChild(self.flowTab, newPos)
        if child ~= nil then
            local i = child:getTag()
            print(i)
            local ret = self.content[i][2](self, self.content[i][3], self.content[i][4])
            if ret then
                return
            end
            --[[
            if i == #self.content-1 then
                global.httpController:addRequest('setFormation', dict({{'uid',1}, {'formation', simple.encode(Logic.formation)}}) )
            elseif i == #self.content then
                global.httpController:addRequest('setFormation', dict({{'uid',1}, {'formation', simple.encode(Logic.formation)}}) )
                global.director:popView()
                return
            end
            --]]
        end
    end

    local curPos = getPos(self.flowTab)
    local k = round((curPos[2]-self.INITOFF)/self.HEIGHT)
    local maxK = math.max(0, math.ceil((self.TabNum*self.HEIGHT-self.BACK_HEI)/self.HEIGHT))
    k = math.min(math.max(0, k), maxK)
    setPos(self.flowTab, {curPos[1], self.INITOFF+self.HEIGHT*k})


    if self.selected ~= nil then
        setTexture(self.selected, 'green.png')
        self.selected = nil
    end
end

function Formation:initTabs()
    self.tabArray = {}
    for i=1, self.TabNum, 1 do 
        local t = setContentSize(setAnchor(setPos(addNode(self.flowTab), {0, -(i-1)*self.HEIGHT}), {0, 0}), {400, 60})
        local sp = setAnchor(addSprite(t, "green.png"), {0, 0})
        --table.insert(self.tabArray, {sp, i-1})
        t:setTag(i)
        self.data[i] = {sp, t}
        local sz = sp:getContentSize()
        local w = setColor(setPos(addLabel(sp, self.content[i][1], "", 33), {sz.width/2, sz.height/2}), {0, 0, 0})
    end
end

