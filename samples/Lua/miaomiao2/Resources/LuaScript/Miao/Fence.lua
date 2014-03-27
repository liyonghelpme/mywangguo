Fence = class(FuncBuild)
function Fence:initView()
    local bd = Logic.buildings[self.baseBuild.id]
    local sz = self.baseBuild.changeDirNode:getContentSize()
    --setPos(setAnchor(self.baseBuild.changeDirNode, {170/512, (sz.height-bd.ay)/sz.height}), {0, SIZEY})
    setScale(setAnchor(self.baseBuild.changeDirNode, {170/sz.width, 0}), 1.1)
end
function Fence:setPos()
    setPos(self.baseBuild.changeDirNode, {0, SIZEY})
end
