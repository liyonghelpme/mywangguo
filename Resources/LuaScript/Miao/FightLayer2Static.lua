function FightLayer2:finishFoot()
    print("finish Foot attack")
    self:clearMenu()
    local ret, left, right = self:oneFail()
    if ret then
    else
        self.animateYet = false
        self.finishAttack = false
        self.day = 0
        self.passTime = 0
        for k, v in ipairs(self.allSoldiers) do
            v.funcSoldier:resetPos()
        end
        self.leftCamera:clearCamera()
        self.rightCamera:clearCamera()
    end
end
function FightLayer2:countFoot()
    for k, v in ipairs(self.allSoldiers) do
        if v.id == 0 and not v.dead then
            return 1
        end
    end
    return 0
end
function FightLayer2:clearMenu()
    self.scene.menu:finishRound()
end
function FightLayer2:oneFail()
    local left = 0
    local right = 0
    for k, v in ipairs(self.allSoldiers) do
        if not v.dead then
            if v.color == 0 then
                left = left+1
            elseif v.color == 1 then
                right = right+1
            end
            if left > 0 and right > 0 then
                return false
            end
        end
    end
    print("oneFail", left, right)
    --只是士兵 跑动 一会大概几秒钟吧
    for k, v in ipairs(self.allSoldiers) do
        v:doWinMove(left, right)
    end
    if left == right then
        addBanner("平局")
    elseif left > 0 then
        addBanner("胜利")
    else
        addBanner("失败")
    end
    return true, left, right
end

--不同士兵类型执行不同的剧本
function FightLayer2:footScript(diff)
    --print("footScript")
    local p = getPos(self.battleScene)
    if self.passTime == 0 then
        self.moveTarget = p[1]
        --快速移动镜头 分镜头
        --再显示animate动画
        local p = getPos(self.battleScene)
        local vs = getVS()
        local bp = self.leftWidth
        --该种士兵的第一行的头部加上 一定偏移值 第一排要显示完全
        self.moveTarget = -(bp-(vs.width/2-FIGHT_OFFX))
        --trace Soldier if soldier dead trace other first soldier
        --front line soldier
        print("foot left Width ", self.moveTarget)
        self:showLeftCamera() 
        --快速移动到 镜头到场景某个位置 同时 修正 battleScene 中相关对象的位置
        --然后恢复场景位置
        self.leftCamera:fastMoveTo(p, self.moveTarget) 

        --右侧镜头位置当前屏幕的左侧
        self:showRightCamera()
        --local fw = #self.eneFootNum*FIGHT_OFFX
        local ahead = self.WIDTH-self.rightWidth
        self.rightCamera:fastMoveTo({p[1]-vs.width/2-2, p[2]}, -(ahead-FIGHT_OFFX))
    end
    if self.leftCamera.startPoint ~= nil and self.rightCamera.startPoint ~= nil then
        local ls = self.leftCamera.startPoint[1]
        --镜头移动移动到目标位置了 则播放跑步动画
        if math.abs(ls-self.leftCamera.moveTarget) < 5 then
            if not self.animateYet then
                self.animateYet = true
                for k, v in ipairs(self.allSoldiers) do
                    --开始跑步和攻击
                    v:doRunAndAttack(self.day)
                end
            end
        end

        local vs = getVS()
        local ls = -self.leftCamera.startPoint[1]
        local rs = -self.rightCamera.startPoint[1]
        local lw = self.leftCamera.width
        local rw = self.rightCamera.width
        local lp = getPos(self.leftCamera.renderTexture)
        local rp = getPos(self.rightCamera.renderTexture)
        print("leftCamera rightCamera", ls, rs, lw, rw, simple.encode(lp), simple.encode(rp))
        --镜头相交
        if not self.mergeYet and not self.clone then
            if ls < rs+rw and ls+lw > rs then
                self:mergeCamera()
            end
        end
        --拆分镜头 步兵移动
        if self.mergeYet then
            print("splitCamera foot check", ls, rs+rw, ls+lw, rs, rw, lw)
            print("soldier merge only show one soldier view all Foot killed")
            print('left live or right live')
            if (ls+lw) > (rs+rw) then
                if self.mySol ~= nil and not self.mySol.dead then
                    --main clone left move
                    self:cloneLeftCamera()
                elseif self.eneSol ~= nil and not self.eneSol.dead then
                    --main clone rightMove
                    self:cloneRightCamera()
                end
                --print("splitCamera for foot soldier")
                --self:splitCamera()
            end
        end
    end

    --第一天结束之后 场景应该回到那个位置呢？
    --开始的弓箭手位置
    self.passTime = self.passTime+diff
    local cf = self:countFoot()
    if (cf == 0 or self.passTime >= 20) and not self.finishAttack then
        print("finish foot attack now", cf, self.passTime)
        self.finishAttack = true
        for k, v in ipairs(self.allSoldiers) do
            v:finishAttack()
        end
        --回到弓箭位置
        --self.day = 0
        --等上一会才士兵回到初始位置
        self.bg:runAction(sequence({delaytime(1), callfunc(self, self.finishFoot)}))
    end

    --屏幕重新回到开始位置 
    --FIXME 优化性能只在 镜头设置后 才 设定镜头的object
    if not self.finishAttack and self.animateYet then
        local mySol
        --从外列 逐行搜索
        if self.mySol == nil or self.mySol.dead then
            local maxX = 0
            --从下行到上行 应该从上到下 
            --随便了 足够的空隙即可
            for k, v in ipairs(self.mySoldiers) do
                for tk, tv in ipairs(v) do
                    --活着的士兵
                    if not tv.dead then
                        --local p = getPos(tv.bg)
                        --if p[1] > maxX then 
                            mySol = tv
                            --maxX = p[1]
                            break
                        --end
                    end
                end
            end
            self.mySol = mySol
        end
        if self.mySol ~= nil then
            self.leftCamera:trace(self.mySol, FIGHT_OFFX*2)
        end
        --寻找影子步兵
        --local sp = getPos(mySol.bg)
        --local vs = getVS()
        --看一下4对象的位置
        --查看一下 当前最前端的步兵的 位置 如果步兵死亡了 那么 就使用影子步兵来移动
        --shadow 所有步兵移动都会 影响 
        if self.eneSol == nil or self.eneSol.dead then
            local maxX = 0
            --从下行到上行 应该从上到下 
            --随便了 足够的空隙即可
            for k, v in ipairs(self.eneSoldiers) do
                for tk, tv in ipairs(v) do
                    --活着的士兵
                    if not tv.dead then
                        --local p = getPos(tv.bg)
                        --if p[1] > maxX then 
                            self.eneSol = tv
                            --maxX = p[1]
                            break
                        --end
                    end
                end
            end
        end
        if self.eneSol ~= nil then
            self.rightCamera:trace(self.eneSol, -FIGHT_OFFX*2)
        end
    end

    if self.moveTarget ~= nil then
        --[[
        local pos = getPos(self.battleScene)
        local smooth = diff*5
        smooth = math.min(smooth, 1)
        local px = pos[1]*(1-smooth)+self.moveTarget*smooth
        setPos(self.battleScene, {px, pos[2]}) 
        self:adjustBattleScene(px)
        --]]
        --[[
        local fxy = getPos(self.farScene)
        setPos(self.farScene, {px*self.farRate, fxy[2]})
        local nxy = getPos(self.nearScene)
        setPos(self.nearScene, {px*self.nearRate, nxy[2]})
        --]]
    end
    if self.clone then
        if self.cloneWho == 0 then
            self.mainCamera.moveTarget = self.leftCamera.moveTarget 
            self.mainCamera.startPoint = self.leftCamera.startPoint
        else
            self.mainCamera.moveTarget = self.rightCamera.moveTarget
            self.mainCamera.startPoint = self.rightCamera.startPoint
        end
    end
end
--主镜头 clone 某个分镜头的 moveTarget 和 位置行为
function FightLayer2:cloneLeftCamera()
    self.mergeYet = false
    self.clone = true
    self.cloneWho = 0
end
function FightLayer2:cloneRightCamera()
    self.mergeYet = false
    self.clone = true
    self.cloneWho = 1
end

function FightLayer2:switchArrow()
    self.day = 1
    self.animateYet = false
    self.passTime = 0
end
--显示分镜头关闭主镜头
function FightLayer2:showLeftCamera()
    setVisible(self.leftCamera.renderTexture, true)
    setVisible(self.tempNode, false)
    local vs = getVS()
    setPos(self.leftCamera.renderTexture, {vs.width/4-1, FIGHT_HEIGHT/2})
    setVisible(self.mainCamera.renderTexture, false)
    self.mergeYet = false
end
function FightLayer2:showRightCamera()
    setVisible(self.rightCamera.renderTexture, true)
    setVisible(self.tempNode, false)
    local vs = getVS()
    setPos(self.rightCamera.renderTexture, {vs.width/2+vs.width/4+1, FIGHT_HEIGHT/2})
    setVisible(self.mainCamera.renderTexture, false)
    self.mergeYet = false
end

function FightLayer2:mergeCamera()
    print("merge camera")
    setVisible(self.leftCamera.renderTexture, false)
    setVisible(self.rightCamera.renderTexture, false)
    setVisible(self.mainCamera.renderTexture, true)
    setVisible(self.tempNode, false)
    --对镜头位置
    self.mainCamera.moveTarget = self.leftCamera.moveTarget
    self.mainCamera.startPoint = self.leftCamera.startPoint
    self.mergeYet = true
end
--根据mainCamera 属性重新设定两个镜头的位置和 startPoint 和 已经追踪的对象交换
--交换镜头的position 即可
function FightLayer2:splitCamera()
    self.mergeYet = false
    print("splitCamera")
    setVisible(self.mainCamera.renderTexture, false)
    setVisible(self.leftCamera.renderTexture, true)
    setVisible(self.rightCamera.renderTexture, true)
    
    local vs = getVS()
    --交换镜头位置
    setPos(self.rightCamera.renderTexture, {vs.width/4-1, FIGHT_HEIGHT/2})
    setPos(self.leftCamera.renderTexture, {vs.width/2+vs.width/4+1, FIGHT_HEIGHT/2})
end

--屏幕左侧宽度 要是 保证最后面的有半个屏幕可以显示 至少 
--当前最后面的 是弓箭手
--当前的命令队列 cmdList 解释命令 执行命令  
function FightLayer2:arrowScript(diff)
    if self.passTime == 0 then
        local p = getPos(self.battleScene)
        local vs = getVS()
        local fw = #self.myFootNum*FIGHT_OFFX
        local bp = self.leftWidth-fw
        --该种士兵的第一行的头部加上 一定偏移值 第一排要显示完全
        self.moveTarget = -(bp-(vs.width/2-FIGHT_OFFX))
        print("self.leftWidth ", self.moveTarget)
        self:showLeftCamera() 
        --快速移动到 镜头到场景某个位置 同时 修正 battleScene 中相关对象的位置
        --然后恢复场景位置
        self.leftCamera:fastMoveTo(p, self.moveTarget) 

        --右侧镜头位置当前屏幕的左侧
        self:showRightCamera()
        local fw = #self.eneFootNum*FIGHT_OFFX
        local ahead = self.WIDTH-self.rightWidth+fw
        self.rightCamera:fastMoveTo({p[1]-vs.width/2-2, p[2]}, -(ahead-FIGHT_OFFX))
    end
    self.passTime = self.passTime+diff
    --两个镜头已经分离了再合并
    if self.leftCamera.startPoint ~= nil and self.rightCamera.startPoint ~= nil then
        local vs = getVS()
        local ls = -self.leftCamera.startPoint[1]
        local rs = -self.rightCamera.startPoint[1]
        local lw = self.leftCamera.width
        local rw = self.rightCamera.width
        local lp = getPos(self.leftCamera.renderTexture)
        local rp = getPos(self.rightCamera.renderTexture)
        print("leftCamera rightCamera", ls, rs, lw, rw, simple.encode(lp), simple.encode(rp))
        --镜头相交
        if not self.mergeYet then
            if ls < rs+rw and ls+lw > rs then
                self:mergeCamera()
            end
        end
        --拆分镜头
        if self.mergeYet then
            if ls > rs+rw or ls+lw < rs then
                self:splitCamera()
            end
        end
    end

    --如何制作一个合体的镜头呢？
    if self.moveTarget ~= nil then
        --[[
        local pos = getPos(self.battleScene)
        local dx = math.abs(pos[1]-self.moveTarget)
        local smooth = diff*5
        smooth = math.min(smooth, 1)
        local px = pos[1]*(1-smooth)+self.moveTarget*smooth
        setPos(self.battleScene, {px, pos[2]})
        self:adjustBattleScene(px)

        if self.prepareFoot and dx <= 5 then
            self.prepareFoot = false
            for k, v in ipairs(self.allSoldiers) do
                v:finishAttack()
            end
            self.bg:runAction(sequence({delaytime(0.5), callfunc(self, self.switchArrow)}))
            print("begin Foot Script")
        end
        --]]
    end
    --进入 动画状态
    local p = getPos(self.battleScene)
    --print("battleScene pos and moveTarget", p[1], self.moveTarget)
    if not self.animateYet and math.abs(p[1]-self.moveTarget) <= 5 then
        self.animateYet = true
        for k, v in ipairs(self.allSoldiers) do
            --开始跑步和攻击
            v:doRunAndAttack(self.day)
        end
        print("animation state")
    end
    --trace Arrow 位置
    if self.arrow ~= nil or self.rightArrow ~= nil then
        if not self.arrowOver then
            if self.arrow ~= nil and self.arrow.dead then
                self.arrow = nil
                self.arrowOver = true
                --进入分屏幕状态 下一个 回合
                self.bg:runAction(sequence({delaytime(1), callfunc(self, self.finishArrow)}))
            elseif self.rightArrow ~= nil and self.rightArrow.dead then
                self.rightArrow = nil
                self.arrowOver = true
                self.bg:runAction(sequence({delaytime(1), callfunc(self, self.finishArrow)}))
            end
        end

        --弓箭死亡了 准备进入第二个节点
        --[[
        if self.arrow.dead then
            self.arrow = nil
            self.bg:runAction(sequence({delaytime(1), callfunc(self, self.finishArrow)}))
        else
            local vs = getVS()
            local ap = getPos(self.arrow.changeDirNode)
            local abp = getPos(self.arrow.bg)
            ap[1] = abp[1]+ap[1]
            ap[2] = abp[2]+ap[2]
            local cp = getPos(self.battleScene)
            if (ap[1]+100) >= (-cp[1]+vs.width/2) then
                self.moveTarget = -(ap[1]+100-vs.width/2)
                --self.leftCamera:fastMoveTo(p, self.moveTarget) 
            end
        end
        --]]
    end
end
--进入步兵回合 
--插入好多动作
function FightLayer2:finishArrow()
    --self.day = 1
    --左侧屏幕宽度 第一排 步兵的位置
    --游戏开始就记录了步兵的位置
    self:clearMenu()
    local ret, left, right = self:oneFail()
    if ret then
    else
        --进入步兵开始状态 屏幕分割 和 屏幕设定位置
        --[[
        local vs = getVS()
        local mv = self.leftWidth-vs.width/2
        self.moveTarget = -mv
        self.prepareFoot = true
        print("finishArrow", -mv)
        --]]
        --self.day = 1
        --self.passTime = 0
        for k, v in ipairs(self.allSoldiers) do
            v:finishAttack()
        end
        self.day = 1
        self.animateYet = false
        self.passTime = 0
        self.leftCamera:clearCamera()
        self.rightCamera:clearCamera()

        --self.bg:runAction(sequence({delaytime(0.5), callfunc(self, self.switchArrow)}))
    end
end



--可能有多个 arrow
--先追踪 我方的弓箭
--镜头追踪新的弓箭位置
function FightLayer2:traceArrow(arr)
    if arr.color == 0 then
        if self.arrow ~= nil then
            local ap = getPos(self.arrow.bg)
            local np = getPos(arr.bg)
            --按照左侧追踪 我方镜头表现
            if np[1] > ap[1] then
                self.arrow = arr
            end
        else
            self.arrow = arr
        end
        --startPoint 应该
        self.leftCamera:trace(self.arrow, 200)
    else
        if self.rightArrow ~= nil then
            local ap = getPos(self.rightArrow.bg)
            local np = getPos(arr.bg)
            if np[1] < ap[1] then
                self.rightArrow = arr
            end
        else
            self.rightArrow = arr
        end
        self.rightCamera:trace(self.rightArrow, -200)
    end
end
