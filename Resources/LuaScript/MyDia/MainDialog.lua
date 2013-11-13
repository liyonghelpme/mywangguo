local simple = require "dkjson"
MainDialog = class()
function MainDialog:ctor()
    self.INIT_X = 0
    self.INIT_Y = 0
    self.WIDTH = 457
    self.HEIGHT = 70
    self.BACK_HEI = global.director.disSize[2]
    self.INITOFF = self.BACK_HEI-80
    self.content = {'PVE', 'PVP', '英雄'}
    self.TabNum = #self.content
    self.data = {}

    self.bg = CCLayer:create()
    self.flowTab = setPos(addNode(self.bg), {20, self.INITOFF})

    self:initTabs()
    
    self.touch = ui.newTouchLayer({size={self.WIDTH, self.BACK_HEI}, delegate=self, touchBegan=self.touchBegan, touchMoved=self.touchMoved, touchEnded=self.touchEnded})

    self.bg:addChild(self.touch.bg)
    
    global.httpController:addRequest('getAllHeroData', dict(), self.getAllHeroData, nil, self)

    setPos(addSprite(self.bg, "green2.png"), {100, 100})
end
function MainDialog:getAllHeroData(rep, param)
    self.allHeroData = {}
    for k, v in ipairs(rep['heroData']) do
        self.allHeroData[v['id']] = v
    end
end

function MainDialog:touchBegan(x, y)
    self.accMove = 0
    self.lastPoints = {x, y}
    local child = checkInChild(self.flowTab, self.lastPoints)
    if child ~= nil then
        local sp = self.data[child:getTag()]
        print('touchBegan', sp, sp.setTexture)
        setTexture(sp, 'red.png')
        self.selected = sp
    end
end
function MainDialog:moveBack(dify)
    local oldPos = getPos(self.flowTab)
    setPos(self.flowTab, {oldPos[1], oldPos[2]+dify})
    self.accMove = self.accMove+math.abs(dify)
end
function MainDialog:touchMoved(x, y)
    local oldPos = self.lastPoints
    self.lastPoints = {x, y}
    local dify = self.lastPoints[2]-oldPos[2]
    self:moveBack(dify)
end
function MainDialog:touchEnded(x, y)
    local newPos = {x, y}
    if self.accMove < 10 then
        local child = checkInChild(self.flowTab, newPos)
        if child ~= nil then
            local i = child:getTag()
            print(i)
            if i == 1 then
                global.director:pushView(AllLevel.new(self), 1, 0)
            elseif i == 2 then
                global.director:pushView(AllUser.new(self), 1, 0)
            elseif i == 3 then
                --global.director:replaceScene(heroScene())
                global.director:pushView(AllHeroes.new(self), 1, 0)
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

function MainDialog:initTabs()
    self.tabArray = {}
    for i=1, self.TabNum, 1 do 
        local t = setContentSize(setAnchor(setPos(addNode(self.flowTab), {0, -(i-1)*self.HEIGHT}), {0, 0}), {400, 60})
        local sp = setAnchor(addSprite(t, "green.png"), {0, 0})
        --table.insert(self.tabArray, {sp, i-1})
        t:setTag(i)
        self.data[i] = sp
        --print('gettag', sp:getTag(), t:getChildByTag(2))
        local sz = sp:getContentSize()
        local w = setColor(setPos(addLabel(sp, self.content[i], "", 33), {sz.width/2, sz.height/2}), {0, 0, 0})
    end
end
function mainScene()
    local scene = CCScene:create()
    scene:addChild(MainDialog.new().bg)
    local obj = {}
    obj.bg = scene
    return obj
end
