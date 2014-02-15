Bird = class()
BIRD_STATE = {
    FREE = 0,
    LIVE = 1,
    DEAD = 2,
    CRACK = 3,
}
function Bird:ctor(s)
    self.scene = s
    self.birdScale = 0.9
    local rd = math.random(16)
    self.ani = getAnimation("birdAni"..rd)
    --随机一只鸟
    self.bg = createSprite("bird_"..rd.."_0.png")
    --setAnchor(self.bg, {378/768, (1024-360)/1024})
    setAnchor(self.bg, {99/200, (200-108)/200})
    self.bg:runAction(repeatForever(CCAnimate:create(self.ani)))
    --self.bg:setRotation(45)

    self.state = BIRD_STATE.FREE
    local sz = {width=768, height=1024}
    setScale(self.bg, self.scene.scale*self.birdScale)
    local vs = getVS()
    local bx, by = screenXY(218, fixY(sz.height, 494))
    
    setPos(self.bg, {bx, by})
    self.baseY = by
    --setPos(self.bg, {218, fixY(sz.height, 494)})


    --self.bg:addChild(createSprite("greenbirds1.png"))
    self.vy = 0
    self.tap = false
    
    self.touch = ui.newFullTouch({delegate=self, touchBegan=self.touchBegan, touchMoved=self.touchMoved, touchEnded = self.touchEnded})
    self.bg:addChild(self.touch.bg)
    local fallT = 1.329
    --self.acc = 360*2/(fallT*fallT)
    self.acc = getDefault(Logic.params, "fallAcc", 500)
    self.vx = 100
    self.targetDir = 0
    self.upTime = 0
    self.leftTime = 0
    
    self.moveAni = nil
    self.passTime = 0
    self.needUpdate = true
    registerEnterOrExit(self)
end
function Bird:update(diff)
    if self.state == BIRD_STATE.FREE then
        if self.scene.state == SCENE_STATE.WAIT_START then
            return
        end
        if self.scene.state == SCENE_STATE.FREE then
            if self.tap then
                self.scene.state = SCENE_STATE.RUN 
                return
            else
                self.passTime = self.passTime+diff
                local y = math.sin(self.passTime*3.14)*20+self.baseY
                local p = getPos(self.bg)
                setPos(self.bg, {p[1], y})
                return
            end
        end

        --只有重力
        local downAcc = 3000*self.scene.scale
        --点击后的初始向上速度，向上动作持续时间
        local jumpSpeed, jumpTicks = 720*self.scene.scale, 30
        
        if self.tap then
            self.tap = false
            Music.playEffect("jump.mp3")
            local vs = getVS()
            local p = getPos(self.bg)
            --飞出天空则 停止飞行
            if p[2] >= vs.height-40 then
                 
            else
                self.vy = jumpSpeed
                self.upTime = jumpTicks
            end
        end
        self.acc = downAcc
        --无响应 降落4帧 最多
        --self.leftTime = math.min(self.leftTime+diff, 0.06664)
        self.leftTime = self.leftTime+diff

        --jumpTicks 有30 帧要执行 0.5s时间
        --防止 帧率瞬间掉落 导致的 运行时间过长
        while self.leftTime >= 0.01666 do
            self.leftTime = self.leftTime-0.01666
            local p = getPos(self.bg)
            p[2] = p[2]+self.vy*0.01666
            setPos(self.bg, p)
            
            self.vy = self.vy - self.acc*0.01666
            if self.upTime > 0 then
                self.targetDir = math.max(self.targetDir-15, -25)
            else
                self.targetDir = self.targetDir+5
            end
            --固定帧率 来做 物理计算根据时间 来确定 是否到特定的帧了
            self.upTime = math.max(self.upTime-1, 0)
        end
        --速度降低成 0 
        self.leftTime = 0

        local p = getPos(self.bg)
        --end
        
        local pp = getPos(self.scene.pipNode)
        for k, v in ipairs(self.scene.pipe) do
            local v1xy = getPos(v[1])
            local v2xy = getPos(v[2])
            v1xy[1] = v1xy[1]+pp[1]
            v2xy[1] = v2xy[1]+pp[1]
            
            
            --小鸟的位置是绝对屏幕位置
            if intersectRect({p[1]-40*self.scene.scale*self.birdScale, p[2]-36*self.scene.scale*self.birdScale, 80*self.scene.scale*self.birdScale, 72*self.scene.scale*self.birdScale}, {v1xy[1]-68*self.scene.scale, v1xy[2], 136*self.scene.scale, 742*self.scene.scale}) then
                self.state = BIRD_STATE.DEAD
                Music.playEffect("crack.mp3")
                --addBanner("你死了")
                break
            elseif intersectRect({p[1]-40*self.scene.scale*self.birdScale, p[2]-36*self.scene.scale*self.birdScale, 80*self.scene.scale*self.birdScale, 72*self.scene.scale*self.birdScale}, {v2xy[1]-68*self.scene.scale, v2xy[2]-742*self.scene.scale, 136*self.scene.scale, 742*self.scene.scale}) then
            --elseif p[1]+40 >= v2xy[1]-68 and p[2]-36 <= v2xy[2] and p[1]-40 <= v2xy[1]+68 and p[2]+36 >= v2xy[2]-742 then
                self.state = BIRD_STATE.DEAD
                --addBanner("你死了")
                Music.playEffect("crack.mp3")
                break
            end

        end

        if p[2] <= 164*self.scene.scale then
            p[2] = 164*self.scene.scale
            Music.playEffect("fall.mp3")
            Music.playEffect("crack.mp3")
            setPos(self.bg, p)
            self.state = BIRD_STATE.DEAD    
        end
    elseif self.state == BIRD_STATE.DEAD then
        if not self.stopFly then
            self.stopFly = true
            self.bg:stopAllActions()
        end
        self.vy = self.vy - self.acc*diff 
        self.targetDir = self.targetDir+5
        local p = getPos(self.bg)
        p[2] = p[2]+self.vy*diff
        setPos(self.bg, p)
        if p[2] <= 164*self.scene.scale then
            p[2] = 164*self.scene.scale
            setPos(self.bg, p)
        end

        if not self.shakeYet then
            self.shakeYet = true
            self.scene:shakeNow()
        end
    elseif self.state == BIRD_STATE.CRACK then

    end
    if self.targetDir >= 90 then
        self.targetDir = 90
    end
    setRotation(self.bg, self.targetDir)
end

function Bird:touchBegan(x, y)
    self.tap = true
end
function Bird:touchMoved()
end
function Bird:touchEnded()
end
