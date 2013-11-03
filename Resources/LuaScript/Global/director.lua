Scene = class()
function Scene:ctor()
    self.bg = CCScene:create()
end

Director = class()
function Director:ctor()
    self.stack = {}
    self.designSize = {800, 480}
    local vs = CCDirector:sharedDirector():getVisibleSize()
    self.disSize = {vs.width, vs.height}
    self.sceneStack = {}
    self.curScene = nil

    self.emptyScene = nil
    self.controlledStack = {}

end
function Director:pushControlledFrag(view, dark, autoPop)
end
function Director:popControlledFrag(view)
end

function Director:pushPage(view, z)
end

--view 封装了 CCNode
function Director:pushView(view, dark, autoPop, ani)
    print('pushView', #self.stack)
    if dark == 1 then
        local temp = {}
        temp.bg = CCNode:create()
        local d = Dark.new()
        temp.bg:addChild(d.bg)
        temp.bg:addChild(view.bg)
        self.curScene.bg:addChild(temp.bg)
        table.insert(self.stack, temp)
    else
        self.curScene.bg:addChild(view.bg)
        table.insert(self.stack, view)
        print('push View', #self.stack)
    end
    --默认有动画
    if ani == nil then
        local sca = view.bg:getScale()
        setScale(view.bg, 0.1)
        view.bg:runAction(sinein(sequence({scaleto(0.2, sca, sca)})))
    end
    --MyPlugins:getInstance():sendCmd("hideAds", "");
end

function Director:removeFirstView()
    local v = self.stack[1]
    v.bg:removeFromParentAndCleanup(true)
    table.remove(self.stack, 1)
end

function Director:popView()
    local v = self.stack[#self.stack]
    print('popView', #self.stack, v, v.bg)
    v.bg:retain()
    v.bg:removeFromParentAndCleanup(true)
    table.remove(self.stack, #self.stack)
    v.bg:runAction(sineout(sequence({scaleto(0.2, 0.1, 0.1), callfunc(nil, removeSelf, v.bg)})))
    self.curScene.bg:addChild(v.bg)
    v.bg:release()
    --MyPlugins:getInstance():sendCmd("showAds", "");
end
--上一个场景没有对话框
function Director:popTransfer()
    print("popTransfer", #self.sceneStack, self.sceneStack[1])
    self.curScene = self.sceneStack[#self.sceneStack-1]
    table.remove(self.sceneStack, #self.sceneStack)
    --主要是云朵
    local cd = self.stack[1]
    cd.bg:retain()
    cd.bg:removeFromParentAndCleanup(false)
    --BattleLogic.cloud.bg:retain()
    --BattleLogic.cloud.bg:removeFromParentAndCleanup(false)
    print("self.curScene.bg", self.curScene.bg)
    self.curScene.bg:addChild(cd.bg)
    cd.bg:release()
    --BattleLogic.cloud.bg:release()

    CCDirector:sharedDirector():popScene()
    --self.stack = {self.stack[1]}
end

--不要清理动画
function Director:transferScene(view)
    --self.stack 不变
    local cd = self.stack[1]
    cd.bg:retain()
    cd.bg:removeFromParentAndCleanup(false)
    --BattleLogic.cloud.bg:retain()
    --BattleLogic.cloud.bg:removeFromParentAndCleanup(false)
    view.bg:addChild(cd.bg)
    cd.bg:release()
    --BattleLogic.cloud.bg:release()
    --cloud是由背景节点的所以不能直接使用
    --self.stack = {self.stack[1]}

    --压入场景  如果第一次进入战斗场景 则 push 否则 replace掉旧的
    --BattleScene enterScene inBattle = true
    if BattleLogic.inBattle == false then
        CCDirector:sharedDirector():pushScene(view.bg)
    else
        CCDirector:sharedDirector():replaceScene(view.bg)
        table.remove(self.sceneStack)
    end
    self.curScene = view
    table.insert(self.sceneStack, view)
    print("transferScene", #self.sceneStack)
end 

function Director:replaceScene(view)
    CCDirector:sharedDirector():replaceScene(view.bg)
    self.curScene = view
    self.stack = {}
    table.remove(self.sceneStack)
    table.insert(self.sceneStack, view)
    print("replace", #self.sceneStack) 
end
function Director:pushScene(view)
    CCDirector:sharedDirector():pushScene(view.bg)
    self.curScene = view
    table.insert(self.sceneStack, view)
    print("pushScene", #self.sceneStack)
end

function Director:onlyRun(view)
    self.curScene = view
    table.insert(self.sceneStack, view)
    print("scene runWithScene", #self.sceneStack)
end

function Director:runWithScene(view)
    CCDirector:sharedDirector():runWithScene(view.bg)
    self.curScene = view
    table.insert(self.sceneStack, view)
    print("scene runWithScene", #self.sceneStack)
end

function Director:popScene()
    CCDirector:sharedDirector():popScene()
    self.curScene = self.sceneStack[#self.sceneStack-1]
    table.remove(self.sceneStack, #self.sceneStack)
    print("scene popScene", #self.sceneStack)
    self.stack = {} 
end



