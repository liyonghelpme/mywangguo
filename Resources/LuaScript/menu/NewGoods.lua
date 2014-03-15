NewGoods = class()
--获得技能 和 银币
function NewGoods:ctor(kind, pid)
    print("NewGoods", kind, pid)
    local vs = getVS()
    self.bg = CCNode:create()
    local sz = {width=1024, height=768}
    self.temp = setPos(addNode(self.bg), {0, fixY(sz.height, 0+sz.height)+0})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "sdialoga.png"), {512, fixY(sz.height, 396)}), {633, 427}), {0.50, 0.50}), 255)
    
    print("small", createSmallDialogb)
    local sp = createSmallDialogb()
    local sp = setAnchor(setPos(addChild(self.temp, sp), {512, fixY(sz.height, 403)}), {0.50, 0.50})

    local but = ui.newButton({image="butc.png", text="确定", font="f1", size=27, delegate=self, callback=closeDialog, shadowColor={0, 0, 0}, color={255, 255, 255}})
    but:setContentSize(158, 50)
    setPos(addChild(self.temp, but.bg), {509, fixY(sz.height, 551)})
    local sp = setOpacity(setAnchor(setSize(setPos(addSprite(self.temp, "dialogCat.png"), {749, fixY(sz.height, 500)}), {101, 157}), {0.50, 0.50}), 255)

    if kind == 0 then
        local edata = Logic.equip[pid]
        local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="新装备 "..edata.name, size=35, color={10, 10, 10}, font="f1", shadowColor={0, 0, 0}})), {0.50, 0.50}), {516, fixY(sz.height, 231)})

        local sp = setBox(setOpacity(setAnchor(setPos(addSprite(self.temp, "equip"..pid..".png"), {510, fixY(sz.height, 366)}), {0.50, 0.50}), 255), {200, 200})
        local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text=edata.des, size=25, color={10, 76, 176}, font="f1", shadowColor={0, 0, 0}})), {0.50, 0.50}), {511, fixY(sz.height, 488)})
    elseif kind == 1 then
        local edata = Logic.equip[pid]
        local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="研究新装备 "..edata.name, size=35, color={10, 10, 10}, font="f1", shadowColor={0, 0, 0}})), {0.50, 0.50}), {516, fixY(sz.height, 231)})

        local sp = setBox(setOpacity(setAnchor(setPos(addSprite(self.temp, "equip"..pid..".png"), {510, fixY(sz.height, 366)}), {0.50, 0.50}), 255), {200, 200})
        local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text=edata.des, size=25, color={10, 76, 176}, font="f1", shadowColor={0, 0, 0}})), {0.50, 0.50}), {511, fixY(sz.height, 488)})
    elseif kind == 2 then
        local w 
        local p 
        if pid == 1 then
            w = '新兵种 弓兵'
            p = 'cat_arrow_run_0.png'
        elseif pid == 2 then
            w = '新兵种 魔法兵'
            p = 'cat_magic_run_0.png'
        elseif pid == 3 then
            w = '新兵种 骑兵'
            p = 'cat_cavalry_run_0.png'
        end
        local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text=w, size=35, color={10, 10, 10}, font="f1", shadowColor={0, 0, 0}})), {0.50, 0.50}), {516, fixY(sz.height, 231)})
        local sp = setOpacity(setAnchor(setPos(addSprite(self.temp, p), {510, fixY(sz.height, 366)}), {0.50, 0.50}), 255)
        local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="在兵力菜单训练士兵", size=25, color={10, 76, 176}, font="f1", shadowColor={0, 0, 0}})), {0.50, 0.50}), {511, fixY(sz.height, 488)})
    elseif kind == 3 then
        local w = "获得土地产权证书"
        local p
        local w2
        if pid == 1 then
            w = "获得土地产权证书"
            p = 'storeGoods38.png'
            w2 = '土地产权证书可以开启新的土地'
        elseif pid == 2 then
            w = '合战人数增加1'
            p = 'storeGoods39.png'
            w2 = '战斗配置页面可以选择更多的村民参展'
        end
        
        local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text=w, size=35, color={10, 10, 10}, font="f1", shadowColor={0, 0, 0}})), {0.50, 0.50}), {516, fixY(sz.height, 231)})
        local sp = setBox(setOpacity(setAnchor(setPos(addSprite(self.temp, p), {510, fixY(sz.height, 366)}), {0.50, 0.50}), 255), {200, 200})
        local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text=w2, size=25, color={10, 76, 176}, font="f1", shadowColor={0, 0, 0}})), {0.50, 0.50}), {511, fixY(sz.height, 488)})
    elseif kind == 4 then
        local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text="获得银币", size=35, color={10, 10, 10}, font="f1", shadowColor={0, 0, 0}})), {0.50, 0.50}), {516, fixY(sz.height, 231)})
        local sp = setBox(setOpacity(setAnchor(setPos(addSprite(self.temp, "silverIcon.png"), {510, fixY(sz.height, 366)}), {0.50, 0.50}), 255), {200, 200})
        local w = setPos(setAnchor(addChild(self.temp, ui.newTTFLabel({text=pid..'银币', size=25, color={10, 76, 176}, font="f1", shadowColor={0, 0, 0}})), {0.50, 0.50}), {511, fixY(sz.height, 488)})
    end

    centerUI(self)
end
