Arrow = class()
--模拟jump的parabolic jump 方程
--显示简单的跳跃运动 加上曲线的切线 方向 delta y / delta x = dir 0 个点 1 个点 lastPoint now Point 得到当前的方向 差分方程
function Arrow:ctor(src, target, start, over)
    self.bg = CCSprite:create("s23e0.png")
    local dx = over[1]-start[1]
    local dy = over[2]-start[2]
    --图片本身 -180 逆时针
    --转换成顺时针 角度 取负数值
    local ang = math.atan2(dy, dx)*180/math.pi+180
    print("start over", simple.encode(start), simple.encode(over), ang)
    setRotation(setPos(self.bg, start), -ang)
    --self.bg:runAction(moveto(1, over[1], over[2]))
    self.bg:runAction(jumpTo(1,  over[1], over[2], 30, 1))
    local function doHarm()
        target:doHarm(src.data.attack)
        removeSelf(self.bg)
    end
    self.bg:runAction(sequence({fadein(0.2), delaytime(0.6), fadeout(0.2), callfunc(nil, doHarm)}))
    
    registerEnterOrExit(self)    
    registerUpdate(self)

    self.lastPoint = start
end
function Arrow:update(diff)
    local curPos = getPos(self.bg)
    local dx = curPos[1]-self.lastPoint[1]
    local dy = curPos[2]-self.lastPoint[2]
    local ang = math.atan2(dy, dx)*180/math.pi+180
    setRotation(self.bg, -ang)
    self.lastPoint = curPos
end

