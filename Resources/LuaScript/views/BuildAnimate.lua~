BuildAnimate = class()
function BuildAnimate:ctor(b)
    self.build = b
    local ani = getAni(b.data['id'])
    local aniKind = ani[3]
    local sz = b.bg:getContentSize()
    --if aniKind == BUILD_ANI_OBJ then
    self.bg = setAnchor(setPos(CCSprite:create('images/'..ani[1][1]), {ani[2][1], fixY(sz.height, ani[2][2])}), {ani[5][1]/100, 1.0-ani[5][2]/100})
    --[[
    else
        self.bg = CCNode:create()
    end
    --]]
    self.cus = nil
    if aniKind == BUILD_ANI_OBJ then
        self.cus = animate(ani[3], arrPicFrames(ani[1]))  
        self.bg:runAction(self.cus)
    elseif aniKind == BUILD_ANI_ROT then
        self.bg:runAction(repeatForever(rotateby(ani[2], 360)))
    elseif aniKind == BUILD_ANI_ANI then
        self.cus = animate(ani[3], arrPicFrames(ani[1]))
        self.bg:runAction(self.cus)
    end
end

