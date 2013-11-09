MapWidth=3000
MapHeight=1120
SIZEX=32
SIZEY=16
DEBUG=false
MAX_BUILD_ZORD=10000

Keys = {
    buildingKey,
    equipKey,
    drugKey,
    goldKey,
    silverKey,
    crystalKey,
    plantKey,
    soldierKey,
    freeKey,
    allTasksKey,
    herbKey,
    prescriptionKey,
    null,
    drugKey,
    fallThingKey,
    goodsListKey,
    magicStoneKey,
    skillsKey,
    statusPossibleKey,
    mapBloodKey,
    fightingCostKey,
    MoneyGameGoodsKey,
    ExpGameGoodsKey,
    equipSkillKey,
    ParticleKey,
    levelMaxFallGainKey,
    mineProductionKey,
}
CostData = {
    buildingData,
    equipData,
    drugData,
    goldData,
    silverData,
    crystalData,
    plantData,
    soldierData,
    freeData,
    allTasksData,
    herbData,
    prescriptionData,
    null,
    drugData,
    fallThingData,
    goodsListData,
    magicStoneData,
    skillsData,
    statusPossibleData,
    mapBloodData,
    fightingCostData,
    MoneyGameGoodsData,
    ExpGameGoodsData,
    equipSkillData,
    ParticleData,
    levelMaxFallGainData,
    mineProductionData,
}



--从1开始编号
--StoreGoods 里面的编号都要+1
GOODS_KIND = {
    BUILD=1,
	EQUIP = 2,
	DRUG = 3,
	GOLD = 4,
	SILVER = 5,
	CRYSTAL = 6,
	PLANT = 7,
	SOLDIER = 8,
	FREE_GOLD = 9,
	TASK = 10,
	HERB = 11,
	PRESCRIPTION = 12,
	NOTIFY = 13,
	RELIVE = 14,
	FALL_THING = 15,
	TREASURE_STONE = 16,
	MAGIC_STONE = 17,
	SKILL = 18,
	STATUS = 19,
	MAP_INFO = 20,
	FIGHT_COST = 21,
	MONEY_GAME_GOODS = 22,
	EXP_GAME_GOODS = 23,
	EQUIP_SKILL = 24,
	PARTICLES = 25,
	LEVEL_MAX_FALL_GAIN = 26,
	MINE_PRODUCTION = 27,
}
costKey = {"silver", "gold", "crystal"}
addKey = {"exp", }
PLAN_KIND = {
    PLAN_BUILDING=1,
    PLAN_SOLDIER=2,
}


KindsPre = {
    "build{ID}.png",
    "equip{ID}.png",
    "drug{ID}.png",
    "storeGold.png",
    "storeSilver.png",
    "storeCrystal.png",
    "Wplant{ID}.png",
    "soldier{ID}.png",
    "storeGold.png",
    "task",
    "herb{ID}.png",
    "prescription",
    nil,
    "drug{ID}.png",
    "",
    "stone{ID}.png",
    "magicStone{ID}.png",
    "skill{ID}.png",
    "status{ID}.png",
    nil,
    nil,
}

ZoneCenter = {
    {2526, 626},
    {1533, 726},
    {1533, 726},
    {1533, 726},
    {1533, 726},
}





SOW = 0
SEED = 1
MEDIUM = 2
MATURE = 3
ROT = 4


BUILD_ANI_OBJ = 0
BUILD_ANI_ROT = 1
BUILD_ANI_ANI = 2
buildAnimate = dict({
    {1, {{"mb0.png", "mb1.png", "mb2.png", "mb3.png", "mb4.png", "mb5.png", "mb6.png", "mb7.png"}, {62, 49}, 2000, 0, {50, 100}}},
    {140, {{"f0.png"}, {87, 37}, 2000, 1, {50, 50}}},
    {141, {{"f1.png"}, {87, 37}, 2000, 1, {50, 50}}},
    {202, {{"god0.png", "god1.png","god2.png","god3.png","god4.png","god5.png","god6.png","god7.png","god8.png"}, {101, 0}, 2000, 0, {50, 50}}},
    {203, {{"god0.png", "god1.png","god2.png","god3.png","god4.png","god5.png","god6.png","god7.png","god8.png"}, {28, 0}, 2000, 0, {50, 50}}},
    {204, {{"drugStore0.png",  "drugStore1.png","drugStore2.png","drugStore3.png","drugStore4.png","drugStore5.png","drugStore6.png","drugStore7.png","drugStore8.png","drugStore9.png"}, {31, -60}, 2000, 0, {0, 0}}},
    {205, {{"drugStore0.png",  "drugStore1.png","drugStore2.png","drugStore3.png","drugStore4.png","drugStore5.png","drugStore6.png","drugStore7.png","drugStore8.png","drugStore9.png"}, {109, -60}, 2000, 0, {0, 0}}},
    {206, {{"forgeShop0.png", "forgeShop1.png", "forgeShop2.png", "forgeShop3.png", "forgeShop4.png", "forgeShop5.png", "forgeShop6.png", "forgeShop7.png", "forgeShop8.png", "forgeShop9.png" }, {31, -60}, 2000, 0, {0, 0}}},
    {207, {{"forgeShop0.png", "forgeShop1.png", "forgeShop2.png", "forgeShop3.png", "forgeShop4.png", "forgeShop5.png", "forgeShop6.png", "forgeShop7.png", "forgeShop8.png", "forgeShop9.png"}, {109, -60}, 2000, 0, {0, 0}}},
    {162, {{"build162.png", "build162a1.png", "build162a2.png", "build162a3.png", "build162a4.png"}, {0, 0}, 2000, 2, {0, 0}}},
})

FARM_BUILD = 0
HOUSE_BUILD = 1
DECOR_BUILD = 2
CASTLE_BUILD = 3
GOD_BUILD = 4
DRUG_BUILD = 5
FORGE_SHOP = 6
BUSI_SOL = 7
STATIC_BOARD = 8
MINE_KIND = 9
LOVE_TREE = 10
RING_FIGHTING = 11
CAMP = 12
WALL = 13
CRYSTAL_DEF = 14
WIND = 15

buildFunc = dict({
{FARM_BUILD, {{"photo"}, {"acc", "sell"}}},
{HOUSE_BUILD, {{"photo"}, { "sell" }}},
{DECOR_BUILD, {{"photo"}, {"sell"}}},
{CASTLE_BUILD, {{"photo"}, {"tip"}}},
{GOD_BUILD, {{"photo"}, {"soldier"}}},
{DRUG_BUILD, {{"photo"}, {"allDrug"}}},
{FORGE_SHOP, {{"photo"}, {"allEquip"}}},
{MINE_KIND, {{"photo"}, {"acc"}}},
{LOVE_TREE, {{"photo", "invite"}, {"love", "loveRank"}}},
{RING_FIGHTING, {{}, {}}},
{CAMP, {{"photo"}, {"call"}}},
})


BUY_RES = dict({
    {"silver", "buySilver"},
    {"crystal", "buyCrystal"},
    {"gold", "buyGold"},
})

obstacleBlock = dict(
{{320006, 1}, {310005, 1}, {310007, 1}, {310003, 1}, {330007, 1}, {320004, 1}, {320002, 1}, {330005, 1}, {620026, 1}, {630025, 1}, {620024, 1}, {680008, 1}, {690009, 1}, {690007, 1}, {680008, 1}, {680006, 1}, {690005, 1}, {680004, 1}, {690003, 1}, {330015, 1}, {330017, 1}, {330019, 1}, {650013, 1}, {620018, 1}, {650017, 1}, {640028, 1}, {660030, 1}, {300042, 1}, {640018, 1}, {290025, 1}, {290029, 1}, {290027, 1}, {650029, 1}, {610039, 1}, {640016, 1}, {660016, 1}, {660014, 1}, {320008, 1}, {280030, 1}, {280028, 1}, {320010, 1}, {630033, 1}, {620020, 1}, {650015, 1}, {630019, 1}, {630017, 1}, {280032, 1}, {600024, 1}, {600022, 1}, {280036, 1}, {280038, 1}, {630027, 1}, {610019, 1}, {310043, 1}, {640034, 1}, {640032, 1}, {600020, 1}, {650031, 1}, {610021, 1}, {610025, 1}, {610023, 1}, {600040, 1}, {300010, 1}, {300008, 1}, {630039, 1}, {600042, 1}, {270031, 1}, {270037, 1}, {310027, 1}, {310029, 1}, {310023, 1}, {310025, 1}, {310021, 1}, {330009, 1}, {300016, 1}, {300020, 1}, {300018, 1}, {270029, 1}, {290039, 1}, {290037, 1}, {650035, 1}, {650033, 1}, {290031, 1}, {310019, 1}, {310017, 1}, {310015, 1}, {310011, 1}, {320018, 1}, {300028, 1}, {320020, 1}, {300030, 1}, {300024, 1}, {320016, 1}, {300026, 1}, {300022, 1}, {290043, 1}, {290041, 1}, {330021, 1}, {660032, 1}, {670015, 1}, {670013, 1}, {310009, 1}, {660036, 1}, {320024, 1}, {320022, 1}, {590023, 1}, {300040, 1}, {590021, 1}}
)


TrainZone = {{100, 100, 2800, 400}}
FullZone = {{987, 100, 1914, 438}}
BUILD_ZONE = {{100, 100, 2000, 438}}
MONSTER_ZONE = {{2000, 100, 2800, 438}}

WALL_OFFXY = {
[0]={54, 59},
[1]={53, 57},
[2]={42, 58},
[3]={48, 58},
}
