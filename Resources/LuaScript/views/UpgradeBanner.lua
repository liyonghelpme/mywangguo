UpgradeBanner = class()
function UpgradeBanner:ctor(w, col, cb, delegate)
    self.moveAni = nil
    self.callback = cb
    self.delegate = delegate
    if col == nil then
        col = {255, 255, 255}
    end
    self.bg = CCNode:create()
    local sb = setAnchor(setPos(addSprite(self.bg, "images/storeBlack.png"), {global.director.disSize[1]/2, global.director.disSize[2]/2}), {0.5, 0.5})
    
    local word = setAnchor(colorWordsNode(w, 20, col, {89, 72, 18}), {0.5, 0.5})
    self.bg:addChild(word)
    word:setPosition(ccp(global.director.disSize[1]/2, global.director.disSize[2]/2))
    
    local wSize = word:getContentSize()
    local bSize = sb:getContentSize()
    local nbSize ={math.max(wSize.width+10, bSize.width), bSize.height}  
    setSize(sb, nbSize)
    
    self.bg:runAction(sequence({delaytime(2), fadeout(1), callfunc(self, self.removeNow)}))
end
function UpgradeBanner:removeNow()
    removeSelf(self.bg)
    if self.callback ~= nil then
        callback(delegate)
    end
end
function UpgradeBanner:setMoveAni(X, Y)
    if self.moveAni ~= nil then
        self.bg:stopAction(self.moveAni)
    end
    self.moveAni = expout(moveto(getParam("bannerMoveTime")/1000, X, Y))
    self.bg:runAction(self.moveAni) 
end

