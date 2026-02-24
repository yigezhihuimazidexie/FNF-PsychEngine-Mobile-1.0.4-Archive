-- 全屏背景切换特效（缩放：2, 1，自定义位置）
local bgPink = nil
local bgGreen = nil
local bgWhite = nil
local blackOverlay = nil
local originalBgAlpha = 1

function onCreate()
    if getProperty('bg') then
        originalBgAlpha = getProperty('bg.alpha')
    end
    
    local bgX = -700
    local bgY = 250
    
    makeLuaSprite('bgPink', '', bgX, bgY)
    makeGraphic('bgPink', screenWidth, screenHeight, 'FF69B4')
    scaleObject('bgPink', 2, 3)
    setProperty('bgPink.alpha', 0)
    setObjectOrder('bgPink', getObjectOrder('dadGroup') - 3)
    addLuaSprite('bgPink', false)
    
    makeLuaSprite('bgGreen', '', bgX, bgY)
    makeGraphic('bgGreen', screenWidth, screenHeight, '32CD32')
    scaleObject('bgGreen', 2, 3)
    setProperty('bgGreen.alpha', 0)
    setObjectOrder('bgGreen', getObjectOrder('dadGroup') - 3)
    addLuaSprite('bgGreen', false)
    
    makeLuaSprite('bgWhite', '', bgX, bgY)
    makeGraphic('bgWhite', screenWidth, screenHeight, 'FFFFFF')
    scaleObject('bgWhite', 2, 3)
    setProperty('bgWhite.alpha', 0)
    setObjectOrder('bgWhite', getObjectOrder('dadGroup') - 3)
    addLuaSprite('bgWhite', false)
    
    makeLuaSprite('blackOverlay', '', 0, 0)
    makeGraphic('blackOverlay', screenWidth, screenHeight, '000000')
    screenCenter('blackOverlay')
    setProperty('blackOverlay.alpha', 0)
    setObjectOrder('blackOverlay', getProperty('gf.visible') and getObjectOrder('gfGroup') + 2 or getObjectOrder('boyfriendGroup') + 2)
    addLuaSprite('blackOverlay', true)
end

function onStepHit()
    if curStep == 327 then
        switchToPink()
    elseif curStep == 347 then
        switchToGreen()
    elseif curStep == 355 then
        switchToWhiteAndBlack()
    elseif curStep == 360 then
        restoreOriginal()
    end
end

function switchToPink()
    if getProperty('bg') then
        doTweenAlpha('bgFadeOut', 'bg', 0.2, 0.3, 'quadOut')
    end
    
    hideAllBgsExcept('bgPink')
    
    doTweenAlpha('pinkFadeIn', 'bgPink', 1, 0.3, 'quadOut')
    
    updateLayerOrder()
end

function switchToGreen()
    doTweenAlpha('pinkFadeOut', 'bgPink', 0, 0.25, 'quadOut')
    doTweenAlpha('greenFadeIn', 'bgGreen', 1, 0.25, 'quadIn')
    
    updateLayerOrder()
end

function switchToWhiteAndBlack()
    doTweenAlpha('greenFadeOut', 'bgGreen', 0, 0.2, 'quadOut')
    doTweenAlpha('whiteFadeIn', 'bgWhite', 1, 0.2, 'quadIn')
    
    doTweenAlpha('blackOverlayFadeIn', 'blackOverlay', 0.6, 0.3, 'quadIn')
    
    darkenCharacters()
    
    updateLayerOrder()
end

function restoreOriginal()
    doTweenAlpha('whiteFadeOut', 'bgWhite', 0, 0.3, 'quadOut')
    doTweenAlpha('blackOverlayFadeOut', 'blackOverlay', 0, 0.3, 'quadOut')
    
    if getProperty('bg') then
        doTweenAlpha('bgFadeIn', 'bg', originalBgAlpha, 0.3, 'quadOut')
    end
    
    restoreCharacters()
    
    runTimer('resetAllBgs', 0.5)
end

function onTimerCompleted(tag)
    if tag == 'resetAllBgs' then
        setProperty('bgPink.alpha', 0)
        setProperty('bgGreen.alpha', 0)
        setProperty('bgWhite.alpha', 0)
    end
end

function hideAllBgsExcept(exceptBg)
    local bgs = {'bgPink', 'bgGreen', 'bgWhite'}
    for _, bg in ipairs(bgs) do
        if bg ~= exceptBg then
            setProperty(bg..'.alpha', 0)
        end
    end
end

function darkenCharacters()
    runHaxeCode([[
        var darkShader = new FlxRuntimeShader('
            #pragma header
            void main() {
                vec4 color = texture2D(bitmap, openfl_TextureCoordv);
                float gray = (color.r + color.g + color.b) / 3.0;
                gl_FragColor = vec4(vec3(gray * 0.3), color.a);
            }
        ');
        
        if (game.dad != null && game.dadGroup != null) {
            game.dadGroup.shader = darkShader;
        }
        if (game.boyfriend != null && game.boyfriendGroup != null) {
            game.boyfriendGroup.shader = darkShader;
        }
        if (game.gf != null && game.gfGroup != null && game.gf.visible) {
            game.gfGroup.shader = darkShader;
        }
        
        if (game.dad != null) {
            game.dad.shader = darkShader;
        }
        if (game.boyfriend != null) {
            game.boyfriend.shader = darkShader;
        }
        if (game.gf != null && game.gf.visible) {
            game.gf.shader = darkShader;
        }
    ]])
end

function restoreCharacters()
    runHaxeCode([[
        if (game.dadGroup != null) {
            game.dadGroup.shader = null;
        }
        if (game.boyfriendGroup != null) {
            game.boyfriendGroup.shader = null;
        }
        if (game.gfGroup != null) {
            game.gfGroup.shader = null;
        }
        
        if (game.dad != null) {
            game.dad.shader = null;
        }
        if (game.boyfriend != null) {
            game.boyfriend.shader = null;
        }
        if (game.gf != null) {
            game.gf.shader = null;
        }
    ]])
end

function updateLayerOrder()
    local dadOrder = getObjectOrder('dadGroup')
    local bfOrder = getObjectOrder('boyfriendGroup')
    local gfOrder = getProperty('gf.visible') and getObjectOrder('gfGroup') or 999
    
    local minOrder = math.min(dadOrder, bfOrder, gfOrder)
    
    setObjectOrder('bgPink', minOrder - 3)
    setObjectOrder('bgGreen', minOrder - 3)
    setObjectOrder('bgWhite', minOrder - 3)
    
    setObjectOrder('blackOverlay', minOrder + 2)
end

function onUpdate()
    updateLayerOrder()
    
    if getProperty('bgPink') then
        setProperty('bgPink.x', -700)
        setProperty('bgPink.y', 250)
        if getProperty('bgPink.scale.x') ~= 2 or getProperty('bgPink.scale.y') ~= 1 then
            scaleObject('bgPink', 2, 3)
        end
    end
    if getProperty('bgGreen') then
        setProperty('bgGreen.x', -700)
        setProperty('bgGreen.y', 250)
        if getProperty('bgGreen.scale.x') ~= 2 or getProperty('bgGreen.scale.y') ~= 1 then
            scaleObject('bgGreen', 2, 3)
        end
    end
    if getProperty('bgWhite') then
        setProperty('bgWhite.x', -700)
        setProperty('bgWhite.y', 250)
        if getProperty('bgWhite.scale.x') ~= 2 or getProperty('bgWhite.scale.y') ~= 1 then
            scaleObject('bgWhite', 2, 3)
        end
    end
    
    if getProperty('blackOverlay') then
        screenCenter('blackOverlay')
    end
end

function onDestroy()
    if getProperty('bgPink') then removeLuaSprite('bgPink', true) end
    if getProperty('bgGreen') then removeLuaSprite('bgGreen', true) end
    if getProperty('bgWhite') then removeLuaSprite('bgWhite', true) end
    if getProperty('blackOverlay') then removeLuaSprite('blackOverlay', true) end
    
    restoreCharacters()
end