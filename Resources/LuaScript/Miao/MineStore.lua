MineStore = class(FuncBuild)
function MineStore:initBottom()
    self.baseBuild.bottom = CCNode:create()
    self.baseBuild.bg:addChild(self.baseBuild.bottom, 1) 
    self.s1 = setSize(setPos(setAnchor(addSprite(self.baseBuild.bottom, "white2.png"), {0.5, 0}), {0, 0}), {SIZEX*2+10, SIZEY*2+10})
    self.s2 = setSize(setPos(setAnchor(addSprite(self.baseBuild.bottom, "white2.png"), {0.5, 0}), {SIZEX, SIZEY}), {SIZEX*2+10, SIZEY*2+10})
end
function MineStore:setBottomColor(c)
    if c == 0 then
        setColor(self.s1, {255, 0, 0})
        setColor(self.s2, {255, 0, 0})
    else
        setColor(self.s1, {0, 255, 0})
        setColor(self.s2, {0, 255, 0})
    end
end
