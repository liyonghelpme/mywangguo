require "Miao.MiaoBuild"
require "Miao.MiaoBuildLayer"
MiaoPage = class()
function MiaoPage:ctor(s)
    self.scene = s
    self.bg = CCLayer:create()
    setContentSize(self.bg, {MapWidth, MapHeight})
    local col = math.ceil(MapWidth/256)
    local row = math.ceil(MapHeight/192)
    local offX = 256
    local offY = 192
    local bat = CCSpriteBatchNode:create("grasstile.png")
    self.bat = bat
    self.bg:addChild(bat)
    for i = 0, row-1, 1 do
        for j =0, col-1, 1 do
            local temp = CCSprite:create("grasstile.png")
            self.bat:addChild(temp)
            setAnchor(setPos(temp, {j*offX, i*offY}), {0, 0})
        end
    end

    self.touchDelegate = StandardTouchHandler.new()
    self.touchDelegate.bg = self.bg
    self.blockMove = false
    
    self.buildLayer = MiaoBuildLayer.new(self)
    self.bg:addChild(self.buildLayer.bg)

    registerEnterOrExit(self)
    registerMultiTouch(self)
    self.touchDelegate:scaleToMax(1)
end

function MiaoPage:enterScene()
    Event:registerEvent(EVENT_TYPE.DO_MOVE, self)
    Event:registerEvent(EVENT_TYPE.FINISH_MOVE, self)
end
function MiaoPage:exitScene()
    Event:unregisterEvent(EVENT_TYPE.DO_MOVE, self)
    Event:unregisterEvent(EVENT_TYPE.FINISH_MOVE, self)
end

function MiaoPage:receiveMsg(name, msg)
    if name == EVENT_TYPE.DO_MOVE then
        self.blockMove = true
    elseif name == EVENT_TYPE.FINISH_MOVE then
        self.blockMove = false
    end
end

--移动move 
--点击某个建筑物 进入移动状态 
--原地还有这个建筑物 不过 新的 替换成了这个建筑物 的 图像 可以移动 桥梁 普通建筑物   道路不能移动
function MiaoPage:touchesBegan(touches)
    self.touchBuild = nil
    self.lastPos = convertMultiToArr(touches)
    if self.lastPos.count == 1 then
        local tp = self.buildLayer.bg:convertToNodeSpace(ccp(self.lastPos[0][1], self.lastPos[0][2]))
        tp.y = tp.y-SIZEY
        local allCell = self.buildLayer.mapGridController.mapDict
        local map = getPosMap(1, 1, tp.x, tp.y)
        local key = getMapKey(map[3], map[4])
        --点击到某个建筑物
        if allCell[key] ~= nil then
            --如果在移动状态 点击某个建筑物 那么 选中的是 Move 的建筑物
            --移动地图 和 单纯的点击 地图
            --if self.curBuild ~= nil and self.curBuild.picName == 'move' then
            --    self.touchBuild = self.curBuild
            --    self.touchBuild:touchesBegan(touches)
            --else
            self.touchBuild = allCell[key][#allCell[key]][1]
            self.touchBuild:touchesBegan(touches)
            --end
        end
    end

    if not self.blockMove then
        self.touchDelegate:tBegan(touches)
    end
end
function MiaoPage:touchesMoved(touches)
    if self.touchBuild then
        self.touchBuild:touchesMoved(touches)
    end
    if not self.blockMove then
        self.touchDelegate:tMoved(touches)
    end
end
function MiaoPage:moveToPoint(x, y)
    local wp = self.bg:convertToWorldSpace(ccp(x, y))
    local vs = getVS()
    local dx, dy = vs.width/2-wp.x, vs.height/2-wp.y
    local cp = getPos(self.bg)
    cp[1] = cp[1]+dx
    cp[2] = cp[2]+dy

    local sz = self.bg:getContentSize()
    local mx = math.min(0, cp[1])
    local my = math.min(0, cp[2])
    local sca = self.bg:getScale()
    mx = math.max(mx, vs.width-sz.width*sca)
    my = math.max(my, vs.height-sz.height*sca)
    local function finishMov()
        self.moveAct = nil
    end
    if self.moveAct ~= nil then
        self.bg:stopAction(self.moveAct)
        self.moveAct = nil
    end
    self.moveAct = sequence({moveto(0.2, mx, my), callfunc(nil, finishMov)})
    self.bg:runAction(self.moveAct)
end
function MiaoPage:touchesEnded(touches)
    if not self.blockMove then
        --快速点击 curBuild 移动到 这个点击位置  屏幕移动到中心位置 
        if self.touchDelegate.accMove == nil then

        elseif self.touchDelegate.accMove < 20 then
            --点击移动建筑物 
            if self.curBuild ~= nil and self.curBuild.picName == 'move' then
                self.lastPos = convertMultiToArr(touches)
                --场景没有被缩放的情况下 使用 SIZEY 偏移世界坐标
                --场景缩放了之后 不能使用SIZEY 偏移世界坐标
                local tp = self.buildLayer.bg:convertToNodeSpace(ccp(self.lastPos[0][1], self.lastPos[0][2]))
                tp.y = tp.y-SIZEY
                local np = normalizePos({tp.x, tp.y}, 1, 1)
                self.curBuild:runMoveAction(np[1], np[2])
                self:moveToPoint(np[1], np[2]+SIZEY)
            end
        else
            if self.curBuild ~= nil and self.curBuild.picName == 'move' then
                local vs = getVS()
                local p = self.bg:convertToNodeSpace(ccp(vs.width/2, vs.height/2))
                p = normalizePos({p.x, p.y-SIZEY}, 1, 1)
                self.curBuild:runMoveAction(p[1], p[2])
            end
        end

        self.touchDelegate:tEnded(touches)
    end
    --处理完 blockMove 之后 再清理 blockMove
    if self.touchBuild then
        self.touchBuild:touchesEnded(touches)
    end
end
function MiaoPage:beginBuild(kind, id)
    if self.curBuild == nil then
        local vs = getVS()
        --先确定位置 再加入到 buildLayer里面
        self.curBuild = MiaoBuild.new(self.buildLayer, {picName=kind, id=id}) 
        local p = self.bg:convertToNodeSpace(ccp(vs.width/2, vs.height/2))
        p = normalizePos({p.x, p.y}, 1, 1)
        self.curBuild:setPos(p)
        self.curBuild:setColPos()
        self.curBuild:setState(BUILD_STATE.MOVE)
        self.buildLayer:addBuilding(self.curBuild, MAX_BUILD_ZORD)
        --调整bottom 冲突状态
        self.curBuild:setColPos()
        
        Logic.paused = true
    end
    return self.curBuild
end
function MiaoPage:addPeople(param)
    self.buildLayer:addPeople(param)
end

function MiaoPage:finishBuild()
    if self.curBuild ~= nil then
        print("finishBuild", self.curBuild.picName, self.curBuild.id)
        if self.curBuild.picName == 'move' then
            if self.curBuild.moveTarget == nil then
                self.curBuild:removeSelf()
                self.curBuild = nil
            --取消移动
            else
                self.curBuild:removeSelf()
                self.curBuild = nil
            end
        --道路和 斜坡冲突 斜坡不能移动
        elseif self.curBuild.picName == 't' then
            if self.curBuild.colNow == 0 then
                self.curBuild:finishBuild()
                self.curBuild = nil
            else
                if type(self.curBuild.otherBuild) == 'table' then
                    local ob = self.curBuild.otherBuild
                    --斜坡
                    if ob.picName == 'build' and ob.data.kind == 1 then
                        self.curBuild:finishBuild()
                        self.curBuild = nil
                    else
                        addBanner("道路不能修建在这里！")
                    end
                end
            end
        --矿坑
        elseif self.curBuild.picName == 'build' and self.curBuild.id == 11 then
            if self.curBuild.colNow == 0 then
                addBanner("必须建造到斜坡上面！")
            else
                local ret = false
                if type(self.curBuild.otherBuild) == 'table' then
                    local ob = self.curBuild.otherBuild
                    if ob.picName == 'build' and ob.data.kind == 1 then
                        ret = true
                        self.curBuild:finishBuild()
                        self.curBuild = nil
                    end
                end
                if not ret then
                    addBanner("必须建造到斜坡上面！")
                end
            end
        elseif self.curBuild.picName == 'build' and self.curBuild.id == 3 then
            --桥梁没有冲突
            if self.curBuild.colNow == 0 then
                self.curBuild:finishBuild()
                self.curBuild = nil
            else
                if type(self.curBuild.otherBuild) == 'table' then
                    --地形河流
                    if self.curBuild.otherBuild.picName == 's' then
                        self.curBuild:finishBuild()
                        self.curBuild = nil
                    else
                        addBanner("和其它建筑物冲突啦！")
                    end
                end
            end
        elseif self.curBuild.picName == 'remove' then
            self.curBuild:removeSelf()
            self.curBuild = nil
        elseif self.curBuild.colNow == 0  then
            self.curBuild:finishBuild()
            self.curBuild = nil
        else
            addBanner("和其它建筑物冲突啦！")
        end
        Logic.paused = false
    end
end

function MiaoPage:onRemove()
    if self.curBuild == nil then
        local vs = getVS()
        --先确定位置 再加入到 buildLayer里面
        self.curBuild = MiaoBuild.new(self.buildLayer, {picName='remove'}) 
        local p = self.bg:convertToNodeSpace(ccp(vs.width/2, vs.height/2))
        p = normalizePos({p.x, p.y}, 1, 1)
        self.curBuild:setPos(p)
        self.curBuild:setState(BUILD_STATE.MOVE)
        self.buildLayer:addBuilding(self.curBuild, MAX_BUILD_ZORD)
        Logic.paused = true
    end
end
--拖动某个建筑物 还是  
--选择某个建筑物 拖动 确定  取消 移动 setCurBuild = '??' 作为最上层一旦和这个建筑物 合体 就一起了 
--点击某个位置 这个建筑物 就被选中了 
function MiaoPage:onMove()
    if self.curBuild == nil then
        local vs = getVS()
        self.curBuild = MiaoBuild.new(self.buildLayer, {picName='move'})
        local p = self.bg:convertToNodeSpace(ccp(vs.width/2, vs.height/2))
        p = normalizePos({p.x, p.y}, 1, 1)
        self.curBuild:setPos(p)
        self.curBuild:setState(BUILD_STATE.MOVE)
        self.buildLayer:addBuilding(self.curBuild, MAX_BUILD_ZORD)
        Logic.paused = true
    end
end
