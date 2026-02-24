-- 删除开局倒计时 + 禁用暂停 + 隐藏对手箭头
function onCreate()
    skipCountdown()
    disablePause()
    hideOpponentArrows()
end
function skipCountdown()
    runHaxeCode([[
        game.skipCountdown = true;
        game.startCountdown = function() {};
    ]])
    
    runTimer('startSongImmediately', 0.1)
end

function onTimerCompleted(tag)
    if tag == 'startSongImmediately' then
        runHaxeCode([[ game.startSong(); ]])
    end
end
function disablePause()
    runHaxeCode([[
        var originalPause = game.openPauseMenu;
        game.openPauseMenu = function() {
            return false;
        };
        FlxG.keys.enabled = false;
        if (FlxG.sound.music != null) {
            FlxG.sound.music.pause();
            FlxG.sound.music.play();
        }
    ]])
end
function hideOpponentArrows()
    for i = 0, 3 do
        setPropertyFromGroup('opponentStrums', i, 'visible', false)
        setPropertyFromGroup('opponentStrums', i, 'alpha', 0)
        setPropertyFromGroup('opponentStrums', i, 'active', false)
    end
    runHaxeCode([[
        for (note in game.unspawnNotes) {
            if (!note.mustPress) {
                note.visible = false;
                note.active = false;
                note.alpha = 0;
            }
        }
        for (note in game.notes) {
            if (!note.mustPress) {
                note.visible = false;
                note.active = false;
                note.alpha = 0;
            }
        }
    ]])
end
function onUpdate()
    for i = 0, 3 do
        setPropertyFromGroup('opponentStrums', i, 'visible', false)
        setPropertyFromGroup('opponentStrums', i, 'alpha', 0)
    end
    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.P') or
       getPropertyFromClass('flixel.FlxG', 'keys.justPressed.ESCAPE') then
        runHaxeCode([[ FlxG.sound.play(Paths.sound('cancelMenu')); ]])
    end
end
function onStepHit()
    for i = 0, 3 do
        setPropertyFromGroup('opponentStrums', i, 'visible', false)
    end
end