MineStore = class(FuncBuild)
function MineStore:initBottom()
    self.baseBuild.bottom = CCNode:create()
    self.baseBuild.bg:addChild(self.baseBuild.bottom, 1) 
    self.s1 = setSize(setPos(setAnchor(addSprite(self.baseBuild.bottom, "white2.png"), {0.5, 0.5}), {0, SIZEY}), {SIZEX*2+10, SIZEY*2+10})
    self.s2 = setSize(setPos(setAnchor(addSprite(self.baseBuild.bottom, "white2.png"), {0.5, 0.5}), {SIZEX, SIZEY*2}), {SIZEX*2+10, SIZEY*2+10})

end
function MineStore:initView()
    local bd = Logic.buildings[self.baseBuild.id]
    local sz = self.baseBuild.changeDirNode:getContentSize()
    setPos(setAnchor(self.baseBuild.changeDirNode, {bd.ax/sz.width, (sz.height-bd.ay)/sz.height}), {0, SIZEY})
    self.tool = setSize(setPos(addSprite(self.baseBuild.changeDirNode, "equip70.png"), {93, fixY(130, 75)}), {40, 40})
end

function MineStore:takeTool()
    setVisible(self.tool, false)
end
function MineStore:putTool()
    setVisible(self.tool, true)
end
function MineStore:setBottomColor(c)
    if c == 0 then
        setColor(self.s1, {255, 0, 0})
        setColor(self.s2, {255, 0, 0})
    else
        setColor(self.s1, {0, 255, 0})
        setColor(self.s2, {0, 255, 0})
    end
end
function MineStore:doSwitch()
    removeSelf(self.s1)
    removeSelf(self.s2)
    if self.baseBuild.dir == 0 then
        self.s1 = setSize(setPos(setAnchor(addSprite(self.baseBuild.bottom, "white2.png"), {0.5, 0.5}), {0, SIZEY}), {SIZEX*2+10, SIZEY*2+10})
        self.s2 = setSize(setPos(setAnchor(addSprite(self.baseBuild.bottom, "white2.png"), {0.5, 0.5}), {SIZEX, SIZEY*2}), {SIZEX*2+10, SIZEY*2+10})
    else
        self.s1 = setSize(setPos(setAnchor(addSprite(self.baseBuild.bottom, "white2.png"), {0.5, 0.5}), {0, SIZEY}), {SIZEX*2+10, SIZEY*2+10})
        self.s2 = setSize(setPos(setAnchor(addSprite(self.baseBuild.bottom, "white2.png"), {0.5, 0.5}), {-SIZEX, SIZEY*2}), {SIZEX*2+10, SIZEY*2+10})
    end
    self.baseBuild:setColPos()
end
function MineStore:updateState()
    if self.stonePic ~= nil then
        removeSelf(self.stonePic)
    end
    self.stonePic = CCNode:create()
    self.baseBuild.bg:addChild(self.stonePic)
    local sn = math.ceil(self.baseBuild.stone/5)
    local initX = -20
    for i=1, sn, 1 do
        local sp = CCSprite:create("herb109.png")
        self.stonePic:addChild(sp)
        setPos(sp, {initX+(i-1)*40, 30})
    end
end
