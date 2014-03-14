DialogController = class()
function DialogController:ctor(sc)
    self.scene = sc
    self.bg = CCLayer:create()
    self.cmds = {}
    self.bannerStack = {}
    self.dialogStack = {}

    registerEnterOrExit(self)
end
--伴随场景的切换 多次进出场景
function DialogController:enterScene()
    registerUpdate(self)
end
function DialogController:update(diff)
    local now = Timer.now
    if #self.bannerStack > 0 then
        local first = self.bannerStack[1]
        if now - first[2] > 3 then
            table.remove(self.bannerStack, 1)
        end
    end
    --没有全局对话框
    if #global.director.stack == 0 then
        if #self.cmds > 0 then
            local curCmd = table.remove(self.cmds, 1)
            if curCmd['cmd'] == "login" then
            elseif curCmd['cmd'] == "roleName" then
                global.director:pushView(RoleName.new(), 1, 0)
            elseif curCmd['cmd'] == 'firstGame' then
                global.director:pushView(NewDialog.new(getStr("firstGame")), 1, 0)
            elseif curCmd['cmd'] == 'monGen' then
                global.director:pushView(Happen.new(getStr("monGen")), 1, 0)
            end
        end
    end
    if #global.director.stack == 0 then
        if #self.dialogStack > 0 then
            local d = table.remove(self.dialogStack, 1)
            global.director:pushView(d, 1, 0)
            d.bg:release()
        end
    end
end

function DialogController:addDialog(d)
    d.bg:retain()
    table.insert(self.dialogStack, d)
end

--可能t[1] 已经删除自己了 只是DialogController 还不知道
function DialogController:addBanner(banner)
    while #self.bannerStack > 5 do
        local t = table.remove(self.bannerStack, 1)
        if t[1].bg ~= nil then
            removeSelf(t[1].bg)
        end
    end

    local maxOff = #self.bannerStack
    local dis = global.director.disSize
    local initX = dis[1]/2;
    local initY = dis[2]/2;
    for i = 1, #self.bannerStack, 1 do
        local ban = self.bannerStack[i][1]
        ban:setMoveAni(initX, initY+70*maxOff)
        maxOff = maxOff-1
    end
    table.insert(self.bannerStack, {banner, Timer.now})
    global.director.curScene.bg:addChild(banner.bg, MAX_BUILD_ZORD)
end
function DialogController:addCmd(c)
    table.insert(self.cmds, c)
end

function DialogController:exitScene()
end
