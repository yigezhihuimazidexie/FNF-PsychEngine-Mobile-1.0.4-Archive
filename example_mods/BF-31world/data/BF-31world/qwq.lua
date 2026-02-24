function onCreate()
    hideHudElements()
end

function hideHudElements()
    setProperty('healthBar.visible', false)
    setProperty('healthBarBG.visible', false)
    setProperty('healthBar.alpha', 0)
    setProperty('healthBarBG.alpha', 0)
    setProperty('iconP1.visible', false)
    setProperty('iconP2.visible', false)
    setProperty('iconP1.alpha', 0)
    setProperty('iconP2.alpha', 0)
    setProperty('scoreTxt.visible', false)
    setProperty('scoreTxt.alpha', 0)
    setProperty('timeBar.visible', false)
    setProperty('timeBarBG.visible', false)
    setProperty('timeTxt.visible', false)  
    setProperty('logoBl.visible', false)
    setProperty('logoBf.visible', false)
end

function onUpdate()
    setProperty('healthBar.visible', false)
    setProperty('healthBarBG.visible', false)
    setProperty('iconP1.visible', false)
    setProperty('iconP2.visible', false)
    setProperty('scoreTxt.visible', false)
end
function onStepHit()
    setProperty('healthBar.visible', false)
    setProperty('iconP1.visible', false)
    setProperty('iconP2.visible', false)
end

function fadeOutHud(duration)
    local fadeTime = duration or 1.0
    
    doTweenAlpha('healthFade', 'healthBar', 0, fadeTime, 'linear')
    doTweenAlpha('healthBGFade', 'healthBarBG', 0, fadeTime, 'linear')
    doTweenAlpha('iconP1Fade', 'iconP1', 0, fadeTime, 'linear')
    doTweenAlpha('iconP2Fade', 'iconP2', 0, fadeTime, 'linear')
    doTweenAlpha('scoreFade', 'scoreTxt', 0, fadeTime, 'linear')
    
    runTimer('disableHudAfterFade', fadeTime)
end

function onTimerCompleted(tag)
    if tag == 'disableHudAfterFade' then
        setProperty('healthBar.visible', false)
        setProperty('healthBarBG.visible', false)
        setProperty('iconP1.visible', false)
        setProperty('iconP2.visible', false)
        setProperty('scoreTxt.visible', false)
    end
end

function onEvent(name, value1, value2)
    if name == 'Hide HUD' then
        local action = value1 or 'hide'
        local duration = tonumber(value2) or 0
        
        if action == 'hide' then
            if duration > 0 then
                fadeOutHud(duration)
            else
                hideHudElements()
            end
        elseif action == 'show' then
            if duration > 0 then
                fadeInHud(duration)
            else
                showHudElements()
            end
        end
    end
end
function fadeInHud(duration)
    local fadeTime = duration or 1.0
    
    setProperty('healthBar.visible', true)
    setProperty('healthBarBG.visible', true)
    setProperty('iconP1.visible', true)
    setProperty('iconP2.visible', true)
    setProperty('scoreTxt.visible', true)

    doTweenAlpha('healthFadeIn', 'healthBar', 1, fadeTime, 'linear')
    doTweenAlpha('healthBGFadeIn', 'healthBarBG', 1, fadeTime, 'linear')
    doTweenAlpha('iconP1FadeIn', 'iconP1', 1, fadeTime, 'linear')
    doTweenAlpha('iconP2FadeIn', 'iconP2', 1, fadeTime, 'linear')
    doTweenAlpha('scoreFadeIn', 'scoreTxt', 1, fadeTime, 'linear')
end

function showHudElements()
    setProperty('healthBar.visible', true)
    setProperty('healthBarBG.visible', true)
    setProperty('iconP1.visible', true)
    setProperty('iconP2.visible', true)
    setProperty('scoreTxt.visible', true)
    
    setProperty('healthBar.alpha', 1)
    setProperty('healthBarBG.alpha', 1)
    setProperty('iconP1.alpha', 1)
    setProperty('iconP2.alpha', 1)
    setProperty('scoreTxt.alpha', 1)
end

function onDestroy()
    showHudElements()
end
