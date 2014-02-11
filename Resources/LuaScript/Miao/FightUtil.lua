function getRowFirst(data, row)
    for k, v in ipairs(data) do
        for tk, tv in ipairs(v) do
            --false 用于占位
            if tk == row and tv ~= false and not tv.dead then
                return tv
            end
        end
    end
    return nil
end

--最后一个非死亡的士兵
function getSidest(sol, s)
    --第一个对象就是 nil false
    if not sol then
        return nil
    end
    local lastSol = nil
    if not sol.dead then
        lastSol = sol
    end
    while sol[s] do
        if not sol.dead then
            lastSol = sol
        end
        sol = sol[s]
    end
    return lastSol
end

function getRowMost(data, row, side)
    local rf = getRowFirst(data, row)
    if rf ~= nil then
        return getSidest(rf, side)
    end
    return nil
end

function getFirstNotDead(sol, side)
    while sol[side] ~= nil do
        if sol[side].dead then
            sol[side] = sol[side][side]
        else
            break
        end
    end
    return sol[side]
end

function initSolLeftRight(self)
    local left = getMapKey(self.col-1, self.row)
    local right = getMapKey(self.col+1, self.row)
    self.left = self.map.soldierNet[left]
    self.right = self.map.soldierNet[right]
end
function createDeadSoldier()
end
