FuncBuild = class()
function FuncBuild:ctor(b)
    self.baseBuild = b
end
function FuncBuild:initView()
    local bd = Logic.buildings[self.baseBuild.id]
    local sz = self.baseBuild.changeDirNode:getContentSize()
    setPos(setAnchor(self.baseBuild.changeDirNode, {248.8/sz.width, (sz.height-236)/sz.height}), {0, SIZEY})
end

function FuncBuild:handleTouchEnded()
end
function FuncBuild:clearEffect()
end
function FuncBuild:doEffect()
end
function FuncBuild:adjustRoad()
end
function FuncBuild:finishBuild()
    --finishMove 没有生效 则 finishBuild生效
    --not self.baseBuild.moveYet and
    --不管移动是否 建造结束都要 生效
    if self.baseBuild.data ~= nil and (self.baseBuild.data.kind == 0 or self.baseBuild.data.kind == 5) then
        print("House finish Build", self.baseBuild.data.kind, self.baseBuild.productNum)
        self.baseBuild:doMyEffect()
    end
end
function FuncBuild:beginBuild()
end
function FuncBuild:clearBuildEffect()
    --第一次移动没有效果所以不清除 没有在建造状态中
    if self.baseBuild.state == BUILD_STATE.FREE then
        self.baseBuild:clearMyEffect()
    end
end
function FuncBuild:beginMove()
end
function FuncBuild:finishMove()
    --[[
    if self:checkBuildable() then
        self.baseBuild:doMyEffect()
    end
    --]]
end

function FuncBuild:removeSelf()
    --卖出建筑物 不用清理 自己的效果了
end

function FuncBuild:setBuyer(b)
end
function FuncBuild:clearBuyer(b)
end
function FuncBuild:setWorker(b)
end
function FuncBuild:clearWorker(b)
end
function FuncBuild:initWork()
end
function FuncBuild:whenColNow()
    if self.baseBuild.colNow == 1 then
        addBanner("该位置有冲突")
    end
end
function FuncBuild:setColor()
end
function FuncBuild:checkFinish()
end

function FuncBuild:canFinish()
    return true
end
function FuncBuild:checkBuildable()
    print("checkBuildable", self.baseBuild.colNow)
    return self.baseBuild.colNow == 0
end
function FuncBuild:clearMenu()
    print("try to clear Menu", self.baseBuild.colNow, self.selGrid)
    if self.selGrid ~= nil then
        removeSelf(self.selGrid)
        self.baseBuild.changeDirNode:stopAllActions()
        setColor(self.baseBuild.changeDirNode, {255, 255, 255})
        self.selGrid = nil
        
        --local curMap = getBuildMap(self.baseBuild)
        if not self:checkBuildable() then
            self.baseBuild.map.mapGridController:clearMap(self.baseBuild)
            local np = getPos(self.baseBuild.bg)
            self.baseBuild:setPos(self.baseBuild.oldPos)
            self.baseBuild:setDir(self.baseBuild.oldDir)
            self.baseBuild.map.mapGridController:updateMap(self.baseBuild)
            self:adjustHeight()
            --确定最后冲突的原因是什么 是因为移动还是因为 旋转方向
            
            --[[
            if self.baseBuild.colNow == 1 then
                self.baseBuild:doSwitch()
            end
            --]]

            --清理冲突 调整周围道路的value
            self.baseBuild.colNow = 0
            self:finishMove()
            self:doEffect()
            --移动建筑物 如果清理过状态 则重新计算效果
            if self.baseBuild.state == BUILD_STATE.FREE then
                if self.baseBuild.clearYet then
                    self.baseBuild.clearYet = false
                    self.baseBuild:doMyEffect()
                end
            else
                self.baseBuild:doMyEffect()
            end

            setPos(self.baseBuild.bg, np)
            self.baseBuild.bg:runAction(sequence({moveto(0.2, self.baseBuild.oldPos[1], self.baseBuild.oldPos[2])}))
        --移动结束 恢复效果
        else
            self:doEffect()
            --移动建筑物 如果清理过状态 则 重新计算效果
            if self.baseBuild.state == BUILD_STATE.FREE then
                if self.baseBuild.clearYet then
                    self.baseBuild.clearYet = false
                    self.baseBuild:doMyEffect()
                end
            else
                self.baseBuild:doMyEffect()
            end
        end
        if #global.director.stack > 0 then
            global.director:popView()
        end
        --getPosMap(self.baseBuild.sx, self.baseBuild.sy)    

        --deleted = true
        --构建一个新的建筑物 放在相同的位置  告诉所有的猫我被移动了 大家就要把我从allBuilding 里面删除掉
        --当前所有正在向这个建筑物移动的人 来确认建筑物 moved 移动了 
        --每只猫都hold 到这个建筑物的oldPos 和 newPos 进行比对 如果不同了 表示建筑物move了 网格 这样就要调整当前的网格
        --self.baseBuild.moved = true
        Event:sendMsg(EVENT_TYPE.ROAD_CHANGED)
        print("finish clear Menu send Msg!!!!!!!!!!!!!")
    end
end
function FuncBuild:detailDialog()
    if self.baseBuild.data.effect > 0 then
        global.director:pushView(DecorInfo.new(self.baseBuild), 1)
    elseif self.baseBuild.id == 28 or self.baseBuild.id == 29 then
        global.director:pushView(DecorInfo.new(self.baseBuild), 1)
    end
end
function FuncBuild:showInfo()
    --先清理旧的
    Event:sendMsg(EVENT_TYPE.SELECT_ME, self.baseBuild)

    local bo = BuildOpMenu.new(self.baseBuild)
    global.director:pushView(bo)

    self.baseBuild.changeDirNode:runAction(repeatForever(sequence({itintto(0.5, 128, 128, 128), itintto(0.5, 255, 255, 255)})))
    self.baseBuild.oldPos = getPos(self.baseBuild.bg)
    self:initBottom()
end

function FuncBuild:finishBottom()
    if self.selGrid ~= nil then
        removeSelf(self.selGrid)
        self.selGrid = nil
    end
end
function FuncBuild:initBottom()
    if self.selGrid == nil then
        self.selGrid = setAnchor(setPos(CCSprite:create("newBlueGrid.png"), {0, (self.baseBuild.sx+self.baseBuild.sy)/2*SIZEY}), {0.5, 0.5})
        self.baseBuild.heightNode:addChild(self.selGrid, -1)
    end
    --[[
    self.baseBuild.bottom = setSize(setAnchor(setPos(CCSprite:create("white2.png"), {0, (self.baseBuild.sx+self.baseBuild.sy)/2*SIZEY}), {0.5, 0.5}), {(self.baseBuild.sx+self.baseBuild.sy)*SIZEX+20, (self.baseBuild.sx+self.baseBuild.sy)*SIZEY+10})
    self.baseBuild.heightNode:addChild(self.baseBuild.bottom, 1)
    --]]
end
function FuncBuild:setBottomColor(c)
    if self.selGrid ~= nil then
        print("setBottomColor", c)
        if c == 0 then
            setTexture(self.selGrid, "newRedGrid.png")
        else
            setTexture(self.selGrid, "newBlueGrid.png")
        end
    end
    --self:setColor()
    --[[
    if c == 0 then
        setColor(self.baseBuild.bottom, {255, 0, 0})
    else
        setColor(self.baseBuild.bottom, {0, 255, 0})
    end
    --]]
end
function FuncBuild:doSwitch()
end
function FuncBuild:takeTool()
end
function FuncBuild:putTool()
end
function FuncBuild:updateStage(diff)
end
function FuncBuild:updateState()
end
function FuncBuild:updateGoods()
end
function FuncBuild:setPos()
    self:adjustHeight()
end

function FuncBuild:adjustHeight()
    local p = getPos(self.baseBuild.bg)
    local ax, ay = newCartesianToAffine(p[1], p[2], self.baseBuild.map.scene.width, self.baseBuild.map.scene.height, MapWidth/2, FIX_HEIGHT)
    print("adjust Road Height !!!!!!!!!!!!!!!!!!!!!!!!!", ax, ay)
    local hei = adjustNewHeight(self.baseBuild.map.scene.mask, self.baseBuild.map.scene.width, ax, ay)
    setPos(self.baseBuild.heightNode, {0, hei*103})
end

function delayShow(sp, w)
    sp.bg:setVisible(false)
    local function showSelf()
        sp.bg:setVisible(true)
        sp.sp:runAction(sequence({fadein(0.2), fadeout(0.8)}))
    end
    return sequence({delaytime(w), callfunc(nil, showSelf)})
end
--实现这个接口 用于调整效果
function FuncBuild:showIncrease(n, waitTime)
    if self.baseBuild.data.showInc == 0 then
        return
    end
    if waitTime == nil then
        waitTime = 0
    end

    local sp = ui.newButton({image="info.png", conSize={100, 45}, text=self:getIncWord().." +"..n, color={0, 0, 0}, size=25})
    self.baseBuild.map.bg:addChild(sp.bg)
    local wp = self.baseBuild.heightNode:convertToWorldSpace(ccp(0, 100))
    local np = self.baseBuild.map.bg:convertToNodeSpace(wp)
    setPos(sp.bg, {np.x, np.y})


    sp.bg:runAction(sequence({delayShow(sp, waitTime), moveby(1, 0, 20), callfunc(nil, removeSelf, sp.bg)}))
    self.baseBuild.productNum = self.baseBuild.productNum+n
end
function FuncBuild:showDecrease(n, waitTime)
    if self.baseBuild.data.showInc == 0 then
        return
    end
    if waitTime == nil then
        waitTime = 0
    end
    local sp = ui.newButton({image="info.png", conSize={100, 45}, text=self:getIncWord().." -"..n, color={102, 10, 10}, size=25})
    self.baseBuild.map.bg:addChild(sp.bg)
    local wp = self.baseBuild.heightNode:convertToWorldSpace(ccp(0, 100))
    local np = self.baseBuild.map.bg:convertToNodeSpace(wp)
    setPos(sp.bg, {np.x, np.y})
    sp.bg:runAction(sequence({delayShow(sp, waitTime), moveby(1, 0, 20), callfunc(nil, removeSelf, sp.bg)}))
    self.baseBuild.productNum = self.baseBuild.productNum-n
end

function FuncBuild:getIncWord()
    return "null" 
end


function FuncBuild:getProductName()
    return "--"
end
function FuncBuild:getProductPrice()
    return "--"
end
function FuncBuild:setOwner(s)
end
function FuncBuild:enterStore(s)
    self.inMerchant = s
end
function FuncBuild:exitStore()
    self.inMerchant = nil
end
function FuncBuild:setOperatable()
end
