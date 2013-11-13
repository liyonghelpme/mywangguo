local simple = require "dkjson"
AllHeroes = class()
function AllHeroes:ctor(mainDialog)
    self.INIT_X = 0
    self.INIT_Y = 0
    self.WIDTH = 457
    self.HEIGHT = 70
    self.BACK_HEI = global.director.disSize[2]
    self.INITOFF = self.BACK_HEI-80
    self.content = {'骑士1转1级', '牧师3转2级', '牧师3转3级', '更新', '返回'}
    self.TabNum = #self.content
    self.data = {}
    self.mainDialog = mainDialog

    self.bg = CCLayer:create()
    self.flowTab = setPos(addNode(self.bg), {20, self.INITOFF})

    self:initTabs()
    
    self.touch = ui.newTouchLayer({size={self.WIDTH, self.BACK_HEI}, delegate=self, touchBegan=self.touchBegan, touchMoved=self.touchMoved, touchEnded=self.touchEnded})

    self.bg:addChild(self.touch.bg)

    global.httpController:addRequest('getAllHero', dict(), self.getAllHero, nil, self)
end
function AllHeroes:getAllHero(rep, param)
    self.heroes = rep['heroes']
    self.formation = rep['formation']
    self.temp = {}
    for k, v in ipairs(self.formation) do
        self.temp[v] = true
    end
    self.content = {}
    for k, v in ipairs(rep['heroes']) do
        local name = self.mainDialog.allHeroData[v['kind']]['name']
        if self.temp[v['hid']] ~= nil then
            v['out'] = true
            table.insert(self.content, name..v['job']..'转'..v['level']..'级 出战')
        else
            v['out'] = false
            table.insert(self.content, name..v['job']..'转'..v['level']..'级 ')
        end
    end
    table.insert(self.content, '更新')
    table.insert(self.content, '返回')
    self.TabNum = #self.content

    removeSelf(self.flowTab)
    self.flowTab = setPos(addNode(self.bg), {20, self.INITOFF})
    self:initTabs()

end
function AllHeroes:touchBegan(x, y)
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

function AllHeroes:moveBack(dify)
    local oldPos = getPos(self.flowTab)
    setPos(self.flowTab, {oldPos[1], oldPos[2]+dify})
    self.accMove = self.accMove+math.abs(dify)
end
function AllHeroes:touchMoved(x, y)
    local oldPos = self.lastPoints
    self.lastPoints = {x, y}
    local dify = self.lastPoints[2]-oldPos[2]
    self:moveBack(dify)
end

function AllHeroes:getOutSoldier()
    local temp = {}
    for k, v in ipairs(self.heroes) do
        if v['out'] then
            table.insert(temp, v['hid'])
        end
    end
    return temp
end
function AllHeroes:touchEnded(x, y)
    local newPos = {x, y}
    if self.accMove < 10 then
        local child = checkInChild(self.flowTab, newPos)
        if child ~= nil then
            local i = child:getTag()
            print(i)
            if i == #self.content-1 then
                global.httpController:addRequest('getAllHero', dict(), self.getAllHero, nil, self)
            elseif i == #self.content then
                global.httpController:addRequest('setFormation', dict({{'uid',1}, {'formation', simple.encode(self:getOutSoldier())}}))
                global.director:popView()
                return
            else
                if self.heroes[i]['out'] then
                    self.heroes[i]['out'] = false
                    local w = self.data[i][2]
                    local os = w:getString()
                    w:setString(string.sub(os, 1, -7))
                else
                    self.heroes[i]['out'] = true
                    local w = self.data[i][2]
                    local os = w:getString()
                    w:setString(os..'出战')
                end
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

function AllHeroes:initTabs()
    self.tabArray = {}
    for i=1, self.TabNum, 1 do 
        local t = setContentSize(setAnchor(setPos(addNode(self.flowTab), {0, -(i-1)*self.HEIGHT}), {0, 0}), {400, 60})
        local sp = setAnchor(addSprite(t, "green.png"), {0, 0})
        --table.insert(self.tabArray, {sp, i-1})
        t:setTag(i)
        local sz = sp:getContentSize()
        local w = setColor(setPos(addLabel(sp, self.content[i], "", 33), {sz.width/2, sz.height/2}), {0, 0, 0})
        self.data[i] = {sp, w}
    end
end
function heroScene()
    local scene = CCScene:create()
    scene:addChild(AllHeroes.new().bg)
    local obj = {}
    obj.bg = scene
    return obj
end
