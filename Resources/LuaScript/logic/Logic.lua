Logic = {}
Logic.allHeroData = nil
Logic.heroes = nil
Logic.formation = nil
Logic.level = nil
Logic.maxHid = nil
function getMaxStrength()
    return 120
end
function getAttack(hid)
    return 100
end
function getHealth(hid)
    return 100
end
function getMagicDef(hid)
    return 100
end
function getPhysicDef(hid)
    return 100
end
function getAttSpeed(hid)
    return 100
end
function getMove(hid)
    return 100
end
function getSkill(hid)
    return 100
end
function getEquip(hid)
    return 100
end
function getLevelupGold(hid)
    return 100
end
function getTransferGold(hid)
    return 100
end
function getFastGold(hid)
    return 100
end
function getMaxHid()
    Logic.maxHid = Logic.maxHid+1
    return Logic.maxHid
end
