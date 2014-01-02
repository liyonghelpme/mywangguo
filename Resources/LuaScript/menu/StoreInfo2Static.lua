function StoreInfo2:initFarm()
    if self.build.data.IsStore == 2 then
        self.changeBut.text:setString("查看材料情报")
        self.ability:setString("生产力")
        self.changeBut:setCallback(self.onMat)
    end
end
function StoreInfo2:onMat()
    global.director:pushView(MatInfo2.new(self.build), 1)
end
