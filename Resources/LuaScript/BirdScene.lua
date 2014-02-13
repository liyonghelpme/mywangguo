require "BirdUtil"
require "Bird"
require "BirdMenu"
require "RunMenu"
require "OverMenu"

SCENE_STATE = {
    WAIT_START=0,
    FREE = 1,
    RUN = 2,
    OVER = 3,
}
BirdScene = class()
function BirdScene:ctor()
    self.score = 0
    local vs = getVS()
    local size = {width=768, height=1024}
    local sca = vs.height/size.height

    self.bg = CCScene:create()
    self.dialogController = DialogController.new(self)
    self.bg:addChild(self.dialogController.bg)

    setPos(self.bg, {0, 0})
    local far = createSprite("far.png")
    addChild(self.bg, far)
    setPos(setAnchor(far, {0, 0}), {0, 0})
    setScale(far, sca)

    local far2 = createSprite("far.png")
    addChild(self.bg, far2)
    setPos(setAnchor(far2, {0, 0}), {768*sca, 0})
    setScale(far2, sca)

    local far3 = createSprite("far.png")
    addChild(self.bg, far3)
    setPos(setAnchor(far3, {0, 0}), {1536*sca, 0})
    setScale(far3, sca)

    --远景调整占满屏幕 高度

    local mid = CCNode:create()
    local f1 = createSprite("mid.png")
    setAnchor(setPos(f1, {0, 0}), {0, 0})
    local f2 = createSprite("mid.png")
    setAnchor(setPos(f2, {768, 0}), {0, 0})
    local f3 = createSprite("mid.png")
    setAnchor(setPos(f3, {1536, 0}), {0, 0})

    addChild(mid, f1)
    addChild(mid, f2)
    addChild(mid, f3)
    addChild(self.bg, mid)
    self.m1 = f1
    self.m2 = f2
    self.m3 = f3
    self.mid = mid
    
    self.state = SCENE_STATE.WAIT_START

    local pipNode = CCNode:create()
    addChild(self.bg, pipNode)
    self.pipNode = pipNode

    self.pipe = {}
    self.freePipe = {}

    --local far1 = createSprite()
    local near = CCNode:create()
    local n1 = createSprite("near.png")
    setAnchor(setPos(n1, {0, 0}), {0, 0})
    local n2 = createSprite("near.png")
    setAnchor(setPos(n2, {768, 0}), {0, 0})
    local n3 = createSprite("near.png")
    setAnchor(setPos(n3, {1536, 0}), {0, 0})
    addChild(near, n1)
    addChild(near, n2)
    addChild(near, n3)
    addChild(self.bg, near)
    self.near = near
    self.n1 = n1
    self.n2 = n2
    self.n3 = n3

    --self.bird = Bird.new(self)
    --addChild(self.bg, self.bird.bg)
    --setVisible(self.bird.bg, false)

    self.speed = 200
    self.lastPos = 1000

    --self.bg:addChild(createSprite("greenbirds1.png"))

    
    --self.menu = BirdMenu.new(s)
    --self.bg:addChild(self.menu.bg)

    self.needUpdate = true
    registerUpdate(self)
end
function BirdScene:resetScene()
    self.score = 0
    removeSelf(self.mid)
    removeSelf(self.pipNode)
    removeSelf(self.near)
    removeSelf(self.bird.bg)


    local mid = CCNode:create()
    local f1 = createSprite("mid.png")
    setAnchor(setPos(f1, {0, 0}), {0, 0})
    local f2 = createSprite("mid.png")
    setAnchor(setPos(f2, {768, 0}), {0, 0})
    local f3 = createSprite("mid.png")
    setAnchor(setPos(f3, {1536, 0}), {0, 0})

    addChild(mid, f1)
    addChild(mid, f2)
    addChild(mid, f3)
    addChild(self.bg, mid)
    self.m1 = f1
    self.m2 = f2
    self.m3 = f3
    self.mid = mid

    local pipNode = CCNode:create()
    addChild(self.bg, pipNode)
    self.pipNode = pipNode
    
    for k, v in ipairs(self.pipe) do
        table.insert(self.freePipe, v)
    end
    self.pipe = {}

    local near = CCNode:create()
    local n1 = createSprite("near.png")
    setAnchor(setPos(n1, {0, 0}), {0, 0})
    local n2 = createSprite("near.png")
    setAnchor(setPos(n2, {768, 0}), {0, 0})
    local n3 = createSprite("near.png")
    setAnchor(setPos(n3, {1536, 0}), {0, 0})
    addChild(near, n1)
    addChild(near, n2)
    addChild(near, n3)
    addChild(self.bg, near)
    self.near = near
    self.n1 = n1
    self.n2 = n2
    self.n3 = n3

end
function BirdScene:startGame()
    self.state = SCENE_STATE.FREE
    self.bird = Bird.new(self)
    addChild(self.bg, self.bird.bg)
    --setVisible(self.bird.bg, false)
    --setVisible(self.bird.bg, true)

    self.runMenu = RunMenu.new(s)
    global.director:pushView(self.runMenu)
    self.runMenu:adjustScore(self.score)
end

function BirdScene:update(diff)
    if self.state == SCENE_STATE.WAIT_START then
        self:adjustScene(diff)
        if not self.showMenu then
            self.showMenu = true
            global.director:pushView(BirdMenu.new(self), 1, 0)
        end
    elseif self.state == SCENE_STATE.FREE then
        --self.state = SCENE_STATE.RUN
        self:adjustScene(diff)
    elseif self.state == SCENE_STATE.RUN then
        self:generatePipe()
        if self.bird.state ~= BIRD_STATE.DEAD then
            self:adjustScene(diff)
        else
            global.director:popView()
            global.director:pushView(OverMenu.new(self), 1)
            self.state = BIRD_STATE.OVER
        end
    elseif self.state == SCENE_STATE.OVER then
        --self:adjustScene(diff)
    end
end

--循环图
function BirdScene:adjustScene(diff)
    local mx = -self.speed*diff
    local p = getPos(self.near)
    p[1] = p[1]+mx
    setPos(self.near, p)
    setPos(self.pipNode, p)
    
    setPos(self.mid, {p[1]*0.5, p[2]})
    
    local n1p = getPos(self.n1)
    local n2p = getPos(self.n2)
    local n3p = getPos(self.n3)
    if n1p[1]+p[1]+768 < 0 then
        setPos(self.n1, {n3p[1]+768, 0})
        self.n1, self.n2, self.n3 = self.n2, self.n3, self.n1
    end

    local midp = getPos(self.mid)
    local m1p = getPos(self.m1)
    local m2p = getPos(self.m2)
    local m3p = getPos(self.m3)
    if midp[1]+m1p[1]+768 < 0 then
        setPos(self.m1, {m3p[1]+768, 0})
        self.m1, self.m2, self.m3 = self.m2, self.m3, self.m1
    end
end

function BirdScene:generatePipe()
    --生成4列管道 在某个位置
    if #self.pipe == 0 then
        local p = getPos(self.pipNode)
        self.lastPos = -p[1]+1000
    end
    local pipPos = getPos(self.pipNode)
    local vs = getVS()
    local oldScore = self.score
    for k, v in ipairs(self.pipe) do
        if not v[3] then
            local p = getPos(v[1])
            if pipPos[1]+p[1] <= vs.width/2 then
                v[3] = true
                self.score = self.score+1
            else
                break
            end
        end
    end
    if oldScore ~= self.score then
        self.runMenu:adjustScore(self.score)
    end

    if #self.pipe < 5 then
        --local p = getPos(self.near)
        --local vs = getVS()
        --开始出现管道
        --if p[1] > 1000 then
        local p1, p2
        if #self.freePipe > 0 then
            local allP = table.remove(self.freePipe)
            p1 = allP[1]
            p2 = allP[2]
        else
            p1 = createSprite("bar.png")
            p1:retain()
            p2 = createSprite("bar.png")
            p2:retain()
        end
        local sz = p1:getContentSize()
        print("insert pipe")
        local rdLevel
        local vs = getVS()
        --下面管道的高度范围
        local height = math.random(vs.height-330-172)+172
        print("height is what?", height)

        --local h1 = vs.height/2-132-sz.height
        local h1 = height-sz.height
        --local h2 = vs.height/2+132+sz.height
        local h2 = height+258+sz.height
        setAnchor(setPos(p1, {self.lastPos, h1}), {0.5, 0})
        setAnchor(setPos(p2, {self.lastPos, h2}), {0.5, 0})
        setScaleY(p2, -1)

        addChild(self.pipNode, p1)
        addChild(self.pipNode, p2)
        --是否 计分过
        table.insert(self.pipe, {p1, p2, false})
        self.lastPos = self.lastPos+432
        --end
    else
        print(#self.pipe)
        local pos = getPos(self.pipe[1][1])
        local bp = getPos(self.pipNode)
        --print("remove old pipe", bp[1]+pos[1])
        if bp[1]+pos[1] < -100 then
            local allP = table.remove(self.pipe, 1)
            --p:retain()
            removeSelf(allP[1])
            removeSelf(allP[2])
            table.insert(self.freePipe, allP)
        end
    end
end
--发一下 白色 接着 出现 GameOver 的界面 
function BirdScene:shakeNow()
    local function shakeOver()
        self.shakeOver = true
    end

    self.bg:runAction(sequence({repeatN(sequence({moveby(0.05, -10, 0), moveby(0.05, 10, 0)}), 4)}, callfunc(nil, shakeOver)))
end
