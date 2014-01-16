Camera = class()
function Camera:ctor(m)
    self.map = m
    self.bg = CCNode:create()
    local vs = getVS()
    --中间产生一个2个像素的黑线
    self.renderTexture = CCRenderTexture:create(vs.width/2-1, FIGHT_HEIGHT)
    --渲染进来 并显示出来
    self.bg:addChild(self.renderTexture)
    self.moveNode = addNode(self.bg)
    self.needUpdate = true
    registerEnterOrExit(self)
end
function Camera:trace(o)
end
function Camera:update(diff)
end
function Camera:render()
end


