function genNum(s)
    local score = CCNode:create()

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
        addChild(score, k)
        setAnchor(setPos(k, {wid, 0}), {0, 0.5})
        local sz = k:getContentSize()
        wid = wid+sz.width
    end
    score.width = wid
    return score
end
