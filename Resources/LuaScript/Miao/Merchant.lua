
Merchant = class(FuncPeople)
function Merchant:checkWork(k)
    local ret
    ret = (k.picName == 'build' and k.id == 2 and k.state == BUILD_STATE.FREE and k.workNum > 0 and k.owner == nil)
    --去商店
    if not ret then
        ret = (k.picName == 'build' and k.id == 6 and k.state == BUILD_STATE.FREE and k.workNum > 0 and k.owner == nil)
    end
    --采矿场
    if not ret then
        print("stone ", k.stone)
        ret = (k.picName == 'build' and k.id == 12 and k.state == BUILD_STATE.FREE and k.stone > 0 and k.owner == nil)
    end
    --铁匠铺
    if not ret then
        ret = (k.picName == 'build' and k.id == 13 and k.state == BUILD_STATE.FREE and k.workNum > 0 and k.owner == nil)
    end
    --塔
    if not ret then
        print("try tower goods")
        ret = (k.picName == 'build' and k.id == 14 and k.state == BUILD_STATE.FREE and k.workNum > 0 and k.owner == nil)
    end
    return ret
end

function Merchant:findTarget()
    local allPossible = {}
    self.allPossible = allPossible
    --寻路所有可以访问的商店建筑物
    --按照pool的机制来访问不用管商店的距离
    if self.people.miaoPath.allBuilding == nil or self.people.dirty == true then
        local p = getPos(self.people.bg)
        local mxy = getPosMapFloat(1, 1, p[1], p[2])
        local mx, my = mxy[3], mxy[4]
        self.people.miaoPath:init(mx, my)
        table.insert(self.people.stateStack, self.people.state)
        self.people.state = PEOPLE_STATE.FIND_NEAR_BUILDING
    else
        allBuild = self.people.miaoPath.allBuilding
        for k, v in pairs(allBuild) do
            local ret = false
            ret = self:checkWork(k)
            if ret then
                table.insert(allPossible, k)
            end
        end

        if #allPossible > 0 then
            --按照建筑物的距离排序
            local myp = getPos(self.people.bg)
            local function cmp(a, b)
                local ap = getPos(a.bg)
                local bp = getPos(b.bg)
                local ad = mdist(myp, ap) 
                local bd = mdist(myp, bp)
                return ad < bd
            end
            table.sort(allPossible, cmp)
            self:checkAllPossible() 
        end
        if self.predictTarget == nil then
            self.predictTarget = self.map.backPoint
            self.actionContext = CAT_ACTION.MER_BACK 
        end
    end
end

function Merchant:checkAllPossible()
    for _, k in ipairs(self.allPossible) do
        table.insert(self.people.stateStack, {PEOPLE_STATE.GO_TARGET, self.map.backPoint, CAT_ACTION.MER_BACK})
        k:setOwner(self)
        self.predictTarget = k
        self.actionContext = CAT_ACTION.BUY_GOODS
        if Logic.inNew and not Logic.checkFarm then
            Logic.checkFarm = true
            self.people.merch = 0
            local w = Welcome2.new(self.people.onMerch, self)
            w:updateWord("你好啊!!!没想到这里还会有村落。。。我正在行商途中，正好过来走一遭。")
            global.director:pushView(w, 1, 0)
        end
        break
    end
end

