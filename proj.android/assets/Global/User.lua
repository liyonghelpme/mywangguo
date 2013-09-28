User = class()
function User:ctor()
    self.papayaName = "liyong"
    self.papayaId = "liyong"

    self.resource = {}
    self.buildings = {}
    self.soldiers = {}
    self.drugs = {}
    self.equips = {}
    self.herbs = {}
    self.treasureStone = {}
    self.starNum = {
        {3, 3, 3, 3, 3, 3, 3},
        {3, 3, 3, 3, 3, 3, 3},
        {3, 3, 3, 3, 3, 3, 3},
        {3, 3, 3, 3, 3, 3, 3},
        {3, 3, 3, 3, 3, 3, 3},
    }
end
function User:initDataOver(data, param)
    if data ~= nil then
        self.uid = data.uid
        print("sendMsg")
        Event:sendMsg(EVENT_TYPE.INITDATA)
    end
end
function User:initData()
   --Network.postData("login", self, self.initDataOver, {papayaId=self.papayaId, papayaName=self.papayaName})
   self:initDataOver({uid=1234})
end
