RunMenu = class()
function RunMenu:ctor(s)
    self.scene = s
    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=768, height=1024}
    self.sz = sz
    self.temp = setPos(addNode(self.bg), {0, fixY(sz.height, 0+sz.height)+0})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "0.png"), {385, fixY(sz.height, 91)}), {114, 86}), {0.50, 0.50}), 255)
    self.score = sp
    centerUI(self)
end
function RunMenu:adjustScore(s)
    removeSelf(self.score)
    self.score = addNode(self.temp)

    local num = {}
    while s > 0 do
        local r = s%10
        s = math.floor(s/10)
        table.insert(num, r)
    end
    if #num == 0 then
        table.insert(num, 0)
    end
    local n = #num
    num = reverse(num)
    local wid = 0
    for k, v in ipairs(num) do
        local k = createSprite(v..".png")
        addChild(self.score, k)
        setAnchor(setPos(k, {wid, 0}), {0, 0.5})
        local sz = k:getContentSize()
        wid = wid+sz.width
    end
    setPos(self.score, {385-wid/2, fixY(self.sz.height,91)})
end

