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
    self.picWord = picNumWord(w, self.wSize, self.wColor)
    setPos(self.picWord, {0, 0})
    self.bg:addChild(self.picWord)
    self.bg:setContentSize(self.picWord:getContentSize())
end
function ShadowWords:runAction(act)
    --[[
    local ch = self.picWord:getChildren()
    for i = 0, self.picWord:getChildrenCount()-1, 1 do
        local c = ch:objectAtIndex(i)
        c:runAction(tolua.cast("CCAction", act:copy()))
    end
    --]]
end

