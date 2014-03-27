AllFriend = class()
function AllFriend:ctor(mainDialog, enemyUser)
    self.INIT_X = 0
    self.INIT_Y = 0
    self.WIDTH = 457
    self.HEIGHT = 70
    self.BACK_HEI = global.director.disSize[2]
    self.INITOFF = self.BACK_HEI-80
    self.content = {'好友英雄 骑士1转1级', '好友英雄 牧师3转2级', '好友英雄 牧师3转2级', '返回'}
    self.TabNum = #self.content
    self.data = {}
    self.mainDialog = mainDialog
    self.enemyUser = enemyUser

    self.bg = CCLayer:create()
    self.flowTab = setPos(addNode(self.bg), {20, self.INITOFF})

    self:initTabs()
    
    self.touch = ui.newTouchLayer({size={self.WIDTH, self.BACK_HEI}, delegate=self, touchBegan=self.touchBegan, touchMoved=self.touchMoved, touchEnded=self.touchEnded})

    self.bg:addChild(self.touch.bg)
    self:updateData()
end

function AllFriend:updateData()
    global.httpController:addRequest('getAllFriend', dict(), self.getAllFriend, nil, self)
end
function AllFriend:getAllFriend(rep, param)
    self.allFriend = rep['friend']
    self.content = {}
    for k, v in ipairs(self.allFriend) do
        local leader = v['formation'][1]
        local heroData = v['heroData']
        local ch
        for l, h in ipairs(heroData) do
            if h['hid'] == leader then
                ch = h
                break
            end
        end
        local name = self.mainDialog.allHeroData[ch['kind']]['name']
        table.insert(self.content, '好友英雄 '..name..' '..ch['job']..'转'..' '..ch['level']..'级')
    end
    table.insert(self.content, '返回')
    self.TabNum = #self.content

    removeSelf(self.flowTab)
    self.flowTab = setPos(addNode(self.bg), {20, self.INITOFF})
    self:initTabs()
end

function AllFriend:touchBegan(x, y)
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

function AllFriend:moveBack(dify)
    local oldPos = getPos(self.flowTab)
    setPos(self.flowTab, {oldPos[1], oldPos[2]+dify})
    self.accMove = self.accMove+math.abs(dify)
end
function AllFriend:touchMoved(x, y)
    local oldPos = self.lastPoints
    self.lastPoints = {x, y}
    local dify = self.lastPoints[2]-oldPos[2]
    self:moveBack(dify)
end

function AllFriend:touchEnded(x, y)
    local newPos = {x, y}
    if self.accMove < 10 then
        local child = checkInChild(self.flowTab, newPos)
        if child ~= nil then
            local i = child:getTag()
            print(i)
            if i == #self.content then
                global.director:popView()
                return
            else
                global.director:pushView(Formation.new(self.mainDialog, self.allFriend[i]['uid'], self.enemyUser), 1, 0)
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

function AllFriend:initTabs()
    self.tabArray = {}
    for i=1, self.TabNum, 1 do 
        local t = setContentSize(setAnchor(setPos(addNode(self.flowTab), {0, -(i-1)*self.HEIGHT}), {0, 0}), {400, 60})
        local sp = setAnchor(addSprite(t, "green.png"), {0, 0})
        --table.insert(self.tabArray, {sp, i-1})
        t:setTag(i)
        self.data[i] = sp
        local sz = sp:getContentSize()
        local w = setColor(setPos(addLabel(sp, self.content[i], "", 33), {sz.width/2, sz.height/2}), {0, 0, 0})
    end
end

