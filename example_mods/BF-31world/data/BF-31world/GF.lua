function onCreate()
    setProperty('gf.visible', false)      
    setProperty('gf.active', false)       
    setProperty('gf.alpha', 0)           
end
function onUpdate()
    setProperty('gf.visible', false)
    setProperty('gf.active', false)
    setProperty('gf.alpha', 0)
end

function onStepHit()
    setProperty('gf.visible', false)
end

function onBeatHit()
    setProperty('gf.visible', false)
end

local originalSetProperty = setProperty
function setProperty(variable, value)
    if string.find(variable, 'gf.visible') and value == true then
        return 
    end
    if string.find(variable, 'gf.alpha') and value > 0 then
        value = 0 
    end
    originalSetProperty(variable, value)
end

function onDestroy()
    setProperty('gf.visible', true) 
    setProperty('gf.active', true)
    setProperty('gf.alpha', 1)
end