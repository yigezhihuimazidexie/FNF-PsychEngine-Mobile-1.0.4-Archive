package objects;

import flixel.sound.FlxSound;
import flixel.math.FlxMath;

class AudioDisplay extends FlxSpriteGroup
{
    public var snd:FlxSound;
    var _height:Int;
    var line:Int;

    public function new(snd:FlxSound = null, X:Float = 0, Y:Float = 0, Width:Int, Height:Int, line:Int, gap:Int, Color:FlxColor)
    {
        super(X, Y);

        this.snd = snd;
        this.line = line;

        for (i in 0...line)
        {
            var newLine = new FlxSprite().makeGraphic(Std.int(Width / line - gap), 1, Color);
            newLine.x = (Width / line) * i;
            newLine.y -= 400;
            add(newLine);
        }
        _height = Height;
    }

    public var stopUpdate:Bool = false;
    override function update(elapsed:Float)
        {
            if (stopUpdate) return;
        
            var amp:Float = 0;
            if (snd != null && snd.playing)
            {
                var rawAmp = (snd.amplitudeLeft + snd.amplitudeRight) / 2;
                // 补偿全局音量，使可视化高度与音量键无关
                if (FlxG.sound.volume > 0.001)
                    amp = rawAmp / FlxG.sound.volume;
                else
                    amp = rawAmp;
                // 限制合理范围，避免过大的跳动
                amp = Math.min(1, Math.max(0, amp));
            }
        
            for (i in 0...members.length)
            {
                var targetHeight = 5 + amp * 200 + Math.sin(FlxG.game.ticks * 0.01 + i * 0.5) * 30;
                if (targetHeight < 5) targetHeight = 5;
        
                members[i].scale.y = FlxMath.lerp(targetHeight, members[i].scale.y, Math.exp(-elapsed * 16));
                members[i].updateHitbox();
                members[i].y = this.y - members[i].scale.y +=100; 
            }
            super.update(elapsed);
        }

    public function changeAnalyzer(snd:FlxSound) 
    {
        this.snd = snd;
        stopUpdate = false;
    }

    public function clearUpdate() {
        stopUpdate = true;
        for (i in 0...members.length) {
            members[i].scale.y = 0;
        }
    }
}