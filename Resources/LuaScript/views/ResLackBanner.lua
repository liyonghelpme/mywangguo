ResLackBanner = class()
function ResLackBanner:ctor(w, col, butWord, buyParam, s)
    self.store = s
    if col == nil then
        col = {255, 255, 255}
    end
    self.bg = CCLayer:create()
    setPos(self.bg, {global.director.disSize[1]/2, global.director.disSize[2]/2})
    self.bg:setAnchorPoint(ccp(0.5, 0.5))

    self.sp = CCSprite:create("storeBlack.png")    
    self.bg:addChild(self.sp)

    local sz = self.sp:getContentSize()

    local word = setAnchor(colorWordsNode(w, 20, col, fixColor({89, 72, 18})), {0, 0.5})
    self.bg:addChild(word)
    --[[
    local but0 = ui.newButton({image="roleNameBut0.png", delegate=self, callback=self.buyIt, param=buyParam})
    but0:setAnchor(0.5, 0.5)
    but0:setContentSize(95, 39)
    setPos(but0.bg, {333, fixY(sz.height, 27)})
    self.bg:addChild(but0.bg)
    --]]

    local MARGIN = 20
    local wSize = word:getContentSize()
    local bSize = self.sp:getContentSize()
    --local butSize = but0.bg:getContentSize()
    butSize = {width=0, height=0}
    local totalSize = wSize.width+10+MARGIN+butSize.width
    local nBsize = {math.max(totalSize, bSize.width), bSize.height}
    setSize(self.sp, nBsize)
    setContentSize(self.bg, nBsize)

    word:setAnchorPoint(ccp(0.5, 0.5))
    word:setPosition(ccp(0, 0))
    
    --local wOffx = (nBsize[1]-totalSize)/2
    --setPos(word, {wOffx, nBsize[2]/2})
    --setPos(but0.bg, {wOffx+wSize.width+MARGIN+butSize.width/2, nBsize[2]/2})

    self.bg:runAction(sequence({delaytime(2), fadeout(1), callfunc(self, self.removeNow)}))
end

function ResLackBanner:removeNow()
    removeSelf(self.bg)
end

function ResLackBanner:setMoveAni(X, Y)
    if self.moveAni ~= nil then
        self.bg:stopAction(self.moveAni)
    end
    self.moveAni = expout(moveto(getParam("bannerMoveTime")/1000, X, Y))
    self.bg:runAction(self.moveAni) 
end
