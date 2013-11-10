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
    if type(size) == "table" then
        size = CCSizeMake(size[1], size[2])
    end

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
            print("editBox", event)
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
    editbox:setTouchPriority(kCCMenuHandlerPriority)

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


function ui.newBMFontLabel(params)
    assert(type(params) == "table",
           "[framework.client.ui] newBMFontLabel() invalid params")

    local text      = tostring(params.text)
    local font      = params.font
    local textAlign = params.align or ui.TEXT_ALIGN_CENTER
    local color      = params.color or display.COLOR_WHITE
    if type(color) == "table" then
        color = toCol(color)
    end
    if font == nil then
        font = "bound.fnt"
    end
    local x, y      = params.x, params.y
    local size      = params.size or 20
    assert(font ~= nil, "ui.newBMFontLabel() - not set font")
    local baseSize = 35
    local k = size/baseSize
    local label = CCLabelBMFont:create(text, font, kCCLabelAutomaticWidth, textAlign)
    label:setScale(k)
    if not label then return end
    label:setColor(color)
    if type(x) == "number" and type(y) == "number" then
        label:setPosition(x, y)
    end

    return label
end

function ui.newTTFLabel(params)
    local text       = tostring(params.text)
    local font       = params.font or ui.DEFAULT_TTF_FONT
    local size       = params.size or ui.DEFAULT_TTF_FONT_SIZE
    local color      = params.color or display.COLOR_WHITE
    if type(color) == "table" then
        color = toCol(color)
    end
    local textAlign  = params.align or ui.TEXT_ALIGN_LEFT
    local textValign = params.valign or ui.TEXT_VALIGN_CENTER
    local x, y       = params.x, params.y
    local dimensions = params.dimensions
    if type(dimensions) == 'table' then
        dimensions = CCSizeMake(dimensions[1], dimensions[2])
    end

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
--text
--delegate
--callback
--size
--image
--conSize button size

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
    local text = params.text
    local size = params.size
    local conSize = params.conSize

    local spSize = {sz.width, sz.height}

    function obj:touchBegan(x, y)
        local p = sp:convertToNodeSpace(ccp(x, y))
        local ret = checkIn(p.x, p.y, sz)
        local vs = obj.bg:isVisible()
        if ret and params.callback ~= nil and vs then
            local tempSp = CCSprite:create(params.image)
            lay:addChild(tempSp)
            local function removeTemp()
                removeSelf(tempSp)
            end
            local anchor = sp:getAnchorPoint()
            tempSp:setAnchorPoint(anchor)
            setSize(tempSp, spSize)
            tempSp:runAction(sequence({spawn({scaleby(0.5, 1.2, 1.2), fadeout(0.5)}), callfunc(nil, removeTemp)}))
        end
        return ret
    end
    function obj:touchMoved(x, y)
    end
    function obj:touchEnded(x, y)
        local vs = obj.bg:isVisible()
        if params.callback ~= nil and vs then
            params.callback(params.delegate, params.param)
        end
    end
    function obj:setCallback(cb)
        params.callback = cb
    end
    function obj:setAnchor(x, y)
        lay:setAnchorPoint(ccp(x, y))
        sp:setAnchorPoint(ccp(x, y))
        return obj
    end
    function obj:setContentSize(w, h)
        spSize = {w, h}
        lay:setContentSize(CCSizeMake(w, h))
        setSize(sp, {w, h})
    end
    obj.sp = sp
    registerTouch(obj)
    if conSize ~= nil then
        obj:setContentSize(conSize[1], conSize[2])
    end
    if text ~= nil then
        obj.text = setAnchor(addLabel(obj.bg, text, "", size), {0.5, 0.5})
    end
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
