function StoreInfo2:initFarm()
    if self.build.data.IsStore == 2 or self.build.data.IsStore == 3 or self.build.data.IsStore == 5 then
        self.changeBut.text:setString("查看材料情报")
        self.ability:setString("生产力")
        self.changeBut:setCallback(self.onMat)
        self.goodsW:setString("生产")
    end
end
function StoreInfo2:onMat()
    global.director:pushView(MatInfo3.new(self.build), 1)
end
function StoreInfo2:initFactory()
    if self.build.id == 5 then
        self.changeBut.bg:setVisible(false)
        self.ability:setString("生产力")
        self.changeBut:setCallback(nil)
        self.goodsW:setString("生产")
    end
end
function StoreInfo2:initHouse()
    if self.build.data.kind == 5 then
        self.changeBut.bg:setVisible(false)
        self.changeBut:setCallback(nil)
        self.ability:setString("回复力")
        self.goodsW:setString("回复")
        self.goodsW:setString("居民")
        self.priceW:setString("等级")
        local uname = '--'
        local level = '--'
        if self.build.owner ~= nil then
            uname = self.build.owner.data.name
            level = self.build.owner.level+1
        end
        self.goodName:setString(str(uname))
        self.price:setString(str(level)) 
        self.banner:setVisible(false)
        setVisible(self.inGoods, false)
        setVisible(self.workNum, false)
    end
end
