LoadingScene = class()
function LoadingScene:ctor()
    self.name = 'Loading'
    self.bg = CCScene:create()
    local u = CCUserDefault:sharedUserDefault()
    local username = u:getStringForKey("username")
    Logic.username = username

    local sf = CCSpriteFrameCache:sharedSpriteFrameCache()
    sf:addSpriteFramesWithFile("loadAni.plist")
    local ani = createAnimation("loadingAni", "load%d.png", 0, 8, 1, 1, true)
    local sp = createSprite("load0.png")
    addChild(self.bg, sp)
    local vs = getVS()
    setScale(setPos(sp, {vs.width-228*0.7, 101*0.7}), 1)
    sp:runAction(repeatForever(CCAnimate:create(ani)))

    local lab = ui.newTTFLabel({text="Loading...", size=25})
    setAnchor(setPos(addChild(self.bg, lab), {16, 768-743}), {0, 0.5})

    self.needUpdate = true
    registerEnterOrExit(self)
end
function LoadingScene:signin(rep, param)
    if rep ~= nil then
        --初始化用户建筑物等信息 从服务器初始化么
        --推送到服务器上面 还是 服务器上面初始化好数据推送给客户端呢？
        --主要是人口和建筑数据
        Logic.uid = rep.uid
        Logic.bdata = rep.allB
        Logic.pdata = rep.allP
        Logic.resource = {silver=rep.user.silver, gold=rep.user.gold}
        Logic.researchGoods = simple.decode(rep.researchData.researchGoods)
        Logic.ownGoods = simple.decode(rep.researchData.ownGoods)
        
        Logic.newUser = rep.newUser
        Logic.newStage = rep.newStage

        --[[
        Logic.soldiers = simple.decode(rep.user.soldiers)
        Logic.inSell = simple.decode(rep.user.inSell)
        Logic.catData = simple.decode(rep.user.catData)
        Logic.curVillage = rep.user.curVillage
        Logic.gameStage = rep.user.gameStage
        Logic.ownPeople = simple.decode(rep.user.ownPeople)
        Logic.ownBuild = simple.decode(rep.user.ownBuild)
        --]]
        for k, v in pairs(rep.tableData) do
            print("handle", k, v)
            if k == 'holdNum' then
                Logic[k] = tableToDict(v)
            elseif k == 'openMap' or k == 'ownVillage' or k == 'ownCity' then
                Logic[k] = arrayDict(simple.decode(v))
            elseif type(v) ~= 'number' then
                Logic[k] = tableToDict(simple.decode(v))
            end
        end

        for k, v in pairs(rep.user) do
            if type(v) == 'string' then
                Logic[k] = simple.decode(v)
            else
                Logic[k] = v
            end
        end


        if Logic.showMapYet == 0 then
            Logic.showMapYet = false
        else
            Logic.showMapYet = true
        end
        print("soldiers", simple.encode(Logic.soldiers), type(Logic.soldiers))
        if rep.user.inResearch == 0 then
            Logic.inResearch = nil
        else
            Logic.inResearch = {math.floor(rep.user.inResearch/1000), rep.user.inResearch%1000}
        end

        global.director:replaceScene(TMXScene.new())
        if rep.newUser then
            
        else
        end
    end
end

function LoadingScene:update(diff)
    --[[
    if true then
        return
    end
    --]]
    if Logic.username ~= nil and Logic.username ~= '' and not self.initYet then
        self.initYet = true
        print("User username is", Logic.username)
        --global.director:replaceScene(TMXScene.new())
        sendReq("signin", dict({{"username", Logic.username}}), self.signin, nil, self)
    elseif not self.initYet then
        MyPlugins:getInstance():sendCmd("getUsername", "")
        local u = CCUserDefault:sharedUserDefault()
        local username = u:getStringForKey("username")
        Logic.username = username
        print("user name is", Logic.username)
    end
end

