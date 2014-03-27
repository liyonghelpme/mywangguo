FlyObject = class()
function FlyObject:ctor(obj, c, cb, delegate)
    self.callback = cb
    self.delegate = delegate
    self.num = 0
    self.cost = c
    self.FLY_WIDTH = 30
    self.FLY_HEIGHT = 30

    self.bg = CCNode:create()
    --ui 元素在屏幕上的位置 convertToWorldSpace 进行转化
    local TarPos = dict({{"silver", {297, fixY(nil, 460)}}, {"crystal", {253, fixY(nil, 460)}}, {"gold", {550, fixY(nil, 460)}}, {"exp", {196, fixY(nil, 427)}}})
    local defaultPos = {297, fixY(nil, 460)}

    local bsize = obj:getContentSize()
    local coor2 = obj:convertToWorldSpace(ccp(0, bsize.height+10))
    coor2 = {coor2.x, coor2.y}

    local waitTime = 0
    print("FlyObject", simple.encode(self.cost))
    for k, v in pairs(self.cost) do
        if v ~= 0 then
            local cut = 1
            if v < 10 then
                cut = 1
            elseif v < 100 then
                cut = 3
            else
                cut = 5
            end
            self.num = self.num+cut
            local showVal = math.floor(v/cut)
            for j=0, cut-1, 1 do
                local flyObj = setAnchor(setSize(addSprite(self.bg, k..".png"), {self.FLY_WIDTH, self.FLY_HEIGHT}), {0.5, 0})
                local tar = getDefault(TarPos, k, self.defaultPos)
                local dis = distance(coor2, tar)
                --addSprite(self.bg, "dialogRankShadow.png") 
                setPos(flyObj, coor2)
                print("flyObjPos", simple.encode(coor2), waitTime, simple.encode(tar))
                flyObj:runAction(sequence(
                    {   
                        fadeto(0, 0), 
                        delaytime(waitTime), 
                        fadeto(0, 255), 
                    sinein(bezierto(
                        1.5+dis/100*0.25,
                        coor2[1], coor2[2], 
                        coor2[1]+150, coor2[2]+300, 
                        coor2[1]+100, coor2[2]-100, 
                        tar[1], tar[2])), 
                        callfunc(self, self.pickMe, flyObj)
                    }))
                if j == cut-1 then
                    showVal = v - showVal*cut
                end
                local words = setColor(setAnchor(setPos(addLabel(flyObj, ''..showVal, "", 23), {self.FLY_WIDTH, self.FLY_HEIGHT / 2}), {0, 0.5}), {6, 26*2.5, 46*2.5})
                waitTime = waitTime+0.2
            end
        end
    end
end
function FlyObject:pickMe(param)
    print("pickMe")
    removeSelf(param)
    self.num = self.num-1
    if self.num == 0 then
        if self.callback ~= nil then
            self.callback(self.delegate)
        end
    end
end
