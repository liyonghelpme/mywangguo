Music = {}
Music.curMusic = nil
function Music.playBackground(name)
    Music.curMusic = name
    local engine = SimpleAudioEngine:sharedEngine()
    if Music.curMusic ~= nil then
        engine:playBackgroundMusic(name, true)
    else
        engine:stopBackgroundMusic(true)
    end
end
function Music.playEffect(name)
    local engine = SimpleAudioEngine:sharedEngine()
    engine:playEffect(name, false)
end
function Music.preload(name)
    local engine = SimpleAudioEngine:sharedEngine()
    engine:preloadEffect(name)
end
