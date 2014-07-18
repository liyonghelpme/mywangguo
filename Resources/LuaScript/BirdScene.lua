require "Logic"
require "model.Music"
require "BirdUtil"
require "Bird"
require "BirdMenu"
require "RunMenu"
require "OverMenu"
require "Ready"

SCENE_STATE = {
    WAIT_START=0,
    FREE = 1,
    RUN = 2,
    OVER = 3,
}
BirdScene = class()
function BirdScene:initStar()
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.starNode, "star.png"), {298, fixY(self.sz.height, 66)}), {64, 64}), {0.50, 0.50}), 255)
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.starNode, "star.png"), {418, fixY(self.sz.height, 144)}), {64, 64}), {0.50, 0.50}), 255)
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.starNode, "star.png"), {522, fixY(self.sz.height, 300)}), {64, 64}), {0.50, 0.50}), 255)
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.starNode, "star.png"), {668, fixY(self.sz.height, 184)}), {64, 64}), {0.50, 0.50}), 255)
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.starNode, "star.png"), {360, fixY(self.sz.height, 286)}), {64, 64}), {0.50, 0.50}), 255)
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.starNode, "star.png"), {248, fixY(self.sz.height, 202)}), {64, 64}), {0.50, 0.50}), 255)
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.starNode, "star.png"), {108, fixY(self.sz.height, 260)}), {64, 64}), {0.50, 0.50}), 255)
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.starNode, "star.png"), {100, fixY(self.sz.height, 136)}), {64, 64}), {0.50, 0.50}), 255)
    centerTop(self.starNode)

    local sub = self.starNode:getChildren()
    local count = self.starNode:getChildrenCount()
    for i=0, count-1, 1 do
        local child = tolua.cast(sub:objectAtIndex(i), 'CCNode')
        local p = getPos(child)
        local startP = math.sin(p[1]*50)+1
        local function doFade()
            child:runAction(repeatForever(sinein(sequence({fadeout(1), fadein(1)}))))
        end
        child:runAction(sequence({delaytime(startP), callfunc(nil, doFade)}))
        if i%2 == 0 then
            setScale(child, 0.5)
        end
    end
end
function BirdScene:initFlash()
    local sp = setScale(setOpacity(setAnchor(setSize(setPos(addSprite(self.flashNode, "flash.png"), {71, fixY(self.sz.height, 836)}), {32, 32}), {0.50, 0.50}), 255), 0.5)
    local sp = setScale(setOpacity(setAnchor(setSize(setPos(addSprite(self.flashNode, "flash.png"), {187, fixY(self.sz.height, 850)}), {32, 32}), {0.50, 0.50}), 255), 0.5)
    local sp = setScale(setOpacity(setAnchor(setSize(setPos(addSprite(self.flashNode, "flash.png"), {219, fixY(self.sz.height, 826)}), {32, 32}), {0.50, 0.50}), 255), 1)
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.flashNode, "flash.png"), {553, fixY(self.sz.height, 855)}), {32, 32}), {0.50, 0.50}), 255)
    local sp = setScale(setOpacity(setAnchor(setSize(setPos(addSprite(self.flashNode, "flash.png"), {607, fixY(self.sz.height, 859)}), {32, 32}), {0.50, 0.50}), 255), 0.5)
    local sp = setScale(setOpacity(setAnchor(setSize(setPos(addSprite(self.flashNode, "flash.png"), {642, fixY(self.sz.height, 870)}), {32, 32}), {0.50, 0.50}), 255), 0.5)
    local sp = setScale(setOpacity(setAnchor(setSize(setPos(addSprite(self.flashNode, "flash.png"), {656, fixY(self.sz.height, 822)}), {32, 32}), {0.50, 0.50}), 255), 0.5)
    local sp = setScale(setOpacity(setAnchor(setSize(setPos(addSprite(self.flashNode, "flash.png"), {655, fixY(self.sz.height, 856)}), {32, 32}), {0.50, 0.50}), 255), 0.5)
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.flashNode, "flash.png"), {688, fixY(self.sz.height, 839)}), {32, 32}), {0.50, 0.50}), 255)
    local sp = setScale(setOpacity(setAnchor(setSize(setPos(addSprite(self.flashNode, "flash.png"), {739, fixY(self.sz.height, 882)}), {32, 32}), {0.50, 0.50}), 255), 0.5)
    centerBottom(self.flashNode)
    local sub = self.flashNode:getChildren()
    local count = self.flashNode:getChildrenCount()
    for i=0, count-1, 1 do
        local child = tolua.cast(sub:objectAtIndex(i), 'CCNode')
        local p = getPos(child)
        local startP = math.sin(p[1]*50)+1
        local function doFade()
            local function rmv()
                local dir = math.random(2)
                if dir == 2 then
                    dir = -1
                end
                local mx = (math.random(10)+10)*dir
                local dir = math.random(2)
                if dir == 2 then
                    dir = -1
                end
                local my = (math.random(10)+10)*dir
                child:runAction(sinein(sequence({moveby(1, mx, my), moveby(1, -mx, -my)})))
            end
            child:runAction(repeatForever(sequence({callfunc(nil, rmv), delaytime(2)})))
        end
        child:runAction(sequence({delaytime(startP), callfunc(nil, doFade)}))
    end
end

function BirdScene:updateStar()
end

function BirdScene:ctor()
    self.score = 0
    local vs = getVS()
    local size = {width=768, height=1024}
    self.sz = size
    local sca = vs.height/size.height
    self.scale = sca

    self:initMusic()
    self:initPic()

    self.bg = CCScene:create()
    self.dialogController = DialogController.new(self)
    self.bg:addChild(self.dialogController.bg)
    
    self.backNode = addNode(self.bg)

    setPos(self.bg, {0, 0})
    local far = createSprite("far.png")
    addChild(self.backNode, far)
    setPos(setAnchor(far, {0, 0}), {0, 0})
    setScale(far, sca)

    local far2 = createSprite("far.png")
    addChild(self.backNode, far2)
    setPos(setAnchor(far2, {0, 0}), {768*sca, 0})
    setScale(far2, sca)

    local far3 = createSprite("far.png")
    addChild(self.backNode, far3)
    setPos(setAnchor(far3, {0, 0}), {1536*sca, 0})
    setScale(far3, sca)
    self.allFar = {far, far2, far3}

    self.starNode = addNode(self.backNode)
    self:initStar()
    setVisible(self.starNode, false)

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
    addChild(self.backNode, mid)
    self.m1 = f1
    self.m2 = f2
    self.m3 = f3
    self.mid = mid
    self.allMid = {f1, f2, f3}
    
    self.state = SCENE_STATE.WAIT_START

    local pipNode = CCNode:create()
    addChild(self.backNode, pipNode)
    self.pipNode = pipNode

    self.pipe = {}
    self.freePipe = {}

    self:makeNear()

    --local far1 = createSprite()

    --self.bird = Bird.new(self)
    --addChild(self.bg, self.bird.bg)
    --setVisible(self.bird.bg, false)

    self.birdNode = addNode(self.bg)
    self.nightNode = addNode(self.bg)
   
    self.flashNode = addNode(self.bg)
    self:initFlash()
    setVisible(self.flashNode, false)
    --[[
    local n = math.ceil(vs.width/size.width)
    local sy = vs.height/size.height
    for i=1, n, 1 do
        local night = createSprite("night.png")
        addChild(self.nightNode, night)
        --local sx = vs.width/size.width
        setAnchor(setPos(setScale(night, sy), {768*sy*(i-1), 0}), {0, 0})
    end
    setVisible(self.nightNode, false)
    --]]

    self.speed = 300*self.scale
    self.lastPos = 1000

    --self.bg:addChild(createSprite("greenbirds1.png"))

    
    --self.menu = BirdMenu.new(s)
    --self.bg:addChild(self.menu.bg)
    --self:setNight(false)

    self.needUpdate = true
    registerUpdate(self)
end
function BirdScene:onGet(rep, param)
    self.getYet = true
    if rep == nil then
        return
    end
    local par = rep
    Logic.params = {}
    for k, v in ipairs(par.param) do
        Logic.params[v.key] = v.value
    end
end
function BirdScene:getParam()
    self.inGet = true
    self.getYet = false
    sendReq("getParam", dict(), self.onGet, nil, self)
end
function BirdScene:initPic()
    local sf = CCSpriteFrameCache:sharedSpriteFrameCache()
    sf:addSpriteFramesWithFile("allBird.plist")
    for i=1, 16, 1 do
        createAnimation("birdAni"..i, "bird_"..i.."_%d.png", 0, 3, 1, 0.133, true)
    end
end
function BirdScene:initMusic()
    Music.preload("button.mp3")
    Music.preload("crack.mp3")
    Music.preload("jump.mp3")
    Music.preload("fall.mp3")
    Music.preload("score.mp3")
end
function BirdScene:makeNear()
    local near = CCNode:create()
    local n1 = createSprite("near2.png")
    setScale(setAnchor(setPos(n1, {0, 0}), {0, 0}), self.scale)
    setGLProgram(n1)
    local n2 = createSprite("near2.png")
    setScale(setAnchor(setPos(n2, {768*self.scale, 0}), {0, 0}), self.scale)
    setGLProgram(n2)
    local n3 = createSprite("near2.png")
    setScale(setAnchor(setPos(n3, {1536*self.scale, 0}), {0, 0}), self.scale)
    setGLProgram(n3)

    addChild(near, n1)
    addChild(near, n2)
    addChild(near, n3)
    addChild(self.backNode, near)
    self.near = near
    self.n1 = n1
    self.n2 = n2
    self.n3 = n3

    self.allNear = {n1, n2, n3}
end

function BirdScene:setNight(n)
    if not n then
        setVisible(self.starNode, false)
        setVisible(self.flashNode, false)
        local av = 255
        for k, v in ipairs(self.allFar) do
            setColor(v, {av, av, av})
        end
        for k, v in ipairs(self.allMid) do
            setColor(v, {av, av, av})
        end
        for k, v in ipairs(self.allNear) do
            setColor(v, {av, av, av})
        end
        --setColor(self.bird.bg, {av, av, av})

    else
        setVisible(self.starNode, true)
        setVisible(self.flashNode, true)
        local av = 255*0.7

        for k, v in ipairs(self.allFar) do
            setColor(v, {av, av, av})
        end
        for k, v in ipairs(self.allMid) do
            setColor(v, {av, av, av})
        end
        for k, v in ipairs(self.allNear) do
            setColor(v, {av, av, av})
        end
        --setColor(self.bird.bg, {av, av, av})
    end
end
function BirdScene:resetScene()
    self.score = 0
    --removeSelf(self.mid)
    --removeSelf(self.pipNode)
    --removeSelf(self.near)
    removeSelf(self.bird.bg)

    local rd = math.random(2)
    if rd == 1 then
        --setVisible(self.nightNode, true)
        self:setNight(true)
    else
        self:setNight(false)
        --setVisible(self.nightNode, false)
    end
    --self:setNight(true)

    setPos(self.mid, {0, 0})
    setPos(self.m1, {0, 0})
    setPos(self.m2, {768, 0})
    setPos(self.m3, {1536, 0})

    setPos(self.near, {0, 0})
    setPos(self.n1, {0, 0})
    setPos(self.n2, {768*self.scale, 0})
    setPos(self.n3, {1536*self.scale, 0})

    setPos(self.pipNode, {0, 0})
    
    for k, v in ipairs(self.pipe) do
        removeSelf(v[1])
        removeSelf(v[2])
        table.insert(self.freePipe, v)
    end
    self.pipe = {}
end
function BirdScene:realStart()
    self.state = SCENE_STATE.FREE
    self.bird = Bird.new(self)
    addChild(self.birdNode, self.bird.bg)
    --setVisible(self.bird.bg, false)
    --setVisible(self.bird.bg, true)
    --显示数字
    self.runMenu = RunMenu.new(self)
    --不隐藏 RunMenu
    global.director:pushView(self.runMenu, nil, nil, nil, false)
    self.runMenu:adjustScore(self.score)
    
    self.ready = Ready.new(self)
    global.director:pushView(self.ready)
end
function BirdScene:startGame()
    --self:getParam()
    self:realStart()
end

function BirdScene:update(diff)
    --self:updateStar()

    if self.inGet and self.getYet then
        self.inGet = false
        self:realStart()
    end

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
            --弹出 得分菜单 RunMenu
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
    if n1p[1]+p[1]+768*self.scale < 0 then
        setPos(self.n1, {n3p[1]+768*self.scale, 0})
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
        Music.playEffect("score.mp3")
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
        
        local rdLevel
        local vs = getVS()
        --下面管道的高度范围
        local height = math.random(vs.height-330*self.scale-172*self.scale)+172*self.scale
        

        --local h1 = vs.height/2-132-sz.height
        local h1 = height-sz.height*self.scale
        --local h2 = vs.height/2+132+sz.height
        local h2 = height+258*self.scale+sz.height*self.scale
        
        setScale(setAnchor(setPos(p1, {self.lastPos, h1}), {0.5, 0}), self.scale)
        setScale(setAnchor(setPos(p2, {self.lastPos, h2}), {0.5, 0}), self.scale)
        setScaleY(p2, -self.scale)

        addChild(self.pipNode, p1)
        addChild(self.pipNode, p2)
        --是否 计分过
        table.insert(self.pipe, {p1, p2, false})
        self.lastPos = self.lastPos+432*self.scale
        --end
    else
        
        local pos = getPos(self.pipe[1][1])
        local bp = getPos(self.pipNode)
        --
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