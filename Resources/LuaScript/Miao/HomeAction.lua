BehaviorRest = class(MyAction)
function BehaviorRest:ctor(tar)
    self.mask = bitor(ACTION_MASK.MaskBehavior, ACTION_MASK.MaskReset)
    self.time = 0
end
function BehaviorRest:update(diff)
    return false
end
