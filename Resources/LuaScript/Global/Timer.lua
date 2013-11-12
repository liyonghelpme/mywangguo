Timer = {}
Timer.now = os.time()
--bug 游戏退出之后 就不会计时 了
--now 就存在问题
function Timer.update(diff)
    --Timer.now = Timer.now+diff
    Timer.now = os.time()
end

Timer.updateFunc = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(Timer.update, 1, false)


