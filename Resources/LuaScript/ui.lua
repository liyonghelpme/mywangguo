ui = {}
function ui.newEditBox(params)
    local imageNormal = params.image
    local imagePressed = params.imagePressed
    local imageDisabled = params.imageDisabled
    local listener = params.listener
    local listenerType = type(listener)
    local tag = params.tag
    local x = params.x
    local y = params.y
    local size = params.size

    if type(imageNormal) == "string" then
        imageNormal = display.newScale9Sprite(imageNormal)
    end
    if type(imagePressed) == "string" then
        imagePressed = display.newScale9Sprite(imagePressed)
    end
    if type(imageDisabled) == "string" then
        imageDisabled = display.newScale9Sprite(imageDisabled)
    end

    local editbox = CCEditBox:create(size, imageNormal, imagePressed, imageDisabled)

    if editbox then
        editbox:registerScriptEditBoxHandler(function(event, object)
            if listenerType == "table" or listenerType == "userdata" then
                if event == "began" then
                    listener:onEditBoxBegan(object)
                elseif event == "ended" then
                    listener:onEditBoxEnded(object)
                elseif event == "return" then
                    listener:onEditBoxReturn(object)
                elseif event == "changed" then
                    listener:onEditBoxChanged(object)
                end
            elseif listenerType == "function" then
                listener(event, object)
            end
        end)
        if x and y then editbox:setPosition(x, y) end
    end

    return editbox
end
ui.DEFAULT_TTF_FONT      = "Arial"
ui.DEFAULT_TTF_FONT_SIZE = 24

ui.TEXT_ALIGN_LEFT    = kCCTextAlignmentLeft
ui.TEXT_ALIGN_CENTER  = kCCTextAlignmentCenter
ui.TEXT_ALIGN_RIGHT   = kCCTextAlignmentRight
ui.TEXT_VALIGN_TOP    = kCCVerticalTextAlignmentTop
ui.TEXT_VALIGN_CENTER = kCCVerticalTextAlignmentCenter
ui.TEXT_VALIGN_BOTTOM = kCCVerticalTextAlignmentBottom

function ui.newTTFLabel(params)
    local text       = tostring(params.text)
    local font       = params.font or ui.DEFAULT_TTF_FONT
    local size       = params.size or ui.DEFAULT_TTF_FONT_SIZE
    local color      = params.color or display.COLOR_WHITE
    local textAlign  = params.align or ui.TEXT_ALIGN_LEFT
    local textValign = params.valign or ui.TEXT_VALIGN_CENTER
    local x, y       = params.x, params.y
    local dimensions = params.dimensions

    local label
    if dimensions then
        label = CCLabelTTF:create(text, font, size, dimensions, textAlign, textValign)
    else
        label = CCLabelTTF:create(text, font, size)
    end

    if label then
        label:setColor(color)

        function label:realign(x, y)
            if textAlign == ui.TEXT_ALIGN_LEFT then
                label:setPosition(math.round(x + label:getContentSize().width / 2), y)
            elseif textAlign == ui.TEXT_ALIGN_RIGHT then
                label:setPosition(x - math.round(label:getContentSize().width / 2), y)
            else
                label:setPosition(x, y)
            end
        end

        if x and y then label:realign(x, y) end
    end

    return label
end

function ui.newButton(params)
    local obj = {}
    local lay = CCLayer:create()
    local sp = CCSprite:create(params.image)
    lay:addChild(sp)
    obj.bg = lay
    local sz = sp:getContentSize()
    lay:setContentSize(sz)
    lay:setAnchorPoint(ccp(0, 0))
    sp:setAnchorPoint(ccp(0, 0))

    function obj:touchBegan(x, y)
        --params.touchBegan(params.delegate, x, y)
        local p = sp:convertToNodeSpace(ccp(x, y))
        return checkIn(p.x, p.y, sz)
    end
    function obj:touchMoved(x, y)
        --params.touchMoved(params.delegate, x, y)
    end
    function obj:touchEnded(x, y)
        params.callback(params.delegate, params.param)
    end
    function obj:setAnchor(x, y)
        lay:setAnchorPoint(ccp(x, y))
        sp:setAnchorPoint(ccp(x, y))
        return obj
    end
    function obj:setContentSize(w, h)
        lay:setContentSize(CCSizeMake(w, h))
        setSize(sp, {w, h})
    end
    registerTouch(obj)
    return obj
end

function ui.newTouchLayer(params)
    local obj = {}
    local lay = CCLayer:create()
    obj.bg = lay
    lay:setAnchorPoint(ccp(0, 0))
    lay:setContentSize(CCSizeMake(params.size[1], params.size[2]))
    local sz = lay:getContentSize()
    function obj:touchBegan(x, y)
        local xy = lay:convertToNodeSpace(ccp(x, y))
        if checkIn(xy.x, xy.y, sz) then
            params.touchBegan(params.delegate, x, y)
            return true
        end
        return false
    end
    function obj:touchMoved(x, y)
        params.touchMoved(params.delegate, x, y)
    end
    function obj:touchEnded(x, y)
        params.touchEnded(params.delegate, x, y)
    end
    registerTouch(obj)
    return obj
end
