local simple = require "dkjson"
AllFight = class()

function AllFight:goBack()
    Logic.formation = self:getOutSoldier()
    global.httpController:addRequest('setFormation', dict({{'uid',1}, {'formation', simple.encode(Logic.formation)}}))
    global.director:popView()
    Event:sendMsg(EVENT_TYPE.UPDATE_HERO)
    return true
end
function AllFight:cancel()
    global.director:popView()
    return true
end
function AllFight:chooseHero(i, dataNum)
    print("chooseHero", i)
    if Logic.heroes[i]['out'] then
        Logic.heroes[i]['out'] = false
        local w = self.data[dataNum][2]
        local os = w:getString()
        w:setString(string.sub(os, 1, -7))
    else
        local count =0 
        for k, v in ipairs(Logic.heroes) do
            if v['out'] then
                count = count+1
            end
        end
        if count >= 5 then
            showDialog("出战士兵不能超过5个")
        else
            Logic.heroes[i]['out'] = true
            local w = self.data[dataNum][2]
            local os = w:getString()
            w:setString(os..'出战')
        end
    end
    return false
end

function AllFight:ctor(mainDialog)
    self.INIT_X = 0
    self.INIT_Y = 0
    self.WIDTH = 457
    self.HEIGHT = 70
    self.BACK_HEI = global.director.disSize[2]
    self.INITOFF = self.BACK_HEI-80
    self.content = {{'确定', self.goBack}, {'取消', self.cancel}}
    self.TabNum = #self.content
    self.data = {}
    self.mainDialog = mainDialog

    self.bg = CCLayer:create()
    self.flowTab = setPos(addNode(self.bg), {20, self.INITOFF})

    self:initTabs()
    
    self.touch = ui.newTouchLayer({size={self.WIDTH, self.BACK_HEI}, delegate=self, touchBegan=self.touchBegan, touchMoved=self.touchMoved, touchEnded=self.touchEnded})

    self.bg:addChild(self.touch.bg)

    --global.httpController:addRequest('getAllHero', dict(), self.getAllHero, nil, self)
    self:getAllHero()
end
function AllFight:getAllHero()
    --self.formation = rep['formation']
    self.temp = {}
    for k, v in ipairs(Logic.formation) do
        self.temp[v] = true
    end
    self.content = {}
    local count = 0
    table.insert(self.content, {'确定', self.goBack})
    table.insert(self.content, {'取消', self.cancel})
    count = #self.content
    for k, v in ipairs(Logic.heroes) do
        count = count+1
        local name = Logic.allHeroData[v['kind']]['name']
        if self.temp[v['hid']] ~= nil then
            v['out'] = true
            table.insert(self.content, {name..v['job']..'转'..v['level']..'级 出战', self.chooseHero, k, count})
        else
            v['out'] = false
            table.insert(self.content, {name..v['job']..'转'..v['level']..'级 ', self.chooseHero, k, count})
        end
    end

    self.TabNum = #self.content

    removeSelf(self.flowTab)
    self.flowTab = setPos(addNode(self.bg), {20, self.INITOFF})
    self:initTabs()

end
function AllFight:touchBegan(x, y)
    self.accMove = 0
    self.lastPoints = {x, y}

    local child = checkInChild(self.flowTab, self.lastPoints)
    if child ~= nil then
        local sp = self.data[child:getTag()][1]
        print('touchBegan', sp, sp.setTexture)
        setTexture(sp, 'red.png')
        self.selected = sp
    end
end

function AllFight:moveBack(dify)
    local oldPos = getPos(self.flowTab)
    setPos(self.flowTab, {oldPos[1], oldPos[2]+dify})
    self.accMove = self.accMove+math.abs(dify)
end
function AllFight:touchMoved(x, y)
    local oldPos = self.lastPoints
    self.lastPoints = {x, y}
    local dify = self.lastPoints[2]-oldPos[2]
    self:moveBack(dify)
end
--最终还是根据formation 来确定哪些士兵出战哪些没有
function AllFight:getOutSoldier()
    local temp = {}
    for k, v in ipairs(Logic.heroes) do
        if v['out'] then
            table.insert(temp, v['hid'])
        end
    end
    return temp
end
function AllFight:touchEnded(x, y)
    local newPos = {x, y}
    if self.accMove < 10 then
        local child = checkInChild(self.flowTab, newPos)
        if child ~= nil then
            local i = child:getTag()
            print(i)
            --if i == 0 then
            local ret = self.content[i][2](self, self.content[i][3], self.content[i][4])
            if ret then
                return
            end
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

function AllFight:initTabs()
    self.tabArray = {}
    for i=1, self.TabNum, 1 do 
        local t = setContentSize(setAnchor(setPos(addNode(self.flowTab), {0, -(i-1)*self.HEIGHT}), {0, 0}), {400, 60})
        local sp = setAnchor(addSprite(t, "green.png"), {0, 0})
        --table.insert(self.tabArray, {sp, i-1})
        t:setTag(i)
        local sz = sp:getContentSize()
        local w = setColor(setPos(addLabel(sp, self.content[i][1], "", 33), {sz.width/2, sz.height/2}), {0, 0, 0})
        self.data[i] = {sp, w}
    end
end
