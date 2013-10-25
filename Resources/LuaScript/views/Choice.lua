Choice = class()
function Choice:ctor(s)
    self.store = s
    self.INIT_X = 33
    self.INIT_Y = 79
    self.WIDTH = 198
    self.HEIGHT = 78
    self.ROW_NUM = 5
    self.BACK_HEI = 385
    self.INITOFF = self.BACK_HEI/2
    self.EXTRA = 5

    self.TabNum = #self.store.allGoods
    self.bg = setContentSize(setPos(CCNode:create(), {self.INIT_X, fixY(nil, self.INIT_Y, self.BACK_HEI)}), {self.WIDTH, self.BACK_HEI})
    self.sci = Scissor:create()
    self.sci:setContentSize(CCSizeMake(self.WIDTH, self.BACK_HEI))
    self.bg:addChild(self.sci)
    
    --bg 的高度
    self.flowTab = setPos(addNode(self.sci), {0, self.INITOFF+self.HEIGHT*2})

    self:initTabs()
    self:getTabs()

    self.touch = ui.newTouchLayer({size={self.WIDTH, self.BACK_HEI}, delegate=self, touchBegan=self.touchBegan, touchMoved=self.touchMoved, touchEnded=self.touchEnded})
    self.bg:addChild(self.touch.bg)
end
function Choice:touchBegan(x, y)
    self.lastPoints = {x, y}
end
function Choice:moveBack(dify)
    local oldPos = getPos(self.flowTab)
    setPos(self.flowTab, {oldPos[1], oldPos[2]+dify})
end
function Choice:touchMoved(x, y)
    local oldPos = self.lastPoints
    self.lastPoints = {x, y}
    local dify = self.lastPoints[2]-oldPos[2]
    self:moveBack(dify)

    local curPos = getPos(self.flowTab)

    local selected = round((curPos[2]-self.INITOFF)/self.HEIGHT)
    selected = math.min(math.max(0, selected), (self.TabNum-1))
    self:setTabs(selected)
end
function Choice:setTabs(sel)
    for i=1, #self.tabArray, 1 do
        if self.tabArray[i][2] == sel then
            local tex = CCTextureCache:sharedTextureCache():addImage("images/greenChoice.png")
            self.tabArray[i][1]:setTexture(tex)
        else
            if self.tabArray[i][2]%2 == 0 then
                local tex = CCTextureCache:sharedTextureCache():addImage("images/whiteChoice.png")
                self.tabArray[i][1]:setTexture(tex)
            else
                local tex = CCTextureCache:sharedTextureCache():addImage("images/yellowChoice.png")
                self.tabArray[i][1]:setTexture(tex)
            end
        end
    end
end
function Choice:touchEnded(x, y)
    local curPos = getPos(self.flowTab)
    local k  = round((curPos[2]-self.INITOFF)/self.HEIGHT)
    k = math.min(math.max(0, k), (self.TabNum-1))
    setPos(self.flowTab, {curPos[1], fixY(self.BACK_HEI, self.INITOFF+self.HEIGHT*-k)})
    self:getTabs()
end
function Choice:initTabs()
    self.tabArray = {}
    for i=1, self.TabNum, 1 do
        --Node ContentSize 
        --Node 的size 和 anchor 对孩子没有用 孩子还是相对于 矩形的 0 0 点位置
        local t = setAnchor(setContentSize(setPos(addNode(self.flowTab), {0, -(i-1)*self.HEIGHT}), {0, 0}), {0, 0})
        local sp = setSize(setAnchor(addSprite(t, "images/whiteChoice.png"), {0, 0.5}), {198, 78})
        table.insert(self.tabArray, {sp, i-1})
        setAnchor(setPos(addSprite(t, 'images/'..self.store.pics[i]), {0, 0}), {0, 0.5})
    end
end
function Choice:getTabs()
    local curPos = getPos(self.flowTab)
    local realInit = fixY(self.BACK_HEI, self.INITOFF)
    local selected = round((curPos[2]-realInit)/self.HEIGHT)
    self:setTabs(selected)
    self.store:setTab(selected)
end
function Choice:changeTab(sel)
    local curPos = getPos(self.flowTab)
    self.flowTab:setPosition(ccp(curPos[1], self.INITOFF+self.HEIGHT*sel))
    print('flowTab pos', self.INITOFF+self.HEIGHT*sel)
    self:getTabs()
end


