local simple = require "dkjson"
Store = class()

function Store:goBack()
    Event:sendMsg(EVENT_TYPE.UPDATE_HERO)
    global.director:popView()
    return true
end
function Store:buySuc()
end
function Store:goBuy()
    local buysol = self:getOutSoldier()
    addReq("buyHero", dict({{"uid", 1}, {"hids", simple.encode(buysol)}}), self.buySuc, nil, self) 
    for k, v in ipairs(buysol) do
        table.insert(Logic.heroes, dict({{"hid", v[2]}, {"kind", v[1]}, {"level", 0}, {"job", 0}}))
    end
    return false
end
function Store:chooseHero(i, dataNum)
    print("chooseHero", i)
    if Logic.allHeroData[i]['buy'] then
        Logic.allHeroData[i]['buy'] = false
        local w = self.data[dataNum][2]
        local os = w:getString()
        w:setString(string.sub(os, 1, -7))
    else
        Logic.allHeroData[i]['buy'] = true
        local w = self.data[dataNum][2]
        local os = w:getString()
        w:setString(os..'购买')
    end
    return false
end

function Store:ctor(mainDialog)
    self.INIT_X = 0
    self.INIT_Y = 0
    self.WIDTH = 457
    self.HEIGHT = 70
    self.BACK_HEI = global.director.disSize[2]
    self.INITOFF = self.BACK_HEI-80
    self.content = {{'返回', self.goBack}, {'购买', self.goBuy}, {'骑士1转1级', self.chooseHero}, {'牧师3转2级', self.chooseHero}, {'牧师3转3级', self.chooseHero}}
    self.TabNum = #self.content
    self.data = {}
    self.mainDialog = mainDialog

    self.bg = CCLayer:create()
    self.flowTab = setPos(addNode(self.bg), {20, self.INITOFF})

    self:initTabs()
    --可以扩展协议 将checkIn 也参数化 
    self.touch = ui.newTouchLayer({size={self.WIDTH, self.BACK_HEI}, delegate=self, touchBegan=self.touchBegan, touchMoved=self.touchMoved, touchEnded=self.touchEnded})

    self.bg:addChild(self.touch.bg)

    self:initStore()
end
--refresh heroState
function Store:initStore()
    self.content = {}
    local count = 0
    table.insert(self.content, {"返回", self.goBack})
    table.insert(self.content, {"购买", self.goBuy})
    count = #self.content
    for k, v in pairs(Logic.allHeroData) do
        count = count+1
        local name = v['name']
        table.insert(self.content, {name, self.chooseHero, k, count})
    end
    self.TabNum = #self.content
    removeSelf(self.flowTab)
    self.flowTab = setPos(addNode(self.bg), {20, self.INITOFF})
    self:initTabs()
end

function Store:touchBegan(x, y)
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

function Store:moveBack(dify)
    local oldPos = getPos(self.flowTab)
    setPos(self.flowTab, {oldPos[1], oldPos[2]+dify})
    self.accMove = self.accMove+math.abs(dify)
end
function Store:touchMoved(x, y)
    local oldPos = self.lastPoints
    self.lastPoints = {x, y}
    local dify = self.lastPoints[2]-oldPos[2]
    self:moveBack(dify)
end

function Store:getOutSoldier()
    local temp = {}
    for k, v in ipairs(Logic.allHeroData) do
        if v['buy'] then
            table.insert(temp, {v['id'], getMaxHid()})
        end
    end
    return temp
end
function Store:touchEnded(x, y)
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

function Store:initTabs()
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
