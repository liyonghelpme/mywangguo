Camera = class()
local cid = 0
CAMERA_SMOOTH = 10
function Camera:ctor(m, width)
    self.map = m
    self.width = width
    self.bg = CCNode:create()
    local vs = getVS()
    --中间产生一个2个像素的黑线
    self.renderTexture = CCRenderTexture:create(width, FIGHT_HEIGHT)
    self.renderTexture:beginWithClear(1, 1, 1, 1)
    self.renderTexture:endToLua()
    --渲染进来 并显示出来
    self.moveTarget = nil
    self.bg:addChild(self.renderTexture)
    self.moveNode = addNode(self.bg)
    --local test = setVisible(addSprite(self.bg, "water.jpg"), true)
    --self.test =test
    self.cid = cid
    --主镜头相对于 目标镜头的偏移值
    self.mainOff = 0
    cid = cid+1
    if DEBUG_FIGHT then
        self.renderNode = createSprite("whitebox.png")
        self.map.physicScene:addChild(self.renderNode)
        setAnchor(self.renderNode, {0, 0})
        setPos(self.renderNode, {0, 0})
        local coord = ui.newBMFontLabel({text='', font='bound.fnt', color={0, 0, 0}, size=25})
        self.coord = coord
        setAnchor(coord, {0, 0})
        self.renderNode:addChild(coord)

        if self.cid == 0 then
            setColor(self.renderNode, {255, 0, 0})
            setPos(self.renderNode, {0, 100})
        elseif self.cid == 1 then
            setColor(self.renderNode, {0, 255, 0})
            setPos(self.renderNode, {0, 200})
        else
            setColor(self.renderNode, {0, 0, 255})
            setPos(self.renderNode, {0, 300})
        end
        setVisible(self.renderNode, false)
    end


    self.needUpdate = true
    registerEnterOrExit(self)
end
--偏移该对象100的像素位置
function Camera:trace(o, offX)
    self.object = o
    self.offX = offX
end
function Camera:adjustMoveTarget()
    if self.object ~= nil then
        if self.object.dead then
            --追踪对象死亡了
        else
            local vs = getVS()
            --弓箭就要考虑 changeDirNode 和 bg 不同因素
            local ap = getPos(self.object.changeDirNode)
            local abp = getPos(self.object.bg)
            ap[1] = abp[1]+ap[1]
            ap[2] = abp[2]+ap[2]
            if self.offX > 0 then
                if (ap[1]+self.offX) >= (-self.startPoint[1]+vs.width/2) then
                    self.moveTarget = -(ap[1]+self.offX-vs.width/2)
                end
            else
                if (ap[1]+self.offX) <= (-self.startPoint[1]) then
                    self.moveTarget = -(ap[1]+self.offX)
                end
            end
        end
    end
end
--调整场景位置 进行渲染
function Camera:update(diff)
    self:adjustMoveTarget()
    if self.moveTarget ~= nil then
        local pos = self.startPoint
        local smooth = diff*CAMERA_SMOOTH
        smooth = math.min(smooth, 1)
        local dx = math.abs(pos[1]-self.moveTarget)
        local px = pos[1]*(1-smooth)+self.moveTarget*smooth
        self.startPoint = {px, pos[2]}
        --调整 battleScene 位置主要是为了 背景多个层次摆放位置 渲染
        self.map:adjustBattleScene(px)
        --渲染physic scene 对象
        local vs = self.renderTexture:isVisible()
        --setVisible(self.renderNode, vs)

        if DEBUG_FIGHT then
            local col 
            if self.object ~= nil then
                col = self.object.color 
            end
            self.coord:setString(math.floor(self.moveTarget).." "..math.floor(self.startPoint[1])..' '..math.floor(self.startPoint[2]).." "..str(col).." "..math.floor(self.mainOff))
        end
        if vs then
            local rn
            if DEBUG_FIGHT then
                if self.map.clone then
                    if self.map.cloneWho == 0 then
                        rn = self.map.leftCamera.renderNode
                        setVisible(rn, true)
                    else
                        rn = self.map.rightCamera.renderNode
                        setVisible(rn, true)
                    end
                end
                setVisible(self.renderNode, true)
            end

            self.renderTexture:beginWithClear(0, 0, 0, 1)
            self.map.physicScene:visit()
            --self.test:visit()
            self.renderTexture:endToLua()
            if DEBUG_FIGHT then
                setVisible(self.renderNode, false)
                if rn then
                    setVisible(rn, false)
                end
            end
        end
    end
end
function Camera:render()
end
--快速从a 移动到 b 战斗场景
function Camera:fastMoveTo(a, b)
    print("fastMoveTo", simple.encode(a), simple.encode(b))
    self.startPoint = a
    self.moveTarget = b
end
function Camera:clearCamera()
    self.object = nil
    self.moveTarget = nil
end

