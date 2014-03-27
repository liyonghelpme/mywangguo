MineStore = class(FuncBuild)
function MineStore:ctor(b)
    self.baseBuild.maxNum = 100
    self.goodsNum = 0
end
function MineStore:initBottom()
    if self.selGrid == nil then
        self.selGrid = CCNode:create()
        self.baseBuild.heightNode:addChild(self.selGrid, -1)
        if self.baseBuild.dir == 0 then
            self.s1 = setSize(setPos(setAnchor(addSprite(self.selGrid, "newBlueGrid.png"), {0.5, 0.5}), {0, SIZEY}), {SIZEX*2+10, SIZEY*2+10})
            self.s2 = setSize(setPos(setAnchor(addSprite(self.selGrid, "newBlueGrid.png"), {0.5, 0.5}), {SIZEX, SIZEY*2}), {SIZEX*2+10, SIZEY*2+10})
        else
            self.s1 = setSize(setPos(setAnchor(addSprite(self.selGrid, "newBlueGrid.png"), {0.5, 0.5}), {0, SIZEY}), {SIZEX*2+10, SIZEY*2+10})
            self.s2 = setSize(setPos(setAnchor(addSprite(self.selGrid, "newBlueGrid.png"), {0.5, 0.5}), {-SIZEX, SIZEY*2}), {SIZEX*2+10, SIZEY*2+10})
        end
    end
end
function MineStore:initView()
    --local bd = Logic.buildings[self.baseBuild.id]
    --local sz = self.baseBuild.changeDirNode:getContentSize()
    --setPos(setAnchor(self.baseBuild.changeDirNode, {bd.ax/sz.width, (sz.height-bd.ay)/sz.height}), {0, SIZEY})
    --local bd = Logic.buildings[self.baseBuild.id]
    local sz = self.baseBuild.changeDirNode:getContentSize()
    setPos(setAnchor(self.baseBuild.changeDirNode, {306/1024, (768-288)/768}), {0, SIZEY})
    --self.tool = setSize(setPos(addSprite(self.baseBuild.changeDirNode, "equip70.png"), {93, fixY(130, 75)}), {40, 40})
    self.tool = addNode(self.baseBuild.changeDirNode)
end

function MineStore:takeTool()
    setVisible(self.tool, false)
end
function MineStore:putTool()
    setVisible(self.tool, true)
end
function MineStore:setBottomColor(c)
    if c == 0 then
        setTexture(self.s1, "newRedGrid.png")
        setTexture(self.s2, "newRedGrid.png")
    else
        setTexture(self.s1, "newBlueGrid.png")
        setTexture(self.s2, "newBlueGrid.png")
    end
end

function MineStore:doSwitch()
    if self.s1 ~= nil then
        removeSelf(self.s1)
        removeSelf(self.s2)
        if self.baseBuild.dir == 0 then
            self.s1 = setSize(setPos(setAnchor(addSprite(self.selGrid, "newBlueGrid.png"), {0.5, 0.5}), {0, SIZEY}), {SIZEX*2+10, SIZEY*2+10})
            self.s2 = setSize(setPos(setAnchor(addSprite(self.selGrid, "newBlueGrid.png"), {0.5, 0.5}), {SIZEX, SIZEY*2}), {SIZEX*2+10, SIZEY*2+10})
        else
            self.s1 = setSize(setPos(setAnchor(addSprite(self.selGrid, "newBlueGrid.png"), {0.5, 0.5}), {0, SIZEY}), {SIZEX*2+10, SIZEY*2+10})
            self.s2 = setSize(setPos(setAnchor(addSprite(self.selGrid, "newBlueGrid.png"), {0.5, 0.5}), {-SIZEX, SIZEY*2}), {SIZEX*2+10, SIZEY*2+10})
        end
        self.baseBuild:setColPos()
    end
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

function MineStore:updateGoods()
    local show = math.ceil(3*self.baseBuild.workNum/self.baseBuild.maxNum)
    print("update MineStore Goods", self.baseBuild.workNum, self.baseBuild.maxNum, self.goodsNum, show)
    if self.baseBuild.workNum > 0 then
        show = math.max(1, show)
    end
    if show == self.goodsNum then
        return
    end
    self.goodsNum = show
    if self.goodsObj ~= nil then
        removeSelf(self.goodsObj)
    end
    self.goodsObj = nil
    if show == 0 then
        return
    elseif show == 1 then
        self.goodsObj = createSprite("stone1.png")
    elseif show == 2 then
        self.goodsObj = createSprite("stone2.png")
    elseif show == 3 then
        self.goodsObj = createSprite("stone3.png")
    else
        self.goodsObj = createSprite("stone1.png")
    end
    self.baseBuild.changeDirNode:addChild(self.goodsObj)
    --local sz = self.baseBuild.changeDirNode:getContentSize()
    setPos(self.goodsObj, {512, 384})
    print("setPos", 512)
end

function MineStore:detailDialog()
    global.director:pushView(StoreInfo2.new(self.baseBuild), 1)   
end
function MineStore:getIncWord()
    return "生产"
end
