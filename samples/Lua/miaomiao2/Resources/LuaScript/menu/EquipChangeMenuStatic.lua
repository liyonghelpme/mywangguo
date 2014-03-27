function EquipChangeMenu:setWeaponInfo()
    self.ename:setString(self.allData[self.selPanel].name)
    self.attackNum:setString("+"..self.allData[self.selPanel].attack)
    local edata = self.allData[self.selPanel]
    if edata.defense > 0 then
        self.secAtt:setString("防御")
        self.defNum:setString("+"..edata.defense)
    elseif edata.labor > 0 then
        self.secAtt:setString("劳动")
        self.defNum:setString("+"..edata.labor)
    else
        self.secAtt:setString("")
        self.defNum:setString("")
    end
end
function EquipChangeMenu:setHeadInfo()
    local edata = self.allData[self.selPanel]
    self.ename:setString(edata.name)
    local allAtt = {'defense', 'attack', 'health', 'brawn', 'labor', 'shoot'}
    local allCn = {'防御', '攻击', '体力', '腕力', '劳动', '远程'}
    local fir = true
    self.secAtt:setString("")
    self.secNum:setString("")
    for k, v in ipairs(allAtt) do
        if edata[v] > 0 then
            if fir then
                fir = false
                self.firAtt:setString(allCn[k])
                self.firNum:setString('+'..edata[v])
            else
                self.secAtt:setString(allCn[k])
                self.secNum:setString('+'..edata[v])
            end
        end
    end

end
function EquipChangeMenu:setBodyInfo()
    local edata = self.allData[self.selPanel]
    self.ename:setString(edata.name)
    local allAtt = {'defense', 'attack', 'health', 'brawn', 'labor', 'shoot'}
    local allCn = {'防御', '攻击', '体力', '腕力', '劳动', '远程'}
    local fir = true
    self.secAtt:setString("")
    self.secNum:setString("")
    for k, v in ipairs(allAtt) do
        if edata[v] > 0 then
            if fir then
                fir = false
                self.firAtt:setString(allCn[k])
                self.firNum:setString('+'..edata[v])
            else
                self.secAtt:setString(allCn[k])
                if edata[v] > 0 then
                    self.secNum:setString('+'..edata[v])
                else
                    self.secNum:setString(edata[v])
                end
            end
        end
    end
end


function EquipChangeMenu:getFirstAtt(edata)
    local allAtt = {'defense', 'attack', 'health', 'brawn', 'labor', 'shoot'}
    local allCn = {'防御', '攻击', '体力', '腕力', '劳动', '远程'}
    
    for k, v in ipairs(allAtt) do
        if edata[v] > 0 then
            return allCn[k], edata[v]
        end
    end
end

