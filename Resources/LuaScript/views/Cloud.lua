require "views.BattleScene"
Cloud = class()
--切换场景的时候 显示的云朵
function Cloud:ctor()
    self.bg = CCSpriteBatchNode:create("cloud.png")
    local vx = getVS()
    local cW = 250
    local cH = 150
    local row = math.ceil(vx.width/cW)
    local col = math.ceil(vx.height/cH)
    self.clouds = {}
    print("rowNum colNum", row, col)
    local initX = cW/2
    local initY = cH/2
    for i=0, row-1, 1 do
        for j=0, col-1, 1 do
            local temp = setScale(setPos(CCSprite:create("cloud.png"), {i*cW+initX, j*cH+initY}), 0.1)
            self.bg:addChild(temp)
            temp:runAction(sequence({spawn({fadein(1), scaleto(1, 1.0, 1.0)})}))
            temp:runAction(repeatForever(rotateby(2, 360)))
            table.insert(self.clouds, temp)
        end
    end
    --等待时间足够 
    --当下面场景准备好了 
    --则开始取消掉云朵
    self.bg:runAction(sequence({delaytime(2), callfunc(self, self.finishShow)}))
    --当云朵覆盖满了之后 再replace Scene 并且要保持住Cloud transfer
    registerEnterOrExit(self)
end
function Cloud:enterScene()
    registerUpdate(self)
end
function Cloud:exitScene()
end
--通知场景可以切换建筑物了
function Cloud:finishShow()
    print("finish show")
    self.finishShow = true
    --global.director.curScene:beginSwitch()
    BattleLogic.cloud = self
    --进入战斗场景
    --多个战斗场景之间切换
    if BattleLogic.quitBattle == false then
        --BattleLogic.clearBattle()
        global.director:transferScene(BattleScene.new())
    --退出战斗场景
    else
        BattleLogic.clearBattle()
        global.director:popTransfer()
    end
end
function Cloud:finishCloud()
    for k, v in ipairs(self.clouds) do
        v:stopAllActions()
        v:runAction(sequence({spawn({fadeout(1), scaleto(1, 0.1, 0.1)})}))
        v:runAction(repeatForever(rotateby(2, 360)))
    end
    self.bg:runAction(sequence({delaytime(2), callfunc(self, self.removeSelf)}))
end
function Cloud:removeSelf()
    global.director:popView()
end
--监控场景初始化结束
function Cloud:update(diff)
    --print("cloud diff", diff, BattleLogic.finishInitBuild, self.finishShow)
    if self.finishShow == true and BattleLogic.finishInitBuild  then
        self.finishShow = false
        self:finishCloud()
    end
end
