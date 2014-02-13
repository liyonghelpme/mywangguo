Bird = class()
BIRD_STATE = {
    FREE = 0,
    LIVE = 1,
    DEAD = 2,
}
function Bird:ctor(s)
    self.scene = s

    local sf = CCSpriteFrameCache:sharedSpriteFrameCache()
    sf:addSpriteFramesWithFile("greenbird.plist")
    self.ani = createAnimation("birdAni", "greenbirds%d.png", 1, 4, 1, 0.133, true)

    self.bg = createSprite("greenbirds1.png")
    setAnchor(self.bg, {378/768, (1024-360)/1024})
    self.bg:runAction(repeatForever(CCAnimate:create(self.ani)))
    --self.bg:setRotation(45)

    self.state = BIRD_STATE.FREE

    local vs = getVS()
    setPos(self.bg, {vs.width/2, vs.height/2})

    --self.bg:addChild(createSprite("greenbirds1.png"))
    self.vy = 0
    self.tap = false
    
    self.touch = ui.newFullTouch({delegate=self, touchBegan=self.touchBegan, touchMoved=self.touchMoved, touchEnded = self.touchEnded})
    self.bg:addChild(self.touch.bg)
    local fallT = 1.329
    --self.acc = 360*2/(fallT*fallT)
    self.acc = 400
    self.vx = 100
    self.targetDir = 0
    
    self.moveAni = nil

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
                return
            end
        end

        print("bird update", self.acc, diff, self.acc*diff)
        --self.vy = self.vy - self.acc*diff 
        self.vy = self.vy -self.acc*diff
        if self.tap then
            self.tap = false
            --self.vy = 80
            self.vy = -40
            self.targetDir = -30

            local vs = getVS()
            local p = getPos(self.bg)
            --飞出天空则 停止飞行
            if p[2] >= vs.height-40 then
                 
            else
                if self.moveAni ~= nil then
                    self.bg:stopAction(self.moveAni)
                end
                
                self.moveAni = expinout(moveby(0.1, 0, 72))
                self.bg:runAction(self.moveAni)
            end
        end

        local p = getPos(self.bg)
        p[2] = p[2]+self.vy*diff
        setPos(self.bg, p)
        
        local pp = getPos(self.scene.pipNode)
        for k, v in ipairs(self.scene.pipe) do
            local v1xy = getPos(v[1])
            local v2xy = getPos(v[2])
            v1xy[1] = v1xy[1]+pp[1]
            v2xy[1] = v2xy[1]+pp[1]
            print("v1xy v2xy", simple.encode(v1xy), simple.encode(v2xy))
            print("myp", simple.encode(p))
            if intersectRect({p[1]-40, p[2]-36, 80, 72}, {v1xy[1]-68, v1xy[2], 136, 742}) then
                self.state = BIRD_STATE.DEAD
                --addBanner("你死了")
                break
            elseif intersectRect({p[1]-40, p[2]-36, 80, 72}, {v2xy[1]-68, v2xy[2]-742, 136, 742}) then
            --elseif p[1]+40 >= v2xy[1]-68 and p[2]-36 <= v2xy[2] and p[1]-40 <= v2xy[1]+68 and p[2]+36 >= v2xy[2]-742 then
                self.state = BIRD_STATE.DEAD
                --addBanner("你死了")
                break
            end

        end
        --有个弹跳在里面的 不仅仅是速度  还有高度也决定了 旋转的角度
        --local dir = math.atan2(self.vy, self.vx)
        --dir =  dir*180/math.pi
        --print("dir is", self.vy, self.vx, dir)
        --local kd = dir
        self.targetDir = self.targetDir+3*180/math.pi*diff

        --if dir >= 88 then
        --    dir = 90
            --dir = self.oldDir*0.5+dir*0.5
        --end
        --self.targetDir = -dir

        --self.oldDir = dir

        --setRotation(self.bg, -math.floor(dir))


        if p[2] <= 164 then
            p[2] = 164
            setPos(self.bg, p)
            self.state = BIRD_STATE.DEAD    
            --addBanner("你死了")
        end
    elseif self.state == BIRD_STATE.DEAD then
        if not self.stopFly then
            self.stopFly = true
            self.bg:stopAllActions()
        end
        --继续修正速度 但是 不修正 方向了
        self.vy = self.vy - self.acc*diff 
        --self.vy = self.vy -0.2
        self.targetDir = self.targetDir+3*180/math.pi*diff
        --self.targetDir = 90
        local p = getPos(self.bg)
        p[2] = p[2]+self.vy*diff
        setPos(self.bg, p)
        if p[2] <= 164 then
            p[2] = 164
            setPos(self.bg, p)
        end
        
        --[[
        local dir = math.atan2(self.vy, self.vx)
        dir = dir*180/math.pi
        if dir >= 88 then
            dir = 90
            --dir = self.oldDir*0.5+dir*0.5
        end
        self.targetDir = -dir
        --]]
        --self.oldDir = dir

        --print("dir is", self.vy, self.vx, dir)
        --self.bg:setRotation(-math.floor(dir))

        if not self.shakeYet then
            self.shakeYet = true
            self.scene:shakeNow()
        end
    end
    if self.targetDir >= 90 then
        self.targetDir = 90
    end
    local cr = self.bg:getRotation() 
    local smooth = math.min(1, 8*diff)
    local nr = cr*(1-smooth)+self.targetDir*smooth
    setRotation(self.bg, nr)
end

function Bird:touchBegan(x, y)
    self.tap = true
end
function Bird:touchMoved()
end
function Bird:touchEnded()
end
