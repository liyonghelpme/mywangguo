Bomb = class(SoldierFunc)
--逐渐消失 health = 0
function Bomb:doAttack()
    --ball
    --0 1 2 3
    --10 11 12 13
    --bombCircle
    local function makeBomb()
        local function doHarm()
            self.soldier.attackTarget:doHarm(100)
        end
        delayCall(0.3, doHarm)
        self.soldier:doHarm(self.soldier.health)

        local bf = ccBlendFunc()
        bf.src = GL_ONE
        bf.dst = GL_ONE
        local p = getPos(self.soldier.bg)
        p[2] = p[2]+20
        local function makeFlash()
            local flash = CCSprite:create("myfire.png")
            setSize(setPos(flash, p), {128, 128})
            flash:setBlendFunc(bf)
            self.soldier.map.bg:addChild(flash)
            flash:runAction(sequence({fadein(0.1), scaleto(0.5, 0, 0), callfunc(nil, removeSelf, flash)}))
        end
        makeFlash() 


        local function makeCore()
            local bat = CCSpriteBatchNode:create("fig7.png")
            bat:setBlendFunc(bf)
            self.soldier.map.bg:addChild(bat, MAX_BUILD_ZORD)
            setPos(bat, p)
            for i=0, 30, 1 do
                local sp = CCSprite:createWithSpriteFrameName("arrow0")
                bat:addChild(sp)
                setAnchor(setScale(sp, 0.0), {1, 0.5})
                local rx = math.random(10)-5
                local ry = math.random(10)-5
                setPos(sp, {rx, ry})
                local dir = math.random(1, 360)
                sp:setRotation(dir)
                local t = math.random()*0.5+0.2
                local sca = math.random()*0.1+0.1
                sp:runAction(scaleto(t, sca, sca+0.2))
                sp:runAction(itintto(0.7, 0, 0, 0))
            end
        end
        --等待一段时间产生
        self.soldier.bg:runAction(sequence({delaytime(0.2), callfunc(nil, makeCore)}))

        local function makeFire()
            local bat = CCSpriteBatchNode:create("fig7.png")
            bat:setBlendFunc(bf)
            self.soldier.map.bg:addChild(bat, MAX_BUILD_ZORD)
            setPos(bat, p)
            local bn = {0, 1, 10, 11}
            for i=0, 20, 1 do
                local r = bn[math.random(1, 4)]
                local sp = CCSprite:createWithSpriteFrameName("ball0")
                bat:addChild(sp)
                local rx = math.random(30)-15
                local ry = math.random(20)-10
                setPos(sp, {rx, ry})
                local sca = (21-(ry+10))/21*(math.random()*0.5+0.5)
                setScale(sp, sca, sca)
                local col = {{227, 140, 45}, {156, 42, 0}}
                setColor(sp, col[math.random(1, 2)])
                sp:runAction(sequence({delaytime(0.3), itintto(0.7, 0, 0, 0)}))

                local t = math.random()*0.2+0.2
                --y 越大 scale 越小
            
                sp:runAction(scaleto(t, sca+0.1, sca))
            end
        end
        self.soldier.bg:runAction(sequence({delaytime(0.1), callfunc(nil, makeFire)}))

        local function makeSmoke()
            local smoke = CCSprite:createWithSpriteFrameName("bombCircle")
            self.soldier.map.bg:addChild(smoke, MAX_BUILD_ZORD)
            smoke:setBlendFunc(bf)
            setPos(setScale(smoke, 0, 0), p)
            smoke:runAction(scaleto(0.5, 1.5, 0.75))
            smoke:runAction(sequence({delaytime(0.2), itintto(0.3, 0, 0, 0)}))
        end
        self.soldier.bg:runAction(sequence({delaytime(0.3), callfunc(nil, makeSmoke)}))
    end
    --震动 产生冲击波 消失 health = 0
    self.soldier.bg:runAction(sequence({repeatN(sequence({moveby(0.1, -5, 0), moveby(0.1, 5, 0)}), 4), callfunc(nil, makeBomb)}))

end
