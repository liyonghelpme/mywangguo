NewBuildMenu = class()
function NewBuildMenu:ctor(s)
    self.scene = s
    self.bg = CCNode:create()
    local vs = getVS()
    local temp = display.newScale9Sprite("tabback.jpg")
    temp:setContentSize(CCSizeMake(500, 350))
    self.bg:addChild(temp)
    setPos(temp, {vs.width/2, vs.height/2})

    local but1 = ui.newButton({image="button0.png", conSize={108, 36}, text="环境", callback=self.onEnv, delegate=self})
    but1:setAnchor(0.5, 0.5)
    setPos(but1.bg, {90, fixY(350, 37)})
    temp:addChild(but1.bg)

    local but1 = ui.newButton({image="button0.png", conSize={108, 36}, text="劳动", callback=self.onBuild, delegate=self})
    but1:setAnchor(0.5, 0.5)
    setPos(but1.bg, {250, fixY(350, 37)})
    temp:addChild(but1.bg)

    local but1 = ui.newButton({image="button0.png", conSize={108, 36}, text="店铺", callback=self.onStore, delegate=self})
    but1:setAnchor(0.5, 0.5)
    setPos(but1.bg, {250+160, fixY(350, 37)})
    temp:addChild(but1.bg)


    self.HEIGHT = 270
    self.cl = Scissor:create()
    temp:addChild(self.cl)
    self.cl:setPosition(ccp(0, 10))
    self.cl:setContentSize(CCSizeMake(500, self.HEIGHT))

    self.flowNode = addNode(self.cl)
    setPos(self.flowNode, {0, self.HEIGHT})

    self.touch = ui.newTouchLayer({size={500, self.HEIGHT}, delegate=self, touchBegan=self.touchBegan, touchMoved=self.touchMoved, touchEnded=self.touchEnded})
    temp:addChild(self.touch.bg)
    setPos(self.touch.bg, {0, 0})
    self.data = {}

    self.flowHeight = 0
    print("updateTab .....")
    self:updateTab()
end
function NewBuildMenu:updateTab()
    local initX = 90
    local initY = -69
    local offX = 160
    local offY = 118
    print("updateTab", #Logic.buildList)
    for k, v in ipairs(Logic.buildList) do
        local row = math.floor((k-1)/3)
        local col = (k-1)%3
        local sp = CCSprite:create("tabtab.png")
        self.flowNode:addChild(sp)
        setPos(sp, {initX+col*offX, initY-offY*row})
        print("updateTab", row, col)
        sp:setTag(k)

        local build = CCSprite:create("build"..v.id..".png")
        sp:addChild(build)
        setPos(build, {55, 55})
    end
    local row = math.floor((#Logic.buildList-1)/3)+1
    self.flowHeight = self.flowHeight+offY*row
end

function NewBuildMenu:touchBegan(x, y)
    self.lastPoints = {x, y}
    self.accMove = 0
    self.curSel = nil

end
function NewBuildMenu:moveBack(dify)
    local ox, oy = self.flowNode:getPosition()
    self.flowNode:setPosition(ccp(ox, oy+dify))
end

function NewBuildMenu:touchMoved(x, y)
    local oldPoints = self.lastPoints
    self.lastPoints = {x, y}
    local dify = self.lastPoints[2]-oldPoints[2]
    self.accMove = self.accMove+math.abs(dify)
    self:moveBack(dify)
end
function NewBuildMenu:onHouse()
    self.scene.page:beginBuild('build', self.btype)
end
function NewBuildMenu:touchEnded(x, y)
    local newPos = {x, y}
    if self.accMove < 10 then
        local child = checkInChild(self.flowNode, newPos)
        if child ~= nil then
            print("touch child", child:getTag())
            local t = child:getTag()
            global.director:popView() 
            self.scene.menu:clearMenu()
            self.btype = t            
            if Logic.inNew and not Logic.newBuildYet then
                Logic.newBuildYet = true
                local w = Welcome2.new(self.onHouse, self)
                w:updateWord("请拖拽画面选择建筑场所，点击建筑物可以进行微调。")
                global.director:pushView(w, 1, 0)
                return
            end

            self.scene.page:beginBuild('build', t)
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

    --local rg = self:getShowRange()
    --self:updateTab(rg)
end


function NewBuildMenu:onEnv()

end

function NewBuildMenu:onBuild()
end

function NewBuildMenu:onStore()
end
