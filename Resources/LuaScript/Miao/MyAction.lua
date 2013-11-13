MyAction = class()
function MyAction:ctor(tar)
    self.blocking = false
    self.mask = 0
    self.target = tar
end
function MyAction:update(diff)
    return true
end



MoveToNode = class(MyAction)
function MoveToNode:ctor(tar, start, over)
    self.start = start
    self.over = over
    self.blocking = true
    self.mask = ActionList.MaskMove
    self.time = 0
    self.target.bg:runAction(moveto(1, self.over[1], self.over[2]))
end
function MoveToNode:update(diff)
    self.time = self.time+diff
    if self.time >= 1 then
        return true
    else
        return false
    end
end
