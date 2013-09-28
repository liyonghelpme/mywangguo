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
    local coor2 = obj:convertToNodeSpace(ccp(bsize.width/2, bsize.height+10))

    var item = cost.items();
//        trace("flyObject", cost);
    //var offY = 0;
    local waitTime = 0
    for k, v in pairs(cost) do
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
                local flyObj = setAnchor(setSize(addSprite(self.bg, "images/"..k..".png"), {self.FLY_WIDTH, self.FLY_HEIGHT}), {0.5, 0})
                local tar = getDefault(TarPos, k, self.defaultPos)
                local dis = distance(coor2, tar)
                flyObj:runAction(sequence(itintto(0, 0, 0, 0), delaytime(waitTime), itintto(255, 255, 255, 255), sinein(bezierby(
                        1.5+dis*25/1000,
                        coor2[0], coor2[1], 
                        coor2[0]+150, coor2[1]+300, 
                        coor2[0]+100, coor2[1]-100, 
                        tar[0], tar[1])), callfunc(self, self.pickMe, flyObj)))
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
    removeSelf(param)
    self.num = self.num-1
end
