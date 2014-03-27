ActionList = class()
ActionList.MaskMove = bit(1)
ActionList.MaskAni = bit(2)

function ActionList:ctor(tar)
    --self.bg = CCNode:create()
    self.target = tar
    self.list = {}
end

function ActionList:push(act)
    act.owner = self
    table.insert(self.list, 1, act)
end

function ActionList:isEmpty()
    return #self.list == 0
end

--不能在actionList 内部修改自己的actionList 
--拿不到对象的actionList cocos2dx里面
--某个动作里面包含的 move animation behavior 就把它block掉
function ActionList:update(diff)
    local block_mask = 0
    local index = 1
    --如果taskmask
    while index <= #self.list do
        local task = self.list[index]
        --任务被阻塞 不能更新
        if bitand(task.mask, block_mask) > 0 then
            index = index+1 
        else
            local complete = task:update(diff)
            if complete then
                table.remove(self.list, index)
            else
                if task.blocking then
                    block_mask = bitor(block_mask, task.mask)
                end
                index = index+1
            end
        end
    end
end
