Skills = {}
function Skills.getSkill(id)
    local data = Skills[id]
    return SkillModel.new(data[1],data[2],data[3],data[4],data[5],data[6],data[7],data[8])
end

Skills[1] = {100, 1, 4, 1, 0, 0, 0, 0}
Skills[2] = {120, 2, 4, 3, 0, 0, 0, 0}
Skills[3] = {80, 3, 4, 4, 0, 0, 0, 0}
Skills[4] = {100, 1, 4, 3, 0, 0, 0, 0}
Skills[5] = {150, 1, 2, 1, 0, 0, 0, 0}
Skills[6] = {150, 2, 1, 3, 0, 0, 0, 0}
Skills[7] = {150, 3, 3, 1, 0, 0, 0, 0}
Skills[8] = {150, 1, 1, 2, 0, 0, 0, 0}

json = require ("dkjson")

local data = json.decode('{"actions":{"skill_02":{"name":"地光","time":1.2,"num":12},"skill_01":{"name":"火把","time":1.2,"num":12},"skill_06":{"name":"骷髅头","time":0.6,"num":6},"skill_04":{"name":"灯光","time":0.6,"num":6},"skill_05":{"name":"眼睛","time":0.6,"num":6},"skill_03":{"name":"萤光","time":0.5,"num":5}},"scenes":[{"childs":[{"dir":"skill_03","r":0,"z":0,"py":586,"type":"action","sy":1,"sx":1,"px":531},{"dir":"skill_02","r":0,"z":0,"py":301,"type":"action","sy":1,"sx":1,"px":178},{"dir":"skill_01","r":0,"z":0,"py":573,"type":"action","sy":0.7,"sx":0.7,"px":773},{"dir":"skill_01","r":-5,"z":0,"py":590,"type":"action","sy":0.7,"sx":0.7,"px":254},{"dir":"skill_01","r":-18,"z":2,"py":172,"type":"action","sy":1,"sx":1,"px":832},{"dir":"skill_01","sx":1,"sy":1,"py":134,"r":12,"type":"action","z":2,"px":133},{"type":"object","sx":1,"r":0,"py":57,"file":"scene1_1a.png","sy":1,"z":3,"px":123},{"type":"object","sx":1,"r":0,"py":92,"file":"scene1_1b.png","sy":1,"z":3,"px":848},{"type":"object","sx":1,"r":0,"py":533,"file":"scene1_1c.png","sy":1,"z":1,"px":257},{"type":"object","sx":1,"r":0,"py":516,"file":"scene1_1d.png","sy":1,"z":1,"px":772}],"background":"background1.png","name":"亡灵场景1"},{"childs":[{"dir":"skill_02","r":0,"z":0,"py":214,"type":"action","sy":1,"sx":1,"px":522},{"dir":"skill_03","r":0,"z":0,"py":595,"type":"action","sy":1,"sx":1,"px":885},{"dir":"skill_04","r":3,"z":1,"py":556,"type":"action","sy":0.7,"sx":0.7,"px":779},{"dir":"skill_04","r":-18,"z":1,"py":575,"type":"action","sy":0.7,"sx":0.7,"px":248},{"dir":"skill_04","r":-8,"z":3,"py":133,"type":"action","sy":1,"sx":1,"px":852},{"dir":"skill_04","r":10,"z":3,"py":97,"type":"action","sy":1,"sx":1,"px":103},{"r":0,"sx":1,"sy":1,"py":72,"file":"scene1_2a.png","type":"object","z":2,"px":93},{"r":0,"sx":1,"sy":1,"py":103,"file":"scene1_2b.png","type":"object","z":2,"px":861},{"r":0,"sx":1,"sy":1,"py":536,"file":"scene1_2c.png","type":"object","z":0,"px":779},{"r":0,"sx":1,"sy":1,"py":552,"file":"scene1_2d.png","type":"object","z":0,"px":259}],"background":"background1.png","name":"亡灵场景2"},{"childs":[{"dir":"skill_06","r":0,"z":1,"py":563,"type":"action","sy":0.7,"sx":0.7,"px":775},{"dir":"skill_06","r":0,"z":1,"py":576,"type":"action","sy":0.7,"sx":0.7,"px":263},{"dir":"skill_06","r":0,"z":3,"py":129,"type":"action","sy":1,"sx":1,"px":854},{"dir":"skill_06","r":0,"z":3,"py":129,"type":"action","sy":1,"sx":1,"px":122},{"dir":"skill_02","r":0,"z":0,"py":424,"type":"action","sy":1,"sx":1,"px":598},{"dir":"skill_02","r":0,"z":0,"py":213,"type":"action","sy":1,"sx":1,"px":124},{"dir":"skill_05","r":-145,"z":1,"py":648,"type":"action","sy":1,"sx":1,"px":460},{"dir":"skill_05","z":1,"type":"action","py":644,"sy":1,"r":0,"sx":1,"px":571},{"file":"scene1_3a.png","z":2,"r":0,"py":93,"type":"object","sy":1,"sx":1,"px":119},{"file":"scene1_3b.png","z":2,"r":0,"py":93,"type":"object","sy":1,"sx":1,"px":850},{"file":"scene1_3c.png","z":0,"r":0,"py":537,"type":"object","sy":1,"sx":1,"px":773},{"file":"scene1_3d.png","z":0,"r":0,"py":550,"type":"object","sy":1,"sx":1,"px":262},{"file":"scene1_3e.png","z":0,"r":0,"py":391,"type":"object","sy":1,"sx":1,"px":546}],"background":"background1.png","name":"亡灵场景3"}]}')

actionDatas = data.actions
sceneDatas = data.scenes
