-- yuyi动画脚本 - 适用于Psych Engine 1.0.4
-- 可自定义每个yuyi的坐标

local yuyi1 = nil
local yuyi2 = nil
local yuyi3 = nil
local yuyi4 = nil
local yuyi5 = nil
local isYuyi1Active = false
local isYuyi2Active = false
local isYuyi3Active = false
local isYuyi4Active = false
local isYuyi5Active = false

-- ==============================================
-- 自定义每个yuyi的坐标设置
-- 修改这里的值来调整每个yuyi的位置
-- ==============================================

-- yuyi1 坐标设置
local yuyi1TargetX = -500    -- yuyi1的目标X坐标
local yuyi1TargetY = 250    -- yuyi1的目标Y坐标
local yuyi1StartX = -800    -- yuyi1的起始X坐标（左侧外）
local yuyi1EndX = -1800      -- yuyi1的结束X坐标（返回到左侧外）

-- yuyi2 坐标设置
local yuyi2TargetX = -500    -- yuyi2的目标X坐标
local yuyi2TargetY = 200    -- yuyi2的目标Y坐标
local yuyi2StartX = -800    -- yuyi2的起始X坐标（左侧外）
local yuyi2EndX = -1800      -- yuyi2的结束X坐标（返回到左侧外）

-- yuyi3 坐标设置
local yuyi3TargetX = -650    -- yuyi3的目标X坐标
local yuyi3TargetY = 250    -- yuyi3的目标Y坐标
local yuyi3StartX = -800    -- yuyi3的起始X坐标（左侧外）
local yuyi3EndX = -1800      -- yuyi3的结束X坐标（返回到左侧外）

-- yuyi4 坐标设置
local yuyi4TargetX = -500    -- yuyi4的目标X坐标
local yuyi4TargetY = 300    -- yuyi4的目标Y坐标
local yuyi4StartX = -800    -- yuyi4的起始X坐标（左侧外）
local yuyi4EndX = -1800      -- yuyi4的结束X坐标（返回到左侧外）

-- yuyi5 坐标设置（垂直移动）
local yuyi5TargetX = -300    -- yuyi5的目标X坐标（nil表示使用默认居中）
local yuyi5TargetY = 200    -- yuyi5的目标Y坐标（nil表示使用默认居中）
local yuyi5StartY = nil     -- yuyi5的起始Y坐标（nil表示使用屏幕下方）
local yuyi5EndY = -1500       -- yuyi5的结束Y坐标（nil表示使用屏幕下方）


function onCreate()
    for i = 1, 5 do
        precacheImage('yuyi' .. i)
    end

    makeAnimatedLuaSprite('yuyi1', 'yuyi1', yuyi1StartX, yuyi1TargetY)
    addAnimationByPrefix('yuyi1', 'idle', 'idle', 24, false)
    setProperty('yuyi1.visible', false)
    setProperty('yuyi1.antialiasing', true)
    scaleObject('yuyi1', 0.7, 0.7)
    addLuaSprite('yuyi1', true)
    setObjectOrder('yuyi1', 9999)
    
    makeAnimatedLuaSprite('yuyi2', 'yuyi2', yuyi2StartX, yuyi2TargetY)
    addAnimationByPrefix('yuyi2', 'idle', 'idle', 24, false)
    setProperty('yuyi2.visible', false)
    setProperty('yuyi2.antialiasing', true)
    scaleObject('yuyi2', 0.7, 0.7)
    addLuaSprite('yuyi2', true)
    setObjectOrder('yuyi2', 9999)
    
    makeAnimatedLuaSprite('yuyi3', 'yuyi3', yuyi3StartX, yuyi3TargetY)
    addAnimationByPrefix('yuyi3', 'idle', 'idle', 24, false)
    setProperty('yuyi3.visible', false)
    setProperty('yuyi3.antialiasing', true)
    scaleObject('yuyi3', 0.7, 0.7)
    addLuaSprite('yuyi3', true)
    setObjectOrder('yuyi3', 9999)

    makeAnimatedLuaSprite('yuyi4', 'yuyi4', yuyi4StartX, yuyi4TargetY)
    addAnimationByPrefix('yuyi4', 'idle', 'idle', 24, false)
    setProperty('yuyi4.visible', false)
    setProperty('yuyi4.antialiasing', true)
    scaleObject('yuyi4', 0.7, 0.7)
    addLuaSprite('yuyi4', true)
    setObjectOrder('yuyi4', 9999)
    
    makeAnimatedLuaSprite('yuyi5', 'yuyi5', 0, 0)
    addAnimationByPrefix('yuyi5', 'idle', 'idle', 24, false)
    setProperty('yuyi5.visible', false)
    setProperty('yuyi5.antialiasing', true)
    scaleObject('yuyi5', 0.7, 0.7)
    addLuaSprite('yuyi5', true)
    setObjectOrder('yuyi5', 9999)
end

function onStepHit()
    if curStep == 122 then
        spawnYuyi1()
    
    elseif curStep == 137 then
        removeYuyi1Left()
    
    elseif curStep == 186 then
        spawnYuyi2()
    
    elseif curStep == 202 then
        removeYuyi2Left()
    
    elseif curStep == 255 then
        spawnYuyi3()
    
    elseif curStep == 267 then
        removeYuyi3Left()

    elseif curStep == 345 then
        spawnYuyi4()
    
    elseif curStep == 360 then
        removeYuyi4Left()
    
    elseif curStep == 1094 then
        spawnYuyi5()
        
    elseif curStep == 1110 then
        removeYuyi5Down()
    end
end

function spawnYuyi1()
    if isYuyi1Active then return end
    setProperty('yuyi1.x', yuyi1StartX)
    setProperty('yuyi1.y', yuyi1TargetY)
    setProperty('yuyi1.visible', true)
    
    objectPlayAnimation('yuyi1', 'idle', true)
    doTweenX('yuyi1MoveIn', 'yuyi1', yuyi1TargetX, 1, 'sineOut')
    
    isYuyi1Active = true
end

function removeYuyi1Left()
    if not isYuyi1Active then return end
    doTweenX('yuyi1MoveOutLeft', 'yuyi1', yuyi1EndX, 0.8, 'sineIn')
    
    runTimer('hideYuyi1', 0.9)
end

function spawnYuyi2()
    if isYuyi2Active then return end
    
    setProperty('yuyi2.x', yuyi2StartX)
    setProperty('yuyi2.y', yuyi2TargetY)
    setProperty('yuyi2.visible', true)   
    objectPlayAnimation('yuyi2', 'idle', true)
    doTweenX('yuyi2MoveIn', 'yuyi2', yuyi2TargetX, 1, 'sineOut') 
    isYuyi2Active = true
end

function removeYuyi2Left()
    if not isYuyi2Active then return end
    doTweenX('yuyi2MoveOutLeft', 'yuyi2', yuyi2EndX, 0.8, 'sineIn')
    
    runTimer('hideYuyi2', 0.9)
end

function spawnYuyi3()
    if isYuyi3Active then return end
    
    setProperty('yuyi3.x', yuyi3StartX)
    setProperty('yuyi3.y', yuyi3TargetY)
    setProperty('yuyi3.visible', true)
    objectPlayAnimation('yuyi3', 'idle', true)
    doTweenX('yuyi3MoveIn', 'yuyi3', yuyi3TargetX, 1, 'sineOut')
    
    isYuyi3Active = true
end

function removeYuyi3Left()
    if not isYuyi3Active then return end
    doTweenX('yuyi3MoveOutLeft', 'yuyi3', yuyi3EndX, 0.8, 'sineIn')
    runTimer('hideYuyi3', 0.9)
end

function spawnYuyi4()
    if isYuyi4Active then return end
    setProperty('yuyi4.x', yuyi4StartX)
    setProperty('yuyi4.y', yuyi4TargetY)
    setProperty('yuyi4.visible', true)
    objectPlayAnimation('yuyi4', 'idle', true)
    doTweenX('yuyi4MoveIn', 'yuyi4', yuyi4TargetX, 1, 'sineOut')
    isYuyi4Active = true
end

function removeYuyi4Left()
    if not isYuyi4Active then return end
    doTweenX('yuyi4MoveOutLeft', 'yuyi4', yuyi4EndX, 0.8, 'sineIn')
    runTimer('hideYuyi4', 0.9)
end
function spawnYuyi5()
    if isYuyi5Active then return end
    
    local screenWidth = getProperty('camGame.width')
    local screenHeight = getProperty('camGame.height')
    local spriteWidth = getProperty('yuyi5.width') * getProperty('yuyi5.scale.x')
    local spriteHeight = getProperty('yuyi5.height') * getProperty('yuyi5.scale.y')
    local targetX = yuyi5TargetX or ((screenWidth - spriteWidth) / 2)
    local targetY = yuyi5TargetY or ((screenHeight - spriteHeight) / 2)
    local startY = yuyi5StartY or (screenHeight + 100)
    setProperty('yuyi5.x', targetX)  -- X坐标不变，保持水平居中
    setProperty('yuyi5.y', startY)   -- 从屏幕下方开始
    setProperty('yuyi5.visible', true)   
    objectPlayAnimation('yuyi5', 'idle', true)
    doTweenY('yuyi5MoveUp', 'yuyi5', targetY, 1.2, 'sineOut')
    isYuyi5Active = true
end

function removeYuyi5Down()
    if not isYuyi5Active then return end
    local screenHeight = getProperty('camGame.height')
    local currentY = getProperty('yuyi5.y')
    doTweenY('yuyi5MoveDown', 'yuyi5', screenHeight + 100, 1, 'sineIn')
    runTimer('hideYuyi5', 1.1)
end

function onTimerCompleted(tag)
    if tag == 'hideYuyi1' then
        setProperty('yuyi1.visible', false)
        isYuyi1Active = false
        
    elseif tag == 'hideYuyi2' then
        setProperty('yuyi2.visible', false)
        isYuyi2Active = false
        
    elseif tag == 'hideYuyi3' then
        setProperty('yuyi3.visible', false)
        isYuyi3Active = false
        
    elseif tag == 'hideYuyi4' then
        setProperty('yuyi4.visible', false)
        isYuyi4Active = false
        
    elseif tag == 'hideYuyi5' then
        setProperty('yuyi5.visible', false)
        isYuyi5Active = false
    end
end

function onTweenCompleted(tag)
    -- 可以在这里添加动画完成后的处理
    -- 例如：if tag == 'yuyi1MoveIn' then ... end
end

function onUpdate()
    if getProperty('yuyi1.visible') then setObjectOrder('yuyi1', 9999) end
    if getProperty('yuyi2.visible') then setObjectOrder('yuyi2', 9999) end
    if getProperty('yuyi3.visible') then setObjectOrder('yuyi3', 9999) end
    if getProperty('yuyi4.visible') then setObjectOrder('yuyi4', 9999) end
    if getProperty('yuyi5.visible') then setObjectOrder('yuyi5', 9999) end
end

function onDestroy()
    if getProperty('yuyi1') then removeLuaSprite('yuyi1', true) end
    if getProperty('yuyi2') then removeLuaSprite('yuyi2', true) end
    if getProperty('yuyi3') then removeLuaSprite('yuyi3', true) end
    if getProperty('yuyi4') then removeLuaSprite('yuyi4', true) end
    if getProperty('yuyi5') then removeLuaSprite('yuyi5', true) end
end