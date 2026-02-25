----来自吴宇的留言（看什么看，这个就是隐藏ui元素，但不是隐藏hud的lua罢了【有点小bug，不耽误玩】）
function onCreatePost()
    for i = 0,3 do
        setPropertyFromGroup('playerStrums', i, 'visible', false)
        setPropertyFromGroup('playerStrums', i, 'alpha', 0)
    end
    for i = 0,3 do
        setPropertyFromGroup('opponentStrums', i, 'visible', false)
        setPropertyFromGroup('opponentStrums', i, 'alpha', 0)
    end
    setProperty('uiGroup.visible', false)
end

function onStepHit()
    if curStep == 144 then
        for i = 0,3 do
            setPropertyFromGroup('playerStrums', i, 'alpha', 0)
            setPropertyFromGroup('playerStrums', i, 'visible', true)
            setPropertyFromGroup('opponentStrums', i, 'alpha', 0)
            setPropertyFromGroup('opponentStrums', i, 'visible', true)
        end
        setProperty('uiGroup.visible', true)
        setProperty('botplayTxt.visible', false)
        setProperty('uiGroup.alpha', 0)
        doTweenAlpha('uiGroup', 'uiGroup', 1, 1, 'sineInOut')
    
        for i = 0, 3 do
            doTweenAlpha('playerFadeIn'..i, 'playerStrums.members['..i..']', 1, 1, 'sineInOut')
        end
        
        for i = 0, 3 do
            doTweenAlpha('opponentFadeIn'..i, 'opponentStrums.members['..i..']', 1, 1, 'sineInOut')
        end
    end

    if curStep == 272 then
        doTweenAlpha('uiGroupHide', 'uiGroup', 0, 1, 'sineInOut')
        for i = 0,3 do
            doTweenAlpha('playerHide'..i, 'playerStrums.members['..i..']', 0, 1, 'sineInOut')
        end
        for i = 0,3 do
            doTweenAlpha('opponentHide'..i, 'opponentStrums.members['..i..']', 0, 1, 'sineInOut')
        end
    end

    if curStep == 388 then
        setProperty('uiGroup.visible', true)
        for i = 0,3 do
            setPropertyFromGroup('playerStrums', i, 'visible', true)
            setPropertyFromGroup('opponentStrums', i, 'visible', true)
        end
        setProperty('uiGroup.alpha', 0)
        for i = 0,3 do
            setPropertyFromGroup('playerStrums', i, 'alpha', 0)
            setPropertyFromGroup('opponentStrums', i, 'alpha', 0)
        end
        doTweenAlpha('uiGroupShow', 'uiGroup', 1, 1, 'sineInOut')
        for i = 0,3 do
            doTweenAlpha('playerShow'..i, 'playerStrums.members['..i..']', 1, 1, 'sineInOut')
        end
        for i = 0,3 do
            doTweenAlpha('opponentShow'..i, 'opponentStrums.members['..i..']', 1, 1, 'sineInOut')
        end
    end
end