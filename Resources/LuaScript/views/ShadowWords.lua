ShadowWords = class()
function ShadowWords:ctor(w, ty, sz, bo, col)
    self.wSize = sz
    self.wColor = col
    self.bg = CCNode:create()
    self.picWord = picNumWord(w, self.wSize, self.wColor)
    setPos(self.picWord, {0, 0})
    self.bg:addChild(self.picWord)
    self.bg:setContentSize(self.picWord:getContentSize())
end
function ShadowWords:setWords(w)
    self.picWord:removeFromParentAndCleanup(true)
    self.picWord = picNumWord(w, wSize, wColor)
    setPos(self.picWord, {0, 0})
    self.bg:addChild(self.picWord)
    self.bg:setContentSize(self.picWord:getContentSize())
end

