Arrow = class()
function Arrow:ctor(sol, target, start, over)
    self.bg = CCSprite:create("s23e0.png")
    local dx = over[1]-start[1]
    local dy = over[2]-start[2]
    --图片本身 -180 逆时针
    --转换成顺时针 角度 取负数值
    local ang = math.atan2(dy, dx)*180/math.pi+180
    print("start over", simple.encode(start), simple.encode(over), ang)
    setRotation(setPos(self.bg, start), -ang)
    self.bg:runAction(moveto(1, over[1], over[2]))
    local function doHarm()
        target:doHarm(10)
        removeSelf(self.bg)
    end
    self.bg:runAction(sequence({fadein(0.2),delaytime(0.6), fadeout(0.2), callfunc(nil, doHarm)}))
end
