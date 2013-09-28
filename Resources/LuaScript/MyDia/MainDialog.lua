require "MyDia.SmallDialog"
local simple = require "dkjson"
MainDialog = class()
function MainDialog:onPVE()
    global.director:pushView(AllLevel.new(self), 1, 0, 1)
end
function MainDialog:onPVP()
    global.director:pushView(AllUser.new(self), 1, 0, 1)
end
function MainDialog:onHero()
    global.director:pushView(AllHeroes.new(self), 1, 0, 1)
end
function MainDialog:onFriend()
end
function MainDialog:onTask()
end
function MainDialog:onLeague()
end
function MainDialog:onTest()
    global.director:pushView(SmallDialog.new(self), 1, 0)
end
function MainDialog:ctor()
    self.INIT_X = 0
    self.INIT_Y = 0
    self.WIDTH = 457
    self.HEIGHT = 70
    self.BACK_HEI = global.director.disSize[2]
    self.INITOFF = self.BACK_HEI-80
    self.content = {{'PVE', self.onPVE}, {'PVP', self.onPVP}, {'英雄', self.onHero}, {'任务', self.onTask}, {'好友', self.onFriend}, {'帮会', self.onLeague}, {'test', self.onTest}}
    self.TabNum = #self.content
    self.data = {}

    self.bg = CCLayer:create()
    self.flowTab = setPos(addNode(self.bg), {20, self.INITOFF})

    self:initTabs()
    
    self.touch = ui.newTouchLayer({size={800, self.BACK_HEI}, delegate=self, touchBegan=self.touchBegan, touchMoved=self.touchMoved, touchEnded=self.touchEnded})

    self.bg:addChild(self.touch.bg)
    self:initLeftTop()
    
    global.httpController:addRequest('getAllHeroData', dict(), self.getAllHeroData, nil, self)
    global.httpController:addRequest('getUserData', dict({{"uid", 1}}), self.getUserData, nil, self)

    --setPos(addSprite(self.bg, "green2.png"), {100, 100})
end
function MainDialog:initLeftTop()
    local vs = getVs() 
    local lt = addNode(self.bg)
    setPos(lt, {vs.width-236, vs.height-33})
    local temp = setPos(setAnchor(addLabel(lt, getStr("level"), "", 18), {0, 0.5}), {0, 0})
    self.level = temp
    temp = setPos(setAnchor(addLabel(lt, getStr("exp"), "", 18), {0, 0.5}), {0, -30})
    self.exp = temp
    temp = setPos(setAnchor(addLabel(lt, getStr("name"), "", 18), {0, 0.5}), {0, -60})
    self.name = temp
    temp = setPos(setAnchor(addLabel(lt, getStr("strength"), "", 18), {0, 0.5}), {0, -90})
    self.strength = temp
    temp = setPos(setAnchor(addLabel(lt, getStr("crystal"), "", 18), {0, 0.5}), {0, -120})
    self.crystal = temp
    temp = setPos(setAnchor(addLabel(lt, getStr("gold"), "", 18), {0, 0.5}), {0, -150})
    self.gold = temp
end
function MainDialog:updateValue()
    self.level:setString("等级:"..Logic.userData.level)
    self.exp:setString("经验:"..Logic.userData.exp)
    self.name:setString("用户名:"..Logic.userData.name)
    self.strength:setString("体力值:"..Logic.userData.strength.."/"..getMaxStrength())
    self.crystal:setString("宝石:"..Logic.userData.crystal)
    self.gold:setString("金币:"..Logic.userData.gold)
end
function MainDialog:getUserData(rep, param)
    Logic.userData = rep.user
    self:updateValue()
end

function MainDialog:getAllHeroData(rep, param)
    --self.allHeroData = {}
    Logic.allHeroData = {}
    for k, v in ipairs(rep['heroData']) do
        Logic.allHeroData[v['id']] = v
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
        local w = setColor(setPos(addLabel(sp, self.content[i][1], "", 33), {sz.width/2, sz.height/2}), {0, 0, 0})
    end
end
function mainScene()
    local scene = CCScene:create()
    --scene:addChild(MainDialog.new().bg)
    local obj = {}
    obj.initYet = false
    function obj:enterScene()
        if not obj.initYet then
            global.director:pushView(MainDialog.new(), 1, 0, 1)
            obj.initYet = true
        end
    end
    function obj:exitScene()
    end
    obj.bg = scene
    obj.dialogController = DialogController.new()
    obj.bg:addChild(obj.dialogController.bg)
    registerEnterOrExit(obj)
    return obj
end
