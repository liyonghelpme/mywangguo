display = {}

display.COLOR_WHITE = ccc3(255, 255, 255)
display.COLOR_BLACK = ccc3(0, 0, 0)

display.designSize = {1024, 768}
function display.getScaleX()
    local vs = CCDirector:sharedDirector():getVisibleSize()
    return vs.width/display.designSize[1]
end

function display.getScaleY()
    local vs = CCDirector:sharedDirector():getVisibleSize()
    return vs.height/display.designSize[2]
end
function display.pushView(view)
    local rc = CCDirector:sharedDirector():getRunningScene()
    rc:addChild(view)
end


function display.newScale9Sprite(filename, x, y)
    local sprite
    sprite = CCScale9Sprite:create(filename)

    if sprite then
        if x and y then sprite:setPosition(x, y) end
    end

    return sprite
end
