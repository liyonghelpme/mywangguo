UpgradeBanner = class()
function UpgradeBanner:ctor(w, col, cb, delegate)
    self.moveAni = nil
    self.callback = cb
    self.delegate = delegate
    if col == nil then
        col = {255, 255, 255}
    end
    self.bg = CCNode:create()
    local sb = setAnchor(setPos(addSprite(self.bg, "storeBlack.png"), {global.director.disSize[1]/2, global.director.disSize[2]/2}), {0.5, 0.5})
    self.sb = sb
    
    local word = setAnchor(colorWordsNode(w, 20, col, {89, 72, 18}), {0.5, 0.5})
    self.sb:addChild(word)
    --word:setPosition(ccp(global.director.disSize[1]/2, global.director.disSize[2]/2))
    
    local wSize = word:getContentSize()
    local bSize = sb:getContentSize()
    local nbSize ={math.max(wSize.width+10, bSize.width), bSize.height}  
    setSize(sb, nbSize)
    setPos(word, {nbSize[1]/2, nbSize[2]/2})
    
    self.bg:runAction(sequence({delaytime(2), fadeout(1), callfunc(self, self.removeNow)}))
end
function UpgradeBanner:removeNow()
    removeSelf(self.bg)
    self.bg = nil
    self.sb = nil
    if self.callback ~= nil then
        callback(delegate)
    end
end
function UpgradeBanner:setMoveAni(X, Y)
    if self.bg ~= nil then
        if self.moveAni ~= nil then
            self.sb:stopAction(self.moveAni)
        end
        self.moveAni = expout(moveto(0.2, X, Y))
        self.sb:runAction(self.moveAni) 
    end
end

