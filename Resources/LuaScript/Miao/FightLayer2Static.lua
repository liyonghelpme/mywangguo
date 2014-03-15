function FightLayer2:finishCavalry()
    print("finishCavalry")
    self:clearMenu()
    local ret, left, right = self:oneFail()
    if ret then
    else
        for k, v in ipairs(self.allSoldiers) do
            v.funcSoldier:resetPos()
        end
        self.day = 0
        self:clearState()
        --最后一天显示day
        self.state = FIGHT_STATE.SHOW_DAY
    end
end

function FightLayer2:finishFoot()
    print("finish Foot attack")
    self:clearMenu()
    local ret, left, right = self:oneFail()
    if ret then
    else
        for k, v in ipairs(self.allSoldiers) do
            v.funcSoldier:resetPos()
        end
        self.day = 3
        self:clearState()
    end
end
--只有在处理完 游戏是否结束后 再清理是否split的状态
function FightLayer2:clearAllCamera()
    self.split = false
    self.leftCamera:clearCamera()
    self.rightCamera:clearCamera()
    self.mainCamera:clearCamera()

    self:showMiddleScene()

    --还原位置
    local vs = getVS()
    setPos(self.leftCamera.renderTexture, {vs.width/4-1, FIGHT_HEIGHT/2})
    setPos(self.rightCamera.renderTexture, {vs.width/2+vs.width/4+1, FIGHT_HEIGHT/2})
end
--我方或者敌方步兵死光
function FightLayer2:countFoot()
    local left = 0
    local right = 0
    for k, v in ipairs(self.allSoldiers) do
        if v.id == 0 and not v.dead then
            if v.color == 0 then
                left = 1
            else
                right = 1
            end
            if left > 0 and right > 0 then
                break
            end
        end
    end
    return left, right
end
function FightLayer2:clearMenu()
    self.scene.menu:finishRound()
end

function FightLayer2:checkOneFootDead()
    local left = 0
    local right = 0
    for k, v in ipairs(self.allSoldiers) do
        if not v.dead and v.id == 0 then
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
    print("check FootDead", left, right)
    return true, left, right
end
function FightLayer2:checkOneDead()
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
    print("check OneDead", left, right)
    return true
end
--一方失败了则 停止运动镜头
function FightLayer2:stopCameraMove(left, right)
    local vs = self.mainCamera.renderTexture:isVisible()
    if not vs then
        --显示胜利的一方
        --平局 
        --胜利 
        --失败
        self:mergeCamera()
        local sz = getVS()
        --可能弓箭 left right Camera 交换了位置
        if left == 0 then
            if not self.split then
                --参考右侧镜头
                print("stopCameraMove")
                --参照 右侧镜头位置布局
                local rs = self.rightCamera.startPoint
                self.mainCamera.moveTarget = rs[1]+sz.width/2
                self.mainCamera.startPoint = {rs[1]+sz.width/2, rs[2]}
            --参考左侧镜头位置即可
            else
            end
        else
            --left 胜利 参考 左侧镜头 如果 弓箭split 了 则参考右侧镜头
            --测试
            if self.split then
                local rs = self.rightCamera.startPoint
                self.mainCamera.moveTarget = rs[1]+sz.width/2
                self.mainCamera.startPoint = {rs[1]+sz.width/2, rs[2]}
            end
        end
    end
end

--天数到了平局
function FightLayer2:dayOver()
    addBanner("平局")

    local function checkWin()
        print("oneFail checkWin")
        if Logic.newVillage then
            Logic.newVillage = false
            print("new Village win inform", global.director.curScene.name)
            global.director.curScene:newVillageWin(win)
        else
            if global.director.curScene.checkWin == nil then
                global.director:pushScene(FightMap.new(), true)
            end
            global.director.curScene:checkWin()
        end
    end
    local function fightOver()
        print("fightOver")
        --如果scene 退出完了 则 push一个新的scene
        local st = global.director.sceneStack
        local os = st[#st-1]
        
        if os.name == 'FightMap' then
            global.director:popScene()
        else
            global.director:replaceScene(FightMap.new())
        end

        delayCall(0.5, checkWin)
    end
    print("why not call fightOver function here")
    self.bg:runAction(sequence({delaytime(5), callfunc(nil, fightOver)}))
end


--获取当前的 主镜头位置 不要移动 然后 展示双方的 移动
function FightLayer2:oneFail()
    local left = 0
    local right = 0
    --清理相机 状态
    self.clone = false
    self.mergeYet = false
    
    --self.skillYet = false

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
    --主镜头不要移动
    self.day = -1
    self:stopCameraMove(left, right)
    --self.clone = false

    local win = false
    --if left == right then
    --    addBanner("平局")
    --else
    if left > 0 then
        addBanner("胜利")
        winCity()
        win = true
    else
        addBanner("失败")
    end

    local function checkWin()
        print("oneFail checkWin")
        Logic.paused = false
        if Logic.newVillage then
            Logic.newVillage = false
            print("new Village win inform", global.director.curScene.name)
            global.director.curScene:newVillageWin(win)
        else
            if global.director.curScene.checkWin == nil then
                global.director:pushScene(FightMap.new(), true)
            end
            global.director.curScene:checkWin()
        end
    end
    local function fightOver()
        print("fightOver")
        --如果scene 退出完了 则 push一个新的scene
        --global.director:popScene()
        local st = global.director.sceneStack
        local os = st[#st-1]
        --新手村阶段
        if os.name == 'FightMap' or Logic.newVillage then
            global.director:popScene()
        else
            global.director:replaceScene(FightMap.new())
        end

        Logic.paused = true
        delayCall(0.5, checkWin)
    end
    print("why not call fightOver function here")
    self.bg:runAction(sequence({delaytime(5), callfunc(nil, fightOver)}))
    return true, left, right
end

function FightLayer2:getMyRight()
    local maxX = 0
    local myT
    for k, v in ipairs(self.allSoldiers) do
        if not v.dead and v.color == 0 then
            local p = getPos(v.bg)
            if p[1] > maxX then
                maxX = p[1]
                myT = v
            end
        end
    end
    return maxX, myT
end
function FightLayer2:getEneLeft()
    local minX = 999999
    local myT
    for k, v in ipairs(self.allSoldiers) do
        if not v.dead and v.color == 1 then
            local p = getPos(v.bg)
            if p[1] < minX then
                minX = p[1]
                myT = v
            end
        end
    end
    return minX, myT
end

--初始化 主动技能
--不用heros 使用 活着的英雄列表
function FightLayer2:initSkill()
    local ss
    local heros = self.allHero
    local he
    --步兵技能 暂时只实现步兵
    --TODO
    --步兵
    if self.day == 2 then
        ss = self.mySoldiers
        he = heros[1]
    elseif self.day == 0 then
        ss = self.myMagicSoldiers
        he = heros[2]
    elseif self.day == 1 then
        ss = self.myArrowSoldiers
        he = heros[3]
    elseif self.day == 3 then
        ss = self.myCavalrySoldiers
        he = heros[4]
    end


    local positive = {}
    for k, v in ipairs(he) do
        if not v.dead and v.heroData.skill ~= nil then
            local skData = Logic.skill[v.heroData.skill]
            if skData.kind == 1 then
                table.insert(positive, skData)
            end
        end
    end
    --确保 英雄 是 活着的 才能施展技能的呀
    print("positive skill", #positive)
    if #positive > 0 then
        for k, v in ipairs(ss) do
            for tk, tv in ipairs(v) do
                if not tv.dead then
                    tv:showSkillEffect(positive)
                end
            end
        end
        local function setOver()
            self.skillOver = true
        end
        self.bg:runAction(sequence({delaytime(1), callfunc(nil, setOver)}))
    else
        self.skillOver = true
    end
end


--不同士兵类型执行不同的剧本
function FightLayer2:footScript(diff)
    --print("footScript")
    local p = getPos(self.battleScene)
    if self.passTime == 0 then
        local footDead, left, right = self:checkOneFootDead()
        if left == 0 and right == 0 then
            self.day = 3
            return
        end

        self.moveTarget = p[1]
        --快速移动镜头 分镜头
        --再显示animate动画
        local p = getPos(self.battleScene)
        local vs = getVS()
        local bp = self.leftWidth
        --self.footDead = footDead
        if left == 0 then
            local mr = self:getMyRight()
            self.moveTarget = -(mr-(vs.width/2-FIGHT_HEAD_OFF))
            self:showLeftCamera() 
            self.leftCamera:fastMoveTo(p, self.moveTarget) 
        else
            --该种士兵的第一行的头部加上 一定偏移值 第一排要显示完全
            self.moveTarget = -(bp-(vs.width/2-FIGHT_OFFX))
            --trace Soldier if soldier dead trace other first soldier
            --front line soldier
            print("foot left Width ", self.moveTarget)
            self:showLeftCamera() 
            --快速移动到 镜头到场景某个位置 同时 修正 battleScene 中相关对象的位置
            --然后恢复场景位置
            self.leftCamera:fastMoveTo(p, self.moveTarget) 
        end
        if right == 0 then
            self:showRightCamera()
            local er = self:getEneLeft()
            self.rightCamera:fastMoveTo({p[1]-vs.width/2-2, p[2]}, -(er-FIGHT_HEAD_OFF))
        else
        --右侧镜头位置当前屏幕的左侧
            self:showRightCamera()
            --local fw = #self.eneFootNum*FIGHT_OFFX
            local ahead = self.WIDTH-self.rightWidth
            self.rightCamera:fastMoveTo({p[1]-vs.width/2-2, p[2]}, -(ahead-FIGHT_OFFX))
        end
    end

    local ls = self.leftCamera.startPoint[1]
    if math.abs(ls-self.leftCamera.moveTarget) < 5 then
        --最简单的箭头效果 图片
        if not self.skillYet then
            self.skillYet = true
            self:initSkill()
        end

        if self.skillOver and not self.animateYet then
            self.animateYet = true
            for k, v in ipairs(self.allSoldiers) do
                --开始跑步和攻击
                v:doRunAndAttack(self.day)
            end
        end
    end

    if self.leftCamera.startPoint ~= nil and self.rightCamera.startPoint ~= nil and self.skillYet then
        --镜头移动移动到目标位置了 则播放跑步动画
        --播放 技能 效果 skillEffect Yet 
        --skillEffect Yet over 接着 进入正题

        local vs = getVS()
        local ls = -self.leftCamera.startPoint[1]
        local rs = -self.rightCamera.startPoint[1]
        local lw = self.leftCamera.width
        local rw = self.rightCamera.width
        local lp = getPos(self.leftCamera.renderTexture)
        local rp = getPos(self.rightCamera.renderTexture)
        print("leftCamera rightCamera", ls, rs, lw, rw, simple.encode(lp), simple.encode(rp))
        --镜头相交 结束了第一个阶段 镜头快速移动 skillYet
        if not self.mergeYet and not self.clone and self.skillYet then
            if ls <= rs+rw and ls+lw >= rs then
                print("merge left right in foot")
                self:mergeCamera()
                self.mergeTime = 0
                --self.footCenter = -self.mainCamera.moveTarget+vs.width/2
            end
        end
        --拆分镜头 步兵移动
        --只merge 了 但是 没有clone
        if self.mergeYet and not self.clone then
            --1907  2370--
            print("splitCamera foot check", ls, rs, ls+lw, rs+rw, rw, lw)
            print("soldier merge only show one soldier view all Foot killed")
            print('left live or right live')
            --这个条件判断有问题
            --一方全部死亡才行
            local footDead, left, right = self:checkOneFootDead()
            --if rs+rw >= 
            --我方士兵都阵亡了 战斗中
            --并且是 之前已经打过一架之后才阵亡的 而不是 立即就clone的 
            --应该在 超出了 镜头位置才clone 而不是一死亡就 clone
            --本回合开始 不是某方 步兵都死了
            --则不用clone 一方的镜头移动么？ 但是也要 追随后续的 魔法和骑兵 去攻击呀
            self.mergeTime = self.mergeTime+diff
            --等待一会merge 移动 等移动到 屏幕中心位置 再clone 追随位置
            if footDead and self.mergeTime > 1 then
                print("camera cross now foot")
                --if self.mySol ~= nil and not self.mySol.dead then
                if right == 0 then
                    print("clone left camera if not mysol dead")
                    --main clone left move
                    self:cloneLeftCamera()
                --elseif self.eneSol ~= nil and not self.eneSol.dead then
                --merge 镜头 结束 之后 我方士兵都死亡了 才clone RightCamera
                else
                    print("all my soldier dead clone ene right foot")
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
    --print("foot passTime", self.passTime)
    --local left, right = self:countFoot()
    --一方士兵死光的话
    local oneDead = self:checkOneDead()
    print("oneDead?", oneDead)
    local footDead, left, right = self:checkOneFootDead()
    if (oneDead or self.passTime >= 20 or (left == 0 and right == 0)) and not self.finishAttack then
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
        --从外列 逐行搜索
        if self.mySol == nil or self.mySol.dead then
            self.mySol = self:findMyRightMostFoot()
        end
        if self.mySol ~= nil then
            if DEBUG_FIGHT then
                setColor(self.mySol.changeDirNode, {0, 255, 0})
            end
            self.leftCamera:trace(self.mySol, FIGHT_OFFX*3)
        end
        --寻找影子步兵
        --local sp = getPos(mySol.bg)
        --local vs = getVS()
        --看一下4对象的位置
        --查看一下 当前最前端的步兵的 位置 如果步兵死亡了 那么 就使用影子步兵来移动
        --shadow 所有步兵移动都会 影响 
        if self.eneSol == nil or self.eneSol.dead then
            self.eneSol = self:findEneLeftFoot()
        end
        if self.eneSol ~= nil then
            if DEBUG_FIGHT then
                setColor(self.eneSol.changeDirNode, {0, 255, 0})
            end
            self.rightCamera:trace(self.eneSol, -FIGHT_OFFX*3)
        end
    end

    if self.clone then
        print("start clone", self.cloneWho)
        if self.cloneWho == 0 then
            print("foot clone left camera", self.leftCamera.cid, self.leftCamera.moveTarget, simple.encode(self.leftCamera.startPoint))
            print("self right", self.rightCamera.moveTarget, simple.encode(self.rightCamera.startPoint))
            --local vs = getVS()
            --相对于左侧镜头 有半个屏幕的偏移
            self.mainCamera.moveTarget = self.leftCamera.moveTarget+self.mainCamera.mainOff
            --self.mainCamera.startPoint = copyTable(self.leftCamera.startPoint)
        else
            print("foot clone right camera")
            self.mainCamera.moveTarget = self.rightCamera.moveTarget+self.mainCamera.mainOff
            --self.mainCamera.startPoint = copyTable(self.rightCamera.startPoint)
        end
    end
end
function FightLayer2:findMyRightMostCavalry()
    local maxX = 0
    local mySol 
    for k, v in ipairs(self.myCavalrySoldiers) do
        for tk, tv in ipairs(v) do
            --活着的士兵
            if not tv.dead then
                local p = getPos(tv.bg)
                if p[1] > maxX then
                    mySol = tv
                    maxX = p[1]
                end
            end
        end
    end
    return mySol
end
function FightLayer2:findEneLeftCavalry()
    local minX = 999999
    local eneSol 
    for k, v in ipairs(self.eneCavalrySoldiers) do
        for tk, tv in ipairs(v) do
            --活着的士兵
            if not tv.dead then
                local p = getPos(tv.bg)
                if p[1] < minX then
                    eneSol = tv
                    minX = p[1]
                end
            end
        end
    end
    return eneSol
end

function FightLayer2:findMyRightMostFoot()
    local maxX = 0
    local mySol 
    for k, v in ipairs(self.mySoldiers) do
        for tk, tv in ipairs(v) do
            --活着的士兵
            if not tv.dead then
                local p = getPos(tv.bg)
                if p[1] > maxX then
                    mySol = tv
                    maxX = p[1]
                end
            end
        end
    end
    return mySol
end
function FightLayer2:findEneLeftFoot()
    local minX = 999999
    local eneSol 
    for k, v in ipairs(self.eneSoldiers) do
        for tk, tv in ipairs(v) do
            --活着的士兵
            if not tv.dead then
                local p = getPos(tv.bg)
                if p[1] < minX then
                    eneSol = tv
                    minX = p[1]
                end
            end
        end
    end
    return eneSol
end
--主镜头 clone 某个分镜头的 moveTarget 和 位置行为
function FightLayer2:cloneLeftCamera()
    local moff = self.mainCamera.moveTarget-self.leftCamera.moveTarget
    self.mainCamera.mainOff = moff
    self.mergeYet = false
    self.clone = true
    self.cloneWho = 0
    print("cloneLeftCamera")
end
function FightLayer2:cloneRightCamera()
    local moff = self.mainCamera.moveTarget-self.rightCamera.moveTarget
    self.mainCamera.mainOff = moff
    self.mergeYet = false
    self.clone = true
    self.cloneWho = 1
    print("cloneRightCamera")
end


--显示分镜头关闭主镜头
function FightLayer2:showLeftCamera()
    setVisible(self.leftCamera.renderTexture, true)
    setVisible(self.tempNode, false)
    local vs = getVS()
    --self.leftCamera.object = nil
    setPos(self.leftCamera.renderTexture, {vs.width/4-1, FIGHT_HEIGHT/2})
    setVisible(self.mainCamera.renderTexture, false)
    self.mergeYet = false
    self.split = false
end
function FightLayer2:showRightCamera()
    setVisible(self.rightCamera.renderTexture, true)
    setVisible(self.tempNode, false)
    local vs = getVS()
    setPos(self.rightCamera.renderTexture, {vs.width/2+vs.width/4+1, FIGHT_HEIGHT/2})
    setVisible(self.mainCamera.renderTexture, false)
    self.mergeYet = false
    self.split = false
end

--显示中间屏幕位置
function FightLayer2:showMiddleScene()
    setVisible(self.leftCamera.renderTexture, false)
    setVisible(self.rightCamera.renderTexture, false)
    setVisible(self.mainCamera.renderTexture, true)
    setVisible(self.tempNode, false)
    local vs = getVS()
    self.mainCamera.startPoint = {-(self.WIDTH/2-vs.width/2), 0}
    self.mainCamera.moveTarget = self.mainCamera.startPoint[1]
end

function FightLayer2:mergeCamera()
    setVisible(self.leftCamera.renderTexture, false)
    setVisible(self.rightCamera.renderTexture, false)
    setVisible(self.mainCamera.renderTexture, true)
    setVisible(self.tempNode, false)
    --对镜头位置
    --清理镜头的object 追踪
    --self.mainCamera.object = nil
    print("merge camera", self.leftCamera.moveTarget, simple.encode(self.leftCamera.startPoint))
    self.mainCamera.moveTarget = self.leftCamera.moveTarget
    self.mainCamera.startPoint = copyTable(self.leftCamera.startPoint)
    self.mergeYet = true
end
function FightLayer2:mergeRightCamera()
    setVisible(self.leftCamera.renderTexture, false)
    setVisible(self.rightCamera.renderTexture, false)
    setVisible(self.mainCamera.renderTexture, true)
    setVisible(self.tempNode, false)

    local vs = getVS()
    self.mainCamera.moveTarget = self.rightCamera.moveTarget+vs.width/2
    local rs = self.rightCamera.startPoint
    self.mainCamera.startPoint = {rs[1]+vs.width/2, rs[2]}
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
    self.split = true
end

--活着的骑兵 都 在等待 返回
function FightLayer2:cavalryAllWait()
    --local waitBack = false
    for mk, mv in ipairs(self.myCavalrySoldiers) do
        for k, v in ipairs(mv) do
            print("cavalryAllWait myCavalrySoldiers", v.dead, v.state)
            if not v.dead and  v.state ~= FIGHT_SOL_STATE.WAIT_BACK then
                return false
            end
        end
    end
    for mk, mv in ipairs(self.eneCavalrySoldiers) do
        for k, v in ipairs(mv) do
            print("cavalryAllWait eneCavalrySoldiers", v.dead, v.state)
            if not v.dead and v.state ~= FIGHT_SOL_STATE.WAIT_BACK then
                return false
            end
        end
    end
    return true
end

function FightLayer2:checkCavalry()
    local left
    local right
    for k, v in ipairs(self.allSoldiers) do
        if not v.dead and v.id == 3 then
            if v.color == 0 then
                left = true
            else
                right = true
            end
        end
    end
    return left, right
end
function FightLayer2:checkMagic()
    local left
    local right
    for k, v in ipairs(self.allSoldiers) do
        if not v.dead and v.id == 2 then
            if v.color == 0 then
                left = true
            else
                right = true
            end
        end
    end
    return left, right
end
function FightLayer2:checkArrow()
    local left
    local right
    for k, v in ipairs(self.allSoldiers) do
        if not v.dead and v.id == 1 then
            if v.color == 0 then
                left = true
            else
                right = true
            end
        end
    end
    return left, right
end

function FightLayer2:checkOneArrowDead()
    local left = 0
    local right = 0
    for k, v in ipairs(self.allSoldiers) do
        if not v.dead and v.id == 1 then
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
    print("check FootDead", left, right)
    return true, left, right
end

function FightLayer2:checkOneCavalryDead()
    local left = 0
    local right = 0
    for k, v in ipairs(self.allSoldiers) do
        if not v.dead and v.id == 3 then
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
    print("check Magic Dead", left, right)
    return true, left, right
end
function FightLayer2:checkOneMagicDead()
    local left = 0
    local right = 0
    for k, v in ipairs(self.allSoldiers) do
        if not v.dead and v.id == 2 then
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
    print("check Magic Dead", left, right)
    return true, left, right
end

--根据findNearEnemy 的结果来做即可
function FightLayer2:getRightHead()
    local eneList = {}
    table.insert(eneList, self.eneSoldiers)
    table.insert(eneList, self.eneMagicSoldiers)
    table.insert(eneList, self.eneArrowSoldiers)
    table.insert(eneList, self.eneCavalrySoldiers)

    local minX = nil 
    for ek, ev in ipairs(eneList) do
        for k, v in ipairs(ev) do
            for ck, cv in ipairs(v) do
                if not cv.dead then
                    --setColor(cv.changeDirNode, {255, 0, 0})
                    return getPos(cv.bg)[1]
                end
            end
        end
    end
end

--从头开始计算列
function FightLayer2:getLeftHead()
    local eneList = {}
    table.insert(eneList, self.mySoldiers)
    table.insert(eneList, self.myMagicSoldiers)
    table.insert(eneList, self.myArrowSoldiers)
    table.insert(eneList, self.myCavalrySoldiers)

    for ek, ev in ipairs(eneList) do
        for k, v in ipairs(ev) do
            for ck, cv in ipairs(v) do
                if not cv.dead then
                    if DEBUG_FIGHT then
                        setColor(cv.changeDirNode, {255, 0, 0})
                    end
                    return getPos(cv.bg)[1]
                end
            end
        end
    end
end

function FightLayer2:getLeftArrowHead()
    for k, v in ipairs(self.myArrowSoldiers) do
        for ck, cv in ipairs(v) do
            if not cv.dead then
                return getPos(cv.bg)[1]
            end
        end
    end
end
function FightLayer2:getRightArrowHead()
    for k, v in ipairs(self.eneArrowSoldiers) do
        for ck, cv in ipairs(v) do
            if not cv.dead then
                if DEBUG_FIGHT then
                    setColor(cv.changeDirNode, {255, 0, 0})
                end
                return getPos(cv.bg)[1]
            end
        end
    end
end

function FightLayer2:magicScript(diff)
    if self.passTime == 0 then
        print("magicScript", self.day, diff)
        local ad, left, right = self:checkOneMagicDead()
        if left == 0 and right == 0 then
            self.day = 1
            return
        end

        local p
        if self.leftCamera.startPoint ~= nil then
            p = copyTable(self.leftCamera.startPoint)
        else
            p = getPos(self.battleScene)
        end

        local vs = getVS()
        --快速回到 双方部队头部
        --这种类型部队的头部
        if left == 0 then
            --self.moveTarget = -(self.leftWidth-(vs.width/2-FIGHT_HEAD_OFF)) 
            self:showLeftCamera()
            --self.leftCamera:fastMoveTo(p, self.moveTarget) 
            self.leftCamera:fastMoveTo(p, -(self:getLeftHead()+FIGHT_OFFX-vs.width/2)) 
        else
            local fw = #self.myFootNum*FIGHT_OFFX
            local bp = self.leftWidth-fw
            --该种士兵的第一行的头部加上 一定偏移值 第一排要显示完全
            self.moveTarget = -(bp-(vs.width/2-FIGHT_HEAD_OFF))
            print("self.leftWidth ", self.moveTarget)
            self:showLeftCamera() 
            --快速移动到 镜头到场景某个位置 同时 修正 battleScene 中相关对象的位置
            --然后恢复场景位置
            self.leftCamera:fastMoveTo(p, self.moveTarget) 
        end
        --右侧没有魔法师则显示右侧敌方部队当前的头部
        if right == 0 then
            self:showRightCamera()
            --self.rightCamera:fastMoveTo({p[1]-vs.width/2-2, p[2]}, -(self.WIDTH-self.rightWidth-FIGHT_HEAD_OFF)) 
            self.rightCamera:fastMoveTo({p[1]-vs.width/2-2, p[2]}, -(self:getRightHead()-FIGHT_OFFX)) 
        else
            --右侧镜头位置当前屏幕的左侧
            self:showRightCamera()
            local fw = #self.eneFootNum*FIGHT_OFFX
            local ahead = self.WIDTH-self.rightWidth+fw
            self.rightCamera:fastMoveTo({p[1]-vs.width/2-2, p[2]}, -(ahead-FIGHT_HEAD_OFF))
        end
    end

    self.passTime = self.passTime+diff

    --两个镜头已经分离了再合并
    --判断两个镜头的 动作
    --暂时不要镜头动作
    if self.leftCamera.startPoint ~= nil and self.rightCamera.startPoint ~= nil then
        local vs = getVS()
        local ls = -self.leftCamera.startPoint[1]
        local rs = -self.rightCamera.startPoint[1]
        local lw = self.leftCamera.width
        local rw = self.rightCamera.width
        local lp = getPos(self.leftCamera.renderTexture)
        local rp = getPos(self.rightCamera.renderTexture)
        print("magic leftCamera rightCamera", ls, rs, lw, rw, simple.encode(lp), simple.encode(rp))
        --当一方没有 魔法师剩余的时候 则 等待另外一侧镜头到达屏幕中央则 clone这个镜头即可
        local left, right = self:checkMagic()
        --只有单侧士兵
        --左侧没有弓箭手
        --战场中心不是 WIDTH/2 而是 LEFTWIDHT + vs.width*1.5/2 的位置
        local bmid = self.leftWidth+vs.width*1.5/2
        if not left then
            print("magic left not arrow rightCamera ", rs, bmid, self.WIDTH/2, self.WIDTH/2-vs.width/2, self.mergeYet, self.clone)
            if not self.mergeYet then
                --[[
                if rs <= bmid and rs > bmid-vs.width/2 then
                    print("magic no left arrow so merge Right Camera ")
                    self:mergeRightCamera()
                end
                --]]

                if ls < rs+rw and ls+lw > rs then
                    self:mergeCamera()
                end
            else
                --[[
                if rs <= bmid-vs.width/2 then
                    print("magic no left arrow begin clone Right Camera")
                    self:cloneRightCamera()
                end
                --]]
            end
        --右侧没有士兵则镜头相交则合并 
        elseif not right then
            if not self.mergeYet then
                --[[
                if (ls+lw) >= bmid and (ls+lw) < bmid+vs.width/2 then
                    self:mergeCamera()
                end
                --]]
                if ls < rs+rw and ls+lw > rs then
                    self:mergeCamera()
                end
            else
                --并不clone 直接攻击即可
                --[[
                if (ls+lw) >= bmid+vs.width/2 then
                    self:cloneLeftCamera()
                end
                --]]
            end
        else
            --镜头相交
            if not self.mergeYet then
                if ls < rs+rw and ls+lw > rs then
                    self:mergeCamera()
                end
            end
            --拆分镜头 交错弓箭镜头
            if self.mergeYet then
                if ls > rs+rw or ls+lw < rs then
                    self:splitCamera()
                end
            end
        end
    end

    --镜头移动到目标位置
    print("magic leftCamera ", self.leftCamera.startPoint[1], self.leftCamera.moveTarget)
    if not self.animateYet and math.abs(self.leftCamera.startPoint[1]-self.leftCamera.moveTarget) < 5 then
        self.animateYet = true
        for k, v in ipairs(self.allSoldiers) do
            --开始跑步和攻击
            v:doRunAndAttack(self.day)
        end
    end

    if self.arrow ~= nil or self.rightArrow ~= nil then
        if not self.arrowOver then
            print("magic check arrow Over one arrow dead", self.arrow, self.rightArrow, self.arrowOver)
            --双方 弓箭都死亡了 才行的
            if self.arrow ~= nil and self.arrow.dead then
                print("left Arrow dead", self.arrow.mid)
                self.arrow = nil
                --需要清理双方的 弓箭
                self.rightArrow = nil
                self.arrowOver = true
                
                for k, v in ipairs(self.allSoldiers) do
                    v:finishAttack()
                end
                --进入分屏幕状态 下一个 回合
                self.bg:runAction(sequence({delaytime(2), callfunc(self, self.finishMagic)}))
            elseif self.rightArrow ~= nil and self.rightArrow.dead then
                print("right Arrow dead", self.rightArrow.mid)
                self.rightArrow = nil
                self.arrow = nil
                self.arrowOver = true
                for k, v in ipairs(self.allSoldiers) do
                    v:finishAttack()
                end
                self.bg:runAction(sequence({delaytime(2), callfunc(self, self.finishMagic)}))
            end
            print("magic over", self.arrowOver)
        end
    end
    if self.clone then
        print("start clone", self.cloneWho)
        --clone 镜头要逐渐修改不能突然移动
        if self.cloneWho == 0 then
            print("magic clone set left camera move target ")
            self.mainCamera.moveTarget = self.leftCamera.moveTarget 
            self.mainCamera.startPoint = copyTable(self.leftCamera.startPoint)
        else
            print("magic clone set right camera move")
            self.mainCamera.moveTarget = self.rightCamera.moveTarget
            self.mainCamera.startPoint = copyTable(self.rightCamera.startPoint)
        end
    end
end


function FightLayer2:cavalryScript(diff)
    if self.passTime == 0 then
        print("cavalryScript", self.day, diff)
        local ad, left, right = self:checkOneCavalryDead()
        if left == 0 and right == 0 then
            self.day = 0
            --最后一天显示day
            self.state = FIGHT_STATE.SHOW_DAY
            return
        end

        local p = getPos(self.battleScene)
        local vs = getVS()
        --快速回到 双方部队头部
        --这种类型部队的头部
        if left == 0 then
            self.moveTarget = -(self.leftWidth-(vs.width/2-FIGHT_HEAD_OFF)) 
            self:showLeftCamera()
            self.leftCamera:fastMoveTo(p, self.moveTarget) 
        else
            local fw = (#self.myArrowNum+#self.myMagicNum+#self.myFootNum)*FIGHT_OFFX
            local bp = self.leftWidth-fw
            --该种士兵的第一行的头部加上 一定偏移值 第一排要显示完全
            self.moveTarget = -(bp-(vs.width/2-FIGHT_HEAD_OFF))
            print("self.leftWidth ", self.moveTarget)
            self:showLeftCamera() 
            --快速移动到 镜头到场景某个位置 同时 修正 battleScene 中相关对象的位置
            --然后恢复场景位置
            self.leftCamera:fastMoveTo(p, self.moveTarget) 
        end

        if right == 0 then
            self:showRightCamera()
            self.rightCamera:fastMoveTo({p[1]-vs.width/2-2, p[2]}, -(self.WIDTH-self.rightWidth-FIGHT_HEAD_OFF)) 
        else
            --右侧镜头位置当前屏幕的左侧
            self:showRightCamera()
            local fw = (#self.eneFootNum+#self.eneMagicNum+#self.eneArrowNum)*FIGHT_OFFX
            local ahead = self.WIDTH-self.rightWidth+fw
            self.rightCamera:fastMoveTo({p[1]-vs.width/2-2, p[2]}, -(ahead-FIGHT_HEAD_OFF))
        end
    end

    self.passTime = self.passTime+diff
    
    --骑兵开始移动
    local ls = self.leftCamera.startPoint[1]
    --镜头移动移动到目标位置了 则播放跑步动画
    if math.abs(ls-self.leftCamera.moveTarget) < 5 then
        if not self.skillYet then
            self.skillYet = true
            self:initSkill()
        end
        if self.skillOver and not self.animateYet then
            self.animateYet = true
            for k, v in ipairs(self.allSoldiers) do
                --开始跑步和攻击
                v:doRunAndAttack(self.day)
            end
        end
    end

    --模仿trace 步兵  merge 
    --模仿弓箭 split
    if self.leftCamera.startPoint ~= nil and self.rightCamera.startPoint ~= nil and not self.finishAttack and self.skillYet then
        local vs = getVS()
        local ls = -self.leftCamera.startPoint[1]
        local rs = -self.rightCamera.startPoint[1]
        local lw = self.leftCamera.width
        local rw = self.rightCamera.width
        local lp = getPos(self.leftCamera.renderTexture)
        local rp = getPos(self.rightCamera.renderTexture)
        print("magic leftCamera rightCamera", ls, rs, lw, rw, simple.encode(lp), simple.encode(rp))
        --当一方没有 魔法师剩余的时候 则 等待另外一侧镜头到达屏幕中央则 clone这个镜头即可
        local left, right = self:checkCavalry()
        --只有单侧士兵
        --左侧没有弓箭手
        --战场中心不是 WIDTH/2 而是 LEFTWIDHT + vs.width*1.5/2 的位置
        local bmid = self.leftWidth+vs.width*1.5/2
        --因为我的镜头没有放到屏幕中心而是放到了对方部队的头部
        --骑兵只有冲过去才合并镜头
        if not left then
            print("magic left not arrow rightCamera ", rs, bmid, self.WIDTH/2, self.WIDTH/2-vs.width/2, self.mergeYet, self.clone)
            if not self.mergeYet then
                --[[
                if rs <= bmid and rs > bmid-vs.width/2 then
                    print("magic no left arrow so merge Right Camera ")
                    self:mergeRightCamera()
                end
                --]]

                if ls < rs+rw and ls+lw > rs then
                    self:mergeCamera()
                end
            else
                --[[
                if rs <= bmid-vs.width/2 then
                    print("magic no left arrow begin clone Right Camera")
                    self:cloneRightCamera()
                end
                --]]
            end
        elseif not right then
            if not self.mergeYet then
                --[[
                if (ls+lw) >= bmid and (ls+lw) < bmid+vs.width/2 then
                    self:mergeCamera()
                end
                --]]

                if ls < rs+rw and ls+lw > rs then
                    self:mergeCamera()
                end
            else
                --[[
                if (ls+lw) >= bmid+vs.width/2 then
                    self:cloneLeftCamera()
                end
                --]]
            end
        else
            --镜头相交
            if not self.mergeYet then
                if ls < rs+rw and ls+lw > rs then
                    self:mergeCamera()
                end
            end
            --拆分镜头 交错弓箭镜头
            if self.mergeYet then
                if ls > rs+rw or ls+lw < rs then
                    self:splitCamera()
                end
            end
        end

    end

    --骑兵全部死亡 或者 骑兵 都 waitBack 了 则 骑兵回合准备结束
    local allW = self:cavalryAllWait()
    local footDead, left, right = self:checkOneCavalryDead()
    print("all Wait cavalry dead", allW, footDead)
    if (allW or (left == 0 and right == 0)) and not self.finishAttack then
        local oneDead = self:checkOneDead()
        self.finishAttack = true
        for k, v in ipairs(self.allSoldiers) do
            v.funcSoldier:finishAttack(oneDead)
        end
        self.bg:runAction(sequence({delaytime(2), callfunc(self, self.finishCavalry)}))
    end


    --模仿 步兵 追踪士兵
    if not self.finishAttack and self.animateYet then
        print("trace cavalry", self.mySol, self.eneSol)
        --从外列 逐行搜索
        if self.mySol == nil or self.mySol.dead then
            self.mySol = self:findMyRightMostCavalry()
        end
        if self.mySol ~= nil then
            if DEBUG_FIGHT then
                setColor(self.mySol.changeDirNode, {0, 255, 0})
            end
            self.leftCamera:trace(self.mySol, FIGHT_OFFX*3)
        end
        --寻找影子步兵
        --local sp = getPos(mySol.bg)
        --local vs = getVS()
        --看一下4对象的位置
        --查看一下 当前最前端的步兵的 位置 如果步兵死亡了 那么 就使用影子步兵来移动
        --shadow 所有步兵移动都会 影响 
        if self.eneSol == nil or self.eneSol.dead then
            self.eneSol = self:findEneLeftCavalry()
        end
        if self.eneSol ~= nil then
            if DEBUG_FIGHT then
                setColor(self.eneSol.changeDirNode, {0, 255, 0})
            end
            self.rightCamera:trace(self.eneSol, -FIGHT_OFFX*3)
        end
    end
    if self.clone then
        print("start clone", self.cloneWho)
        if self.cloneWho == 0 then
            print("cavalry clone left camera", self.leftCamera.cid, self.leftCamera.moveTarget, simple.encode(self.leftCamera.startPoint))
            print("self right", self.rightCamera.moveTarget, simple.encode(self.rightCamera.startPoint))
            --local vs = getVS()
            --相对于左侧镜头 有半个屏幕的偏移
            self.mainCamera.moveTarget = self.leftCamera.moveTarget+self.mainCamera.mainOff
            --self.mainCamera.startPoint = copyTable(self.leftCamera.startPoint)
        else
            print("foot clone right camera")
            self.mainCamera.moveTarget = self.rightCamera.moveTarget+self.mainCamera.mainOff
            --self.mainCamera.startPoint = copyTable(self.rightCamera.startPoint)
        end
    end
end

--屏幕左侧宽度 要是 保证最后面的有半个屏幕可以显示 至少 
--当前最后面的 是弓箭手
--当前的命令队列 cmdList 解释命令 执行命令  
function FightLayer2:arrowScript(diff)
    if self.passTime == 0 then
        print("arrowScript")
        local ad, left, right = self:checkOneArrowDead()
        if left == 0 and right == 0 then
            self.day = 2
            return
        end

        --local p = getPos(self.battleScene)
        local p
        if self.leftCamera.startPoint ~= nil then
            p = copyTable(self.leftCamera.startPoint)
        else
            p = getPos(self.battleScene)
        end

        local vs = getVS()
        if left == 0 then
            --self.moveTarget = -(self.leftWidth-(vs.width/2-FIGHT_HEAD_OFF)) 
            self:showLeftCamera()
            --self.leftCamera:fastMoveTo(p, self.moveTarget) 
            self.leftCamera:fastMoveTo(p, -(self:getLeftHead()+FIGHT_OFFX-vs.width/2)) 
        else
            --local fw = (#self.myMagicNum+#self.myFootNum)*FIGHT_OFFX
            --local bp = self.leftWidth-fw
            --该种士兵的第一行的头部加上 一定偏移值 第一排要显示完全
            --self.moveTarget = -(bp-(vs.width/2-FIGHT_HEAD_OFF))
            --print("self.leftWidth ", self.moveTarget)
            self:showLeftCamera() 
            --快速移动到 镜头到场景某个位置 同时 修正 battleScene 中相关对象的位置
            --然后恢复场景位置
            --self.leftCamera:fastMoveTo(p, self.moveTarget) 
            self.leftCamera:fastMoveTo(p, -(self:getLeftArrowHead()+FIGHT_OFFX-vs.width/2)) 
        end
        if right == 0 then
            self:showRightCamera()
            --self.rightCamera:fastMoveTo({p[1]-vs.width/2-2, p[2]}, -(self.WIDTH-self.rightWidth-FIGHT_HEAD_OFF)) 
            self.rightCamera:fastMoveTo({p[1]-vs.width/2-2, p[2]}, -(self:getRightHead()-FIGHT_OFFX)) 
        else
            --右侧镜头位置当前屏幕的左侧
            self:showRightCamera()
            --local fw = (#self.eneFootNum+#self.eneMagicNum)*FIGHT_OFFX
            --local ahead = self.WIDTH-self.rightWidth+fw
            --self.rightCamera:fastMoveTo({p[1]-vs.width/2-2, p[2]}, -(ahead-FIGHT_HEAD_OFF))
            self.rightCamera:fastMoveTo({p[1]-vs.width/2-2, p[2]}, -(self:getRightArrowHead()-FIGHT_OFFX))
        end
    end
    self.passTime = self.passTime+diff
    --两个镜头已经分离了再合并
    if self.leftCamera.startPoint ~= nil and self.rightCamera.startPoint ~= nil and self.skillYet then
        local vs = getVS()
        local ls = -self.leftCamera.startPoint[1]
        local rs = -self.rightCamera.startPoint[1]
        local lw = self.leftCamera.width
        local rw = self.rightCamera.width
        local lp = getPos(self.leftCamera.renderTexture)
        local rp = getPos(self.rightCamera.renderTexture)
        print("leftCamera rightCamera", ls, rs, lw, rw, simple.encode(lp), simple.encode(rp))
        --当一方没有 弓箭手剩余的时候 则 等待另外一侧镜头到达屏幕中央则 clone这个镜头即可
        local left, right = self:checkArrow()
        --只有单侧士兵
        --左侧没有弓箭手
        --战场中心不是 WIDTH/2 而是 LEFTWIDHT + vs.width*1.5/2 的位置
        local bmid = self.leftWidth+vs.width*1.5/2
        --当一方没有弓箭的时候 进行合并
        if not left then
            print("left not arrow rightCamera ", rs, bmid, self.WIDTH/2, self.WIDTH/2-vs.width/2, self.mergeYet, self.clone)
            if not self.mergeYet then
                --[[
                if rs <= bmid and rs > bmid-vs.width/2 then
                    print("no left arrow so merge Right Camera ")
                    self:mergeRightCamera()
                end
                --]]
                if ls < rs+rw and ls+lw > rs then
                    self:mergeCamera()
                end
            else
                --[[
                if rs <= bmid-vs.width/2 then
                    print("no left arrow begin clone Right Camera")
                    self:cloneRightCamera()
                end
                --]]
            end
        elseif not right then
            if not self.mergeYet then
                --[[
                if (ls+lw) >= bmid and (ls+lw) < bmid+vs.width/2 then
                    self:mergeCamera()
                end
                --]]
                if ls < rs+rw and ls+lw > rs then
                    self:mergeCamera()
                end
            else
                --[[
                if (ls+lw) >= bmid+vs.width/2 then
                    self:cloneLeftCamera()
                end
                --]]
            end
        else
            --镜头相交
            if not self.mergeYet then
                if ls < rs+rw and ls+lw > rs then
                    self:mergeCamera()
                end
            end
            --拆分镜头 交错弓箭镜头
            if self.mergeYet then
                if ls > rs+rw or ls+lw < rs then
                    self:splitCamera()
                end
            end
        end
    end

    --如何制作一个合体的镜头呢？
    --进入 动画状态
    local p = getPos(self.battleScene)
    --print("battleScene pos and moveTarget", p[1], self.moveTarget)
    if math.abs(self.leftCamera.startPoint[1]-self.leftCamera.moveTarget) < 5 then
        if not self.skillYet then
            self.skillYet = true
            self:initSkill()
        end
        if self.skillOver and not self.animateYet then
            self.animateYet = true
            for k, v in ipairs(self.allSoldiers) do
                --开始跑步和攻击
                v:doRunAndAttack(self.day)
            end
            print("arrow animation state doRunAndAttack", self.animateYet)
        end
    end

    --trace Arrow 位置
    if self.arrow ~= nil or self.rightArrow ~= nil then
        if not self.arrowOver then
            print("check arrow Over one arrow dead", self.arrow, self.rightArrow, self.arrowOver)
            if self.arrow ~= nil and self.arrow.dead then
                print("left Arrow dead")
                self.arrow = nil
                --需要清理双方的 弓箭
                self.rightArrow = nil
                self.arrowOver = true
                --进入分屏幕状态 下一个 回合
                for k, v in ipairs(self.allSoldiers) do
                    v:finishAttack()
                end
                self.bg:runAction(sequence({delaytime(2), callfunc(self, self.finishArrow)}))
            elseif self.rightArrow ~= nil and self.rightArrow.dead then
                print("right Arrow dead")
                self.rightArrow = nil
                self.arrow = nil
                self.arrowOver = true
                for k, v in ipairs(self.allSoldiers) do
                    v:finishAttack()
                end
                self.bg:runAction(sequence({delaytime(2), callfunc(self, self.finishArrow)}))
            end
            print("arrow over", self.arrowOver)
        end
    end
    if self.clone then
        print("start clone", self.cloneWho)
        --clone 镜头要逐渐修改不能突然移动
        if self.cloneWho == 0 then
            print("clone set left camera move target ")
            self.mainCamera.moveTarget = self.leftCamera.moveTarget 
            self.mainCamera.startPoint = copyTable(self.leftCamera.startPoint)
        else
            print("clone set right camera move")
            self.mainCamera.moveTarget = self.rightCamera.moveTarget
            self.mainCamera.startPoint = copyTable(self.rightCamera.startPoint)
        end
    end
end
function FightLayer2:finishMagic()
    print("finish Magic")

    self:clearMenu()
    local ret, left, right = self:oneFail()
    if ret then
    else
        --进入步兵开始状态 屏幕分割 和 屏幕设定位置

        self.day = 1
        self:clearState()
    end
end
function FightLayer2:clearState()
    self.skillOver = false
    self.arrowOver = false
    self.skillYet = false
    self.animateYet = false
    self.passTime = 0
    self.skillEffect = nil
    self.finishAttack = false

    self.mySol = nil
    self.eneSol = nil
    self:clearAllCamera()
    --重新初始化 被动状态 因为英雄可能被杀掉了
    self:initPassivitySkill()
end
--进入步兵回合 
--插入好多动作
function FightLayer2:finishArrow()
    print("finish Arrow")
    --self.day = 1
    --左侧屏幕宽度 第一排 步兵的位置
    --游戏开始就记录了步兵的位置
    self:clearMenu()
    local ret, left, right = self:oneFail()
    if ret then
    else
        --进入步兵开始状态 屏幕分割 和 屏幕设定位置
        self.day = 2
        self:clearState()
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
                if DEBUG_FIGHT then
                    setColor(self.arrow.changeDirNode, {255, 255, 0})
                end
                self.arrow = arr
                if DEBUG_FIGHT then
                    setColor(self.arrow.changeDirNode, {0, 255, 255})
                end
            else
            end
        else
            self.arrow = arr
            if DEBUG_FIGHT then
                setColor(self.arrow.changeDirNode, {0, 255, 255})
            end
        end
        --startPoint 应该
        self.leftCamera:trace(self.arrow, 200)
    else
        if self.rightArrow ~= nil then
            local ap = getPos(self.rightArrow.bg)
            local np = getPos(arr.bg)
            if np[1] < ap[1] then
                if DEBUG_FIGHT then
                    setColor(self.rightArrow.changeDirNode, {255, 255, 0})
                end
                self.rightArrow = arr
                if DEBUG_FIGHT then
                    setColor(self.rightArrow.changeDirNode, {0, 255, 255})
                end
            end
        else
            self.rightArrow = arr
            if DEBUG_FIGHT then
                setColor(self.rightArrow.changeDirNode, {0, 255, 255})
            end
        end
        print("right traceing")
        self.rightCamera:trace(self.rightArrow, -200)
    end
end
