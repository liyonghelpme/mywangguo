Mine = class(FuncBuild)
function Mine:ctor(b)
    self.maxNum = 20
end
function Mine:initView()
    local sz = self.baseBuild.changeDirNode:getContentSize()
    setPos(setAnchor(self.baseBuild.changeDirNode, {306/1024, (768-288)/768}), {0, SIZEY})
end
--在touch的时候setColor
function Mine:setColor()
    local s = self:checkSlope()
    print("Mine setColor")
    if self.selGrid ~= nil then
        if s == false then
            setTexture(self.selGrid, "newRedGrid.png")
        else
            setTexture(self.selGrid, "newBlueGrid.png")
        end
    end
end
function Mine:checkSlope()
    print("checkSlope", self.baseBuild.colNow, self.baseBuild.otherBuild)
    if self.baseBuild.colNow == 1 then
        if self.baseBuild.otherBuild ~= nil then
            local dir = self.baseBuild.otherBuild.dir
            print("checkMineSlope", self.baseBuild.colNow, self.baseBuild.otherBuild, dir)
            if self.baseBuild.otherBuild.picName == 'slope' and (dir ==0 or dir == 1) then
                return true
            end
        end
    end
    return false
end
function Mine:checkFinish()
    local s = self:checkSlope()
    if s then
        self.baseBuild.map.scene:finishBuild() 
    else
        addBanner("必须建造到斜坡上")
    end
end
function Mine:checkBuildable()
    return false
end
--如果和斜坡碰撞了 调整图片方向
function Mine:whenColNow()
    local scaY = getScaleY(self.baseBuild.changeDirNode)
    if self:checkSlope() then
        print("whenColNow Mine", self.baseBuild.colNow, self.baseBuild.otherBuild)
        local dir = self.baseBuild.otherBuild.dir
        if dir == 0 then
            setScaleX(self.baseBuild.changeDirNode, -scaY)
        else
            setScaleX(self.baseBuild.changeDirNode, scaY)
        end
    else
        setScaleX(self.baseBuild.changeDirNode, scaY)
    end
end
function Mine:adjustRoad()
    print("adjust Mine dir")
    self:whenColNow()
end
