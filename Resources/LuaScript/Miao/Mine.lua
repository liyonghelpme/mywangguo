Mine = class(FuncBuild)
function Mine:ctor(b)
    self.maxNum = 15
end
function Mine:setColor()
    local s = self:checkSlope()
    if s then
        setColor(self.baseBuild.bottom, {0, 255, 0})
    else
        setColor(self.baseBuild.bottom, {255, 0, 0})
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
    end
end
function Mine:checkBuildable()
    return false
end
--如果和斜坡碰撞了 调整图片方向
function Mine:whenColNow()
    if self:checkSlope() then
        print("whenColNow Mine", self.baseBuild.colNow, self.baseBuild.otherBuild)
        local dir = self.baseBuild.otherBuild.dir
        if dir == 0 then
            self.baseBuild.changeDirNode:setFlipX(true)
        else
            self.baseBuild.changeDirNode:setFlipX(false)
        end
    else
        self.baseBuild.changeDirNode:setFlipX(false)
    end
end
