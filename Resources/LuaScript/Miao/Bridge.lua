Bridge = class(FuncBuild)
--根据桥梁方向决定flipX 方向
--卖出 买入 移动建筑物 node 都要相应修改位置 setPos
function Bridge:initView()
    self.bgNode1 = CCNode:create()
    self.heightNode1 = addNode(self.bgNode1)
    self.baseBuild.map.roadLayer:addChild(self.bgNode1)

    self.bgNode2 = CCNode:create()
    self.heightNode2 = addNode(self.bgNode2)
    self.baseBuild.map.buildingLayer:addChild(self.bgNode2)

    self.bottom = createSprite("build3_bottom.png")
    self.heightNode1:addChild(self.bottom)

    self.baseBuild.changeDirNode = createSprite("build3_right.png")
    self.right = self.baseBuild.changeDirNode
    self.left = createSprite("build3_left.png")
    self.heightNode2:addChild(self.right)

    self.baseBuild.heightNode:addChild(self.left)

    setPos(setAnchor(self.bottom, {444/1024, (768-559)/768}), {0, SIZEY})
    setPos(setAnchor(self.right, {444/1024, (768-559)/768}), {0, SIZEY})
    setPos(setAnchor(self.left, {444/1024, (768-559)/768}), {0, SIZEY})
end
function Bridge:setPos(p)
    setPos(self.bgNode1, p)
    setPos(self.bgNode2, p)
    self.bgNode1:setZOrder(self.baseBuild.zord)
    self.bgNode2:setZOrder(self.baseBuild.zord-170)
    self:adjustHeight()
end
--基本node 上面放着 栅栏
--特殊node 上面 放着 桥底板
function Bridge:adjustHeight()
    local p = getPos(self.baseBuild.bg)
    local ax, ay = newCartesianToAffine(p[1], p[2], self.baseBuild.map.scene.width, self.baseBuild.map.scene.height, MapWidth/2, FIX_HEIGHT)
    print("adjust Road Height !!!!!!!!!!!!!!!!!!!!!!!!!", ax, ay)
    local hei = adjustNewHeight(self.baseBuild.map.scene.mask, self.baseBuild.map.scene.width, ax, ay)
    setPos(self.baseBuild.heightNode, {0, hei*103})
    setPos(self.heightNode1, {0, hei*103})
    setPos(self.heightNode2, {0, hei*103})
end

local negMap = {
['tile47.png']=true,
['tile53.png']=true,
['tile66.png']=true,
}

local posMap = {
['tile70.png']=true,
['tile71.png']=true,
['tile72.png']=true,
['tile74.png']=true,
['tile75.png']=true,
['tile76.png']=true,
['tile78.png']=true,
}

function Bridge:checkBuildable()
    if self.baseBuild.colNow == 1 then
        if self.baseBuild.otherBuild ~= nil then
            if self.baseBuild.otherBuild.picName == 'water' then
                local pname = self.baseBuild.otherBuild.pname 
                if negMap[pname] or posMap[pname] then
                    return true
                else
                    print("error water", pname)
                end
            end
        end
    end
    return false
end

function Bridge:whenColNow()
    local s = self:checkBuildable()
    if not s then
        addBanner("必须建造到河流上")
    else
        local ax, ay, height = self.baseBuild:getAxAyHeight()
        local tid = axayToTid(ax, ay, self.baseBuild.map.scene.width)
        local wd = self.baseBuild.map.scene.waterData
        --左上 右下 一侧接触陆地 没有超出地图边界
        if wd[tid] ~= nil then
            local scaY = getScaleY(self.bottom)
            if negMap[wd[tid].pname] then
                setScaleX(self.bottom, scaY)
                setScaleX(self.left, scaY)
                setScaleX(self.right, scaY)
            elseif posMap[wd[tid].pname] then
                setScaleX(self.bottom, -scaY)
                setScaleX(self.left, -scaY)
                setScaleX(self.right, -scaY)
            end
        end
    end
end

function Bridge:checkFinish()
    local s = self:checkBuildable()
    if s then
        self.baseBuild.map.scene:finishBuild() 
    else
        addBanner("桥梁必须建造到河流上面")
    end
end

function Bridge:setColor()
    --检查是否和河流冲突
    local s = self:checkBuildable()
    if s then
        self:setBottomColor(1)
    else
        self:setBottomColor(0)
    end
end


function Bridge:removeSelf()
    removeSelf(self.bgNode1)
    removeSelf(self.bgNode2)
end

function Bridge:runBeginBuild()
    self.bottom:runAction(repeatForever(sequence({fadeout(0.5), fadein(0.5)})))
    self.left:runAction(repeatForever(sequence({fadeout(0.5), fadein(0.5)})))
    self.right:runAction(repeatForever(sequence({fadeout(0.5), fadein(0.5)})))
end
function Bridge:finishBuild()
    self.left:stopAllActions()
    self.left:runAction(fadein(0))
    self.right:stopAllActions()
    self.right:runAction(fadein(0))
    self.bottom:stopAllActions()
    self.bottom:runAction(fadein(0))
end

function Bridge:runTouchAni()
    self.bottom:runAction(repeatForever(sequence({itintto(0.5, 128, 128, 128), itintto(0.5, 255, 255, 255)})))
    self.left:runAction(repeatForever(sequence({itintto(0.5, 128, 128, 128), itintto(0.5, 255, 255, 255)})))
    self.right:runAction(repeatForever(sequence({itintto(0.5, 128, 128, 128), itintto(0.5, 255, 255, 255)})))
end

function Bridge:clearTouchAni()
    self.bottom:stopAllActions()
    setColor(self.bottom, {255, 255, 255})

    self.left:stopAllActions()
    setColor(self.right, {255, 255, 255})

    self.right:stopAllActions()
    setColor(self.right, {255, 255, 255})
end
