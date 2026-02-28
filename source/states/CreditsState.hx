package states;

import objects.AttachedSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class CreditsState extends MusicBeatState
{
	var curSelected:Int = -1;
	private var creditsStuff:Array<Array<String>> = [];

	var bg:FlxSprite;
	var intendedColor:FlxColor;

	var currentIcon:FlxSprite;
	var currentName:FlxText;
	var currentRole:FlxText;
	var roleBox:FlxSprite;

	var iconX:Float = 0;
	var iconY:Float = 200;
	var nameY:Float = 120;
	var roleY:Float = 370;
	var boxPadding:Int = 10;

	override function create()
	{
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("In the Menus", null);
		#end

		persistentUpdate = true;

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);
		bg.screenCenter();

		#if MODS_ALLOWED
		for (mod in Mods.parseList().enabled) pushModCreditsToList(mod);
		#end

		var defaultList:Array<Array<String>> = [
			["Cwy",		"Cwy",		"director",					"https://space.bilibili.com/3493119353948379?spm_id_from=333.337.0.0",	"444444"],
			["Baka", "Baka", "Main Programmer","https://www.bilibili.com/video/BV1rs41197Xn/?share_source=copy_web&vd_source=5b936a9bef8d1a986b34aeda2b7ef5fb","#ADD8E6"],
			["Icon-BF",		"icon-bf",		"programming",					"https://space.bilibili.com/488017110",	"444444"],
			["XJ-Akers",		"XJ-Akers",		"painting",					"https://space.bilibili.com/1684262832",	"444444"],
			["Star Fison",		"Star Fison",		"arrangement",					"https://space.bilibili.com/515522141",	"444444"],
			["woofwolf",		"woofwolf",		"painting",					"https://space.bilibili.com/514249942?spm_id_from=333.1387.follow.user_card.click",	"444444"],
			["Join us!", "QQ", "1038989304", "https://space.bilibili.com/3493119353948379?spm_id_from=333.337.0.0", "5165F6"]
		];
		for (i in defaultList) creditsStuff.push(i);

		iconX = (FlxG.width - 150) / 2;

		curSelected = 0;
		while (unselectableCheck(curSelected)) curSelected++;

		buildCard(creditsStuff[curSelected], false, 1);

		bg.color = CoolUtil.colorFromString(creditsStuff[curSelected][4]);
		intendedColor = bg.color;

		addTouchPad('UP_DOWN', 'A_B');

		super.create();
	}

	function buildCard(data:Array<String>, animated:Bool, direction:Int)
	{
		var iconName:String = data[1];
		var iconPath:String = 'credits/missing_icon';
		if (iconName != null && iconName.length > 0)
		{
			var testPath = 'credits/' + iconName;
			if (Paths.fileExists('images/$testPath.png', IMAGE)) iconPath = testPath;
			else if (Paths.fileExists('images/$testPath-pixel.png', IMAGE)) iconPath = testPath + '-pixel';
		}
		currentIcon = new FlxSprite(iconX, iconY).loadGraphic(Paths.image(iconPath));
		currentIcon.antialiasing = !iconPath.endsWith('-pixel') && ClientPrefs.data.antialiasing;
		currentIcon.setGraphicSize(150, 150);
		currentIcon.updateHitbox();
		add(currentIcon);

		currentName = new FlxText(0, nameY, 0, data[0], 40);
		currentName.setFormat(Paths.font("vcr.ttf"), 40, FlxColor.WHITE, CENTER);
		currentName.screenCenter(X);
		add(currentName);

		var roleText:String = (data[2] != null && data[2].length > 0) ? data[2] : null;
		if (roleText != null)
		{
			currentRole = new FlxText(0, roleY, 0, roleText, 24);
			currentRole.setFormat(Paths.font("DM.ttf"), 24, FlxColor.BLACK, CENTER);
			currentRole.screenCenter(X);

			var boxWidth:Int = Std.int(currentRole.width + boxPadding * 2);
			var boxHeight:Int = Std.int(currentRole.height + boxPadding);
			roleBox = new FlxSprite().makeGraphic(boxWidth, boxHeight, 0xCCADD8E6); // 淡蓝半透明
			roleBox.screenCenter(X);
			roleBox.x = (FlxG.width - boxWidth) / 2;
			roleBox.y = roleY - currentRole.height / 2 - boxPadding / 2+20;
			add(roleBox);
			add(currentRole);
		}

		if (animated)
		{
			var startX = iconX + direction * FlxG.width;
			currentIcon.x = startX;
			currentIcon.alpha = 0;
			currentName.alpha = 0;
			if (currentRole != null) currentRole.alpha = 0;
			if (roleBox != null) roleBox.alpha = 0;

			FlxTween.tween(currentIcon, {x: iconX, alpha: 1}, 0.4, {ease: FlxEase.sineInOut});

			FlxTween.tween(currentName, {alpha: 1}, 0.3, {startDelay: 0.1});
			if (currentRole != null) FlxTween.tween(currentRole, {alpha: 1}, 0.3, {startDelay: 0.1});
			if (roleBox != null) FlxTween.tween(roleBox, {alpha: 1}, 0.3, {startDelay: 0.1});
		}
	}

	function destroyCard()
	{
		if (currentIcon != null) { remove(currentIcon); currentIcon.destroy(); }
		if (currentName != null) { remove(currentName); currentName.destroy(); }
		if (currentRole != null) { remove(currentRole); currentRole.destroy(); }
		if (roleBox != null) { remove(roleBox); roleBox.destroy(); }
	}

	function changeSelection(change:Int = 0)
	{
		if (change == 0) return;

		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		var oldSelected = curSelected;

		do {
			curSelected = FlxMath.wrap(curSelected + change, 0, creditsStuff.length - 1);
		} while (unselectableCheck(curSelected));

		var direction = (curSelected > oldSelected) ? 1 : -1;

		destroyCard();

		buildCard(creditsStuff[curSelected], true, direction);

		var newColor:FlxColor = CoolUtil.colorFromString(creditsStuff[curSelected][4]);
		if (newColor != intendedColor)
		{
			intendedColor = newColor;
			FlxTween.cancelTweensOf(bg);
			FlxTween.color(bg, 0.5, bg.color, intendedColor);
		}
	}

	private function unselectableCheck(num:Int):Bool
	{
		return creditsStuff[num].length <= 1;
	}

	#if MODS_ALLOWED
	function pushModCreditsToList(folder:String)
	{
		var creditsFile:String = Paths.mods(folder + '/data/credits.txt');
		#if TRANSLATIONS_ALLOWED
		var translatedCredits:String = Paths.mods(folder + '/data/credits-${ClientPrefs.data.language}.txt');
		#end

		if (#if TRANSLATIONS_ALLOWED (FileSystem.exists(translatedCredits) && (creditsFile = translatedCredits) == translatedCredits) || #end FileSystem.exists(creditsFile))
		{
			var firstarray:Array<String> = File.getContent(creditsFile).split('\n');
			for (i in firstarray)
			{
				var arr:Array<String> = i.replace('\\n', '\n').split("::");
				if (arr.length >= 5) arr.push(folder);
				creditsStuff.push(arr);
			}
			creditsStuff.push(['']);
		}
	}
	#end

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
			FlxG.sound.music.volume += 0.5 * elapsed;

		if (creditsStuff.length > 1)
		{
			var shiftMult:Int = FlxG.keys.pressed.SHIFT ? 3 : 1;

			if (controls.UI_UP_P)
				changeSelection(-shiftMult);
			else if (controls.UI_DOWN_P)
				changeSelection(shiftMult);
		}

		if (controls.ACCEPT && (creditsStuff[curSelected][3]?.length > 4))
			CoolUtil.browserLoad(creditsStuff[curSelected][3]);

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		super.update(elapsed);
	}
}
