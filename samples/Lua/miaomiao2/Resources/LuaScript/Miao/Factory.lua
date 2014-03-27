require "menu.FactoryInfo"
Factory = class(FuncBuild)
function Factory:setWorker(b)
    self.worker = b
end
function Factory:clearWorker(b)
    self.worker = nil
end
function Factory:startWork()
    if self.banner == nil then
        local sz = {width=189, height=30}
        local banner, pro = createFacBanner()
        self.banner = banner
        setPos(self.banner, {0, 240})
        self.baseBuild.heightNode:addChild(banner, 1)
        self.bg = banner
        self.passTime = 0
        self.pro = pro
        registerEnterOrExit(self)
        print("registerEnterOrExit factory")
        registerUpdate(self)
    end
end
function Factory:enterScene()
    print("factory enterScene")
end

function Factory:getIncWord()
    return "生产"
end

function setFacProNum(pro, n, max)
    if n <= 0 then
        pro.bg:setVisible(false)
    else
        pro.bg:setVisible(true)
        local wid = math.floor((n/max)*183)
        wid = math.max(pro.lw+pro.rw, wid)
        --setContentSize(banner, {wid, 23})
        local cw = wid-pro.lw-pro.rw
        --setScaleX(pro.center, cw/pro.cw)
        local r = CCRectMake(pro.lw, 0, cw, 23)
        pro.center:setTextureRect(r, false, r.size)
        setPos(pro.right, {wid-pro.rw, 0})
    end
end
function createFacBanner()
    local sz = {width=189, height=30}
    local banner = setSize(createSprite("buildProgressBar.png"), {189, 30})
    local pro = {lw=8, rw=8, cw=6}
    local tex = CCTextureCache:sharedTextureCache():addImage("buildProgress.png")
    local ca = CCSpriteFrameCache:sharedSpriteFrameCache()
    local r = CCRectMake(0, 0, pro.lw, 23)
    local left = createSpriteFrame(tex, r, 'proLeft')
    local r = CCRectMake(177, 0, pro.rw, 23)
    local right = createSpriteFrame(tex, r, 'proRight')
    local r = CCRectMake(pro.lw, 0, 183-pro.lw-pro.rw, 23)
    local center = createSpriteFrame(tex, r, 'proMiddle')

    pro.bg = CCSpriteBatchNode:create("buildProgress.png")
    pro.left = createSprite("proLeft")
    addChild(pro.bg, pro.left)
    setAnchor(pro.left, {0, 0.5})
    setPos(pro.left, {0, 0})
    pro.right = createSprite("proRight")
    addChild(pro.bg, pro.right)
    setAnchor(pro.right, {0, 0.5})
    setPos(pro.right, {pro.lw+pro.cw, 0})
    pro.center = createSprite("proMiddle")
    addChild(pro.bg, pro.center)
    setAnchor(pro.center, {0, 0.5})
    setPos(pro.center, {pro.lw, 0})

    banner:addChild(pro.bg)
    setAnchor(setPos(pro.bg, {3, fixY(sz.height, 13)}), {0, 0.5})
    return banner, pro
end
function Factory:update(diff)
    --print("Factory", self.passTime)
    --[[
    setFacProNum(self.pro, self.passTime, 1)
    self.passTime = self.passTime+diff
    if self.passTime > 1 then
        self.passTime = 0
    end
    --]]
    if self.baseBuild.owner == nil then
        self:stopWork()
    end
end

function Factory:updateProcess(t, tt)
    t = math.min(t, tt)
    setFacProNum(self.pro, t, tt)
end

function Factory:stopWork()
    removeSelf(self.banner)
    self.bg = nil
    self.banner = nil
end


function Factory:detailDialog()
    global.director:pushView(StoreInfo2.new(self.baseBuild), 1)
end

