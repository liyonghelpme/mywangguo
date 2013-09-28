HeroData = {}
HeroData.heros = {}
HeroData.maxHeroId = 0
function HeroData:init(heros)
    HeroData.heros = heros
    for k, v in ipairs(heros) do
        HeroData.maxHeroId = math.max(HeroData.maxHeroId, v.hid)
    end
    HeroData.maxHeroId = HeroData.maxHeroId+1
end
function HeroData:getMaxHid()
    local temp =  HeroData.maxHeroId
    HeroData.maxHeroId = HeroData.maxHeroId+1
    return temp
end
function HeroData:addHero(param)
    table.insert(HeroData.heros, param)
    --Event:sendMsg(EVENT_TYPE.BUY_HERO, param)
end
function HeroData:sellHero(param)
    for k, v in ipairs(HeroData.heros) do
        if v.hid == param.hid then
            table.remove(HeroData.heros, k)
            break
        end
    end
end

function HeroData:getHero(hid)
    for k, v in ipairs(HeroData.heros) do
        if v.hid == hid then
            return v
        end
    end
    return nil
end

function HeroData:updateLevel(hid)
    for k, v in ipairs(HeroData.heros) do
        if v.hid == hid then
            v.level = v.level+1
            break
        end
    end
    Event:sendMsg(UPDATE_HERO, hid)
end

function HeroData:improveQuality(hid)
    for k, v in ipairs(HeroData.heros) do
        if v.hid == hid then
            v.quality = v.quality+1
            break
        end
    end
    Event:sendMsg(UPDATE_HERO, hid)
end
function HeroData:transferHero(hid)
    local hero = HeroData:getHero(hid)
    hero.job = hero.job+1
    Event:sendMsg(UPDATE_HERO, hid)
end

--类型 等级 品质 职业 
--物理攻击 魔法攻击 物防 魔防 生命 攻击频率 技能
function HeroData:getAttribute(kind, level, quality, job)
    return {physicAttack=10, magicAttack=0, physicDef=0, magicDef=0, }
end
