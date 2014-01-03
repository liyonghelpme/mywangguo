function StoreInfo2:initFarm()
    if self.build.data.IsStore == 2 or self.build.data.IsStore == 3 or self.build.data.IsStore == 5 then
        self.changeBut.text:setString("查看材料情报")
        self.ability:setString("生产力")
        self.changeBut:setCallback(self.onMat)
        self.goodsW:setString("生产")
    end
end
function StoreInfo2:onMat()
    global.director:pushView(MatInfo2.new(self.build), 1)
end
function StoreInfo2:initFactory()
    if self.build.id == 5 then
        self.changeBut.bg:setVisible(false)
        self.ability:setString("生产力")
        self.changeBut:setCallback(nil)
        self.goodsW:setString("生产")
    end
end
