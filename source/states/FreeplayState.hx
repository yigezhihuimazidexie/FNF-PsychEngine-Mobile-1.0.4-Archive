package states;

import backend.WeekData;
import backend.Highscore;
import backend.Song;

import objects.HealthIcon;
import objects.MusicPlayer;
import objects.AudioDisplay;

import options.GameplayChangersSubstate;
import substates.ResetScoreSubState;

import flixel.math.FlxMath;
import flixel.util.FlxDestroyUtil;

import openfl.utils.Assets;

import haxe.Json;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var audioDisplay:AudioDisplay;
	var weekImage:FlxSprite;
	var weekImageBorder:FlxSprite;

	var selector:FlxText;
	private static var curSelected:Int = 0;
	var lerpSelected:Float = 0;
	var curDifficulty:Int = -1;
	var visualBars:Array<FlxSprite>;
	var visualTimer:Float = 0;
	private static var lastDifficultyName:String = Difficulty.getDefault();

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;
	var grpSongs:FlxTypedGroup<FreeplayItem>;

	var updatingWeekImage:Bool = false;

	//private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	var bg:FlxSprite;
	var intendedColor:Int;

	var missingTextBG:FlxSprite;
	var missingText:FlxText;

	var bottomString:String;
	var bottomText:FlxText;
	var bottomBG:FlxSprite;

	var player:MusicPlayer;
	var itemSpacing:Float = 120;

	override function create()
	{
		//Paths.clearStoredMemory();
		//Paths.clearUnusedMemory();
		
		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		if(WeekData.weeksList.length < 1)
		{
			FlxTransitionableState.skipNextTransIn = true;
			persistentUpdate = false;
			MusicBeatState.switchState(new states.ErrorState("NO WEEKS ADDED FOR FREEPLAY\n\nPress ACCEPT to go to the Week Editor Menu.\nPress BACK to return to Main Menu.",
				function() MusicBeatState.switchState(new states.editors.WeekEditorState()),
				function() MusicBeatState.switchState(new states.MainMenuState())));
			return;
		}

		for (i in 0...WeekData.weeksList.length)
		{
			if(weekIsLocked(WeekData.weeksList[i])) continue;

			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];

			for (j in 0...leWeek.songs.length)
			{
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				var colors:Array<Int> = song[2];
				if(colors == null || colors.length < 3)
				{
					colors = [146, 113, 253];
				}
				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
			}
		}
		Mods.loadTopMod();

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);
		bg.screenCenter();

		//grpSongs = new FlxTypedGroup<Alphabet>();
		//add(grpSongs);

		weekImageBorder = new FlxSprite(20, 0);
		weekImageBorder.screenCenter(Y);
		weekImageBorder.y += 200;
		weekImageBorder.x = 100;
		weekImageBorder.alpha = 0;
		weekImageBorder.makeGraphic(1, 1, 0xFFFFFFFF);
		weekImageBorder.visible = false;
		add(weekImageBorder);

		weekImage = new FlxSprite(20, 0).loadGraphic(Paths.image('week/placeholder'));
		weekImage.antialiasing = ClientPrefs.data.antialiasing;
		weekImage.setGraphicSize(0, FlxG.height*0.5);
		weekImage.updateHitbox();
		weekImage.screenCenter(Y);
		weekImage.y += 200;
		weekImage.x = 100;
		weekImage.visible = false;
		add(weekImage);

		grpSongs = new FlxTypedGroup<FreeplayItem>();
		add(grpSongs);

		var maxTextWidth:Float = 0;
		for (s in songs)
		{
			var tempText = new FlxText(0, 0, 0, s.songName, 32);
			tempText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.BLACK);
			if (tempText.width > maxTextWidth) maxTextWidth = tempText.width;
		}
		var fixedWidth:Int = Std.int(maxTextWidth + 40);

		var startX:Float = FlxG.width - fixedWidth - 200;
		var startY:Float = 150;
		var itemSpacing:Float = 120;

		grpSongs = new FlxTypedGroup<FreeplayItem>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			Mods.currentModDirectory = songs[i].folder;

			var item = new FreeplayItem(startX, startY + i * itemSpacing, songs[i].songName, songs[i].songCharacter, fixedWidth);
			item.targetY = i;
			item.visible = false;
			grpSongs.add(item);
		}

		//for (i in 0...songs.length)
			//{
				//var songText:Alphabet = new Alphabet(90, 320, songs[i].songName, true);
				//songText.targetY = i;
				//grpSongs.add(songText);
			
				//songText.scaleX = Math.min(1, 980 / songText.width);
				//songText.snapToPosition();
			
				// --- 新增：设置斜线排列的起始点和偏移量 ---
				//var startX:Float = FlxG.width - 250;   // 起始 X（右上角附近）
				//var startY:Float = 150;                 // 起始 Y
				//var offsetX:Float = -180;                // 每项向左偏移量
				//var offsetY:Float = 80;                  // 每项向下偏移量
			
				//songText.startPosition.set(startX, startY);
				// 因为 updateTexts 中 y 偏移会乘 1.3，所以 distancePerItem.y 需除以 1.3 以补偿
				//songText.distancePerItem.set(offsetX, offsetY / 1.3);
				// ----------------------------------------
			
				//Mods.currentModDirectory = songs[i].folder;
				//var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
				//icon.sprTracker = songText;
			
				//songText.visible = songText.active = songText.isMenuItem = false;
				//icon.visible = icon.active = false;
			
				//iconArray.push(icon);
				//add(icon);
			//}
		WeekData.setDirectoryFromWeek();

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);


		missingTextBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		missingTextBG.alpha = 0.6;
		missingTextBG.visible = false;
		add(missingTextBG);
		
		missingText = new FlxText(50, 0, FlxG.width - 100, '', 24);
		missingText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		missingText.scrollFactor.set();
		missingText.visible = false;
		add(missingText);

		if(curSelected >= songs.length) curSelected = 0;
		bg.color = songs[curSelected].color;
		intendedColor = bg.color;
		lerpSelected = curSelected;

		curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(lastDifficultyName)));

		bottomBG = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		bottomBG.alpha = 0.6;
		add(bottomBG);

		var leText:String = Language.getPhrase("freeplay_tip", "Press SPACE to listen to the Song / Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.");
		bottomString = leText;
		var size:Int = 16;
		bottomText = new FlxText(bottomBG.x, bottomBG.y + 4, FlxG.width, leText, size);
		bottomText.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, CENTER);
		bottomText.scrollFactor.set();
		add(bottomText);
		
		player = new MusicPlayer(this);
		add(player);

		itemSpacing = 120;

		//var barCount = 32;                    // 条形数量
		//visualBars = [];
		//for (i in 0...barCount)
		//{
			//var bar = new FlxSprite(0, 0).makeGraphic(10, 100, 0xAAFFFFFF); // 半透明白色
			//bar.origin.set(0, bar.height);     // 原点设在底部中心（x=0 左对齐，y=底部）
			//bar.visible = false;               // 默认隐藏
			//bar.scrollFactor.set();             // 固定屏幕
			//bar.x = (FlxG.width - barCount * 15) / 2 + i * 15; // 居中排列
			//bar.y = FlxG.height - 30;            // 距底部 30 像素
			//add(bar);
			//visualBars.push(bar);
		//}

		audioDisplay = new AudioDisplay(null, 0, FlxG.height - 30, FlxG.width, 100, 32, 2, 0xFFFFFFFF);
		audioDisplay.scrollFactor.set();
		audioDisplay.visible = false;
		add(audioDisplay);
				
		changeSelection();
		updateTexts();
		super.create();
		addTouchPad('LEFT_FULL', 'A_B_C_X_Y_Z');
	}

	override function closeSubState()
	{
		changeSelection(0, false);
		persistentUpdate = true;
		super.closeSubState();
		addTouchPad('LEFT_FULL', 'A_B_C_X_Y_Z');
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color));
	}

	function weekIsLocked(name:String):Bool
	{
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	var instPlaying:Int = -1;
	public static var vocals:FlxSound = null;
	public static var opponentVocals:FlxSound = null;
	var holdTime:Float = 0;

	var stopMusicPlay:Bool = false;
	override function update(elapsed:Float)
	{
		if(WeekData.weeksList.length < 1)
			return;

		if (FlxG.sound.music.volume < 0.7)
			FlxG.sound.music.volume += 0.5 * elapsed;

		lerpScore = Math.floor(FlxMath.lerp(intendedScore, lerpScore, Math.exp(-elapsed * 24)));
		lerpRating = FlxMath.lerp(intendedRating, lerpRating, Math.exp(-elapsed * 12));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(CoolUtil.floorDecimal(lerpRating * 100, 2)).split('.');
		if(ratingSplit.length < 2) //No decimals, add an empty space
			ratingSplit.push('');
		
		while(ratingSplit[1].length < 2) //Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';

		var shiftMult:Int = 1;
		if(FlxG.keys.pressed.SHIFT || touchPad.buttonZ.pressed) shiftMult = 3;

		if(songs.length > 1)
			{
				if(FlxG.keys.justPressed.HOME)
				{
					curSelected = 0;
					changeSelection();
					holdTime = 0;    
				}
				else if(FlxG.keys.justPressed.END)
				{
					curSelected = songs.length - 1;
					changeSelection();
					holdTime = 0;    
				}
				if (controls.UI_UP_P)
				{
					changeSelection(-shiftMult);
					holdTime = 0;
				}
				if (controls.UI_DOWN_P)
				{
					changeSelection(shiftMult);
					holdTime = 0;
				}
			
				if(controls.UI_DOWN || controls.UI_UP)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);
			
					if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
				}
			
				if(FlxG.mouse.wheel != 0)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);
					changeSelection(-shiftMult * FlxG.mouse.wheel, false);
				}
			}
			
			if (!player.playingMusic)
			{
				if (controls.UI_LEFT_P)
				{
					changeDiff(-1);
					_updateSongLastDifficulty();
				}
				else if (controls.UI_RIGHT_P)
				{
					changeDiff(1);
					_updateSongLastDifficulty();
				}
			}

		if (controls.BACK)
		{
			//if (player.playingMusic)
				//{
					//FlxG.sound.music.stop();
					//destroyFreeplayVocals();
					//FlxG.sound.music.volume = 0;
					//instPlaying = -1;
			
					//player.playingMusic = false;
					//player.switchPlayMusic();
			
					// --- 新增：隐藏音频显示 ---
					//audioDisplay.visible = false;
					//audioDisplay.clearUpdate();
					// --- 结束新增 ---
			
					//FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
					//FlxTween.tween(FlxG.sound.music, {volume: 1}, 1);
				//}
			//else 
			//{
				persistentUpdate = false;
				FlxTween.tween(FlxG.sound.music, {volume: 0}, 1,{onComplete: (tween) -> {
					FlxG.sound.music.stop();
					destroyFreeplayVocals();
					instPlaying = -1;
				}});
				FlxG.sound.music.stop();
				destroyFreeplayVocals();
				instPlaying = -1;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
			//}
		}

		if(FlxG.keys.justPressed.CONTROL || touchPad.buttonC.justPressed)
		{
			persistentUpdate = false;
			openSubState(new GameplayChangersSubstate());
			removeTouchPad();
		}
		else if(FlxG.keys.justPressed.SPACE)
			{
				if (instPlaying == curSelected && player.playingMusic)
				{
					if (FlxG.sound.music != null)
					{
						if (FlxG.sound.music.playing)
							FlxG.sound.music.pause();
						else
							FlxG.sound.music.resume();
					}
					if (vocals != null)
					{
						if (vocals.playing)
							vocals.pause();
						else
							vocals.resume();
					}
					if (opponentVocals != null)
					{
						if (opponentVocals.playing)
							opponentVocals.pause();
						else
							opponentVocals.resume();
					}
					player.pauseOrResume(FlxG.sound.music != null && !FlxG.sound.music.playing);
				}
				else
				{
					playPreviewMusic(true);
				}
			}
		else if (controls.ACCEPT)
		{

			
			player.playingMusic = false;
			player.switchPlayMusic();
			
			//audioDisplay.visible = false;
			FlxTween.tween(audioDisplay, {alpha: 0}, 1);
			audioDisplay.clearUpdate();
			
			FlxTween.tween(FlxG.sound.music, {volume: 0}, 1);
			FlxG.sound.music.stop();
			destroyFreeplayVocals();
			instPlaying = -1;

			persistentUpdate = false;
			var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
			var poop:String = Highscore.formatSong(songLowercase, curDifficulty);

			try
			{
				Song.loadFromJson(poop, songLowercase);
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = curDifficulty;

				trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
			}
			catch(e:haxe.Exception)
			{
				trace('ERROR! ${e.message}');

				var errorStr:String = e.message;
				if(errorStr.contains('There is no TEXT asset with an ID of')) errorStr = 'Missing file: ' + errorStr.substring(errorStr.indexOf(songLowercase), errorStr.length-1); //Missing chart
				else errorStr += '\n\n' + e.stack;

				missingText.text = 'ERROR WHILE LOADING CHART:\n$errorStr';
				missingText.screenCenter(Y);
				missingText.visible = true;
				missingTextBG.visible = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));

				updateTexts(elapsed);
				super.update(elapsed);
				return;
			}

			@:privateAccess
			if(PlayState._lastLoadedModDirectory != Mods.currentModDirectory)
			{
				trace('CHANGED MOD DIRECTORY, RELOADING STUFF');
				Paths.freeGraphicsFromMemory();
			}
			LoadingState.prepareToSong();
			LoadingState.loadAndSwitchState(new PlayState());
			#if !SHOW_LOADING_SCREEN FlxG.sound.music.stop(); #end
			stopMusicPlay = true;

			destroyFreeplayVocals();
			#if (MODS_ALLOWED && DISCORD_ALLOWED)
			DiscordClient.loadModRPC();
			#end
		}
		else if(controls.RESET || touchPad.buttonY.justPressed)
		{
			persistentUpdate = false;
			openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
			removeTouchPad();
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
		updateTexts(elapsed);
		super.update(elapsed);
	}
	
	function getVocalFromCharacter(char:String)
	{
		try
		{
			var path:String = Paths.getPath('characters/$char.json', TEXT);
			#if MODS_ALLOWED
			var character:Dynamic = Json.parse(File.getContent(path));
			#else
			var character:Dynamic = Json.parse(Assets.getText(path));
			#end
			return character.vocals_file;
		}
		catch (e:Dynamic) {}
		return null;
	}

	public static function destroyFreeplayVocals() {
		if(vocals != null) vocals.stop();
		vocals = FlxDestroyUtil.destroy(vocals);

		if(opponentVocals != null) opponentVocals.stop();
		opponentVocals = FlxDestroyUtil.destroy(opponentVocals);
	}

	function changeDiff(change:Int = 0)
	{
		//if (player.playingMusic)
			//return;

		curDifficulty = FlxMath.wrap(curDifficulty + change, 0, Difficulty.list.length-1);
		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		lastDifficultyName = Difficulty.getString(curDifficulty, false);
		var displayDiff:String = Difficulty.getString(curDifficulty);
		if (Difficulty.list.length > 1)
			diffText.text = '< ' + displayDiff.toUpperCase() + ' >';
		else
			diffText.text = displayDiff.toUpperCase();

		positionHighscore();
		missingText.visible = false;
		missingTextBG.visible = false;
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		//if (player.playingMusic)
			//return;

		curSelected = FlxMath.wrap(curSelected + change, 0, songs.length-1);
		_updateSongLastDifficulty();
		if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		var newColor:Int = songs[curSelected].color;
		if(newColor != intendedColor)
		{
			intendedColor = newColor;
			FlxTween.cancelTweensOf(bg);
			FlxTween.color(bg, 1, bg.color, intendedColor);
		}

		for (item in grpSongs)
			{
				item.select(item.targetY == curSelected);
			}
		
		Mods.currentModDirectory = songs[curSelected].folder;
		PlayState.storyWeek = songs[curSelected].week;
		Difficulty.loadFromWeek();
		
		var savedDiff:String = songs[curSelected].lastDifficulty;
		var lastDiff:Int = Difficulty.list.indexOf(lastDifficultyName);
		if(savedDiff != null && !Difficulty.list.contains(savedDiff) && Difficulty.list.contains(savedDiff))
			curDifficulty = Math.round(Math.max(0, Difficulty.list.indexOf(savedDiff)));
		else if(lastDiff > -1)
			curDifficulty = lastDiff;
		else if(Difficulty.list.contains(Difficulty.getDefault()))
			curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(Difficulty.getDefault())));
		else
			curDifficulty = 0;

		changeDiff();
		playPreviewMusic(false);
		_updateSongLastDifficulty();
		updateWeekImage();
	}


	function updateWeekImage()
		{
			var weekIndex = songs[curSelected].week;
			var shouldShow:Bool = false;
			var newImagePath:String = null;
		
			if (weekIndex >= 0 && weekIndex < WeekData.weeksList.length)
			{
				var weekFileName = WeekData.weeksList[weekIndex];
				var weekData = WeekData.weeksLoaded.get(weekFileName);
				if (weekData != null && weekData.image != null && weekData.image.length > 0)
				{
					var imagePath = 'week/' + weekData.image;
					if (Paths.fileExists('images/$imagePath.png', IMAGE))
					{
						shouldShow = true;
						newImagePath = imagePath;
					}
				}
			}
		
			FlxTween.cancelTweensOf(weekImage);
			FlxTween.cancelTweensOf(weekImageBorder);
		
			if (weekImage.visible)
			{
				FlxTween.tween(weekImage, {alpha: 0}, 0.2, {
					onComplete: function(_) {
						weekImage.visible = false;
						performImageUpdate(shouldShow, newImagePath);
					}
				});
				FlxTween.tween(weekImageBorder, {alpha: 0}, 0.2);
			}
			else
			{
				performImageUpdate(shouldShow, newImagePath);
			}
		}
		
		function performImageUpdate(shouldShow:Bool, newImagePath:String)
		{
			if (shouldShow && newImagePath != null)
			{
				weekImage.loadGraphic(Paths.image(newImagePath));
				weekImage.antialiasing = ClientPrefs.data.antialiasing;
				weekImage.setGraphicSize(0, FlxG.height * 0.5);
				weekImage.updateHitbox();
				weekImage.screenCenter(Y);
				weekImage.y -= 100;
				weekImage.x = 100;
				weekImage.alpha = 0;
				weekImage.visible = true;
		
				var borderThickness:Int = 2;
				weekImageBorder.setPosition(weekImage.x - borderThickness, weekImage.y - borderThickness);
				weekImageBorder.makeGraphic(Std.int(weekImage.width + borderThickness * 2), Std.int(weekImage.height + borderThickness * 2), 0xFFFFFFFF);
				weekImageBorder.alpha = 0;
				weekImageBorder.visible = true;
		
				FlxTween.tween(weekImage, {alpha: 1}, 0.2);
				FlxTween.tween(weekImageBorder, {alpha: 1}, 0.2);
			}
			else
			{
				weekImage.visible = false;
				weekImageBorder.visible = false;
			}
		}



	function playPreviewMusic(forceRestart:Bool = false)
		{
			if (songs.length == 0) return;
		
			if (!forceRestart && instPlaying == curSelected) return;
		
			var playNewMusic = function() {
				Mods.currentModDirectory = songs[curSelected].folder;
				var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
				Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
		
				destroyFreeplayVocals();
		
				if (PlayState.SONG.needsVoices)
				{
					vocals = new FlxSound();
					try
					{
						var playerVocals:String = getVocalFromCharacter(PlayState.SONG.player1);
						var loadedVocals = Paths.voices(PlayState.SONG.song, (playerVocals != null && playerVocals.length > 0) ? playerVocals : 'Player');
						if(loadedVocals == null) loadedVocals = Paths.voices(PlayState.SONG.song);
						
						if(loadedVocals != null && loadedVocals.length > 0)
						{
							vocals.loadEmbedded(loadedVocals);
							FlxG.sound.list.add(vocals);
							vocals.persist = vocals.looped = true;
							vocals.volume = 0.8;
							vocals.play();
							vocals.pause();
						}
						else vocals = FlxDestroyUtil.destroy(vocals);
					}
					catch(e:Dynamic)
					{
						vocals = FlxDestroyUtil.destroy(vocals);
					}
					
					opponentVocals = new FlxSound();
					try
					{
						var oppVocals:String = getVocalFromCharacter(PlayState.SONG.player2);
						var loadedVocals = Paths.voices(PlayState.SONG.song, (oppVocals != null && oppVocals.length > 0) ? oppVocals : 'Opponent');
						
						if(loadedVocals != null && loadedVocals.length > 0)
						{
							opponentVocals.loadEmbedded(loadedVocals);
							FlxG.sound.list.add(opponentVocals);
							opponentVocals.persist = opponentVocals.looped = true;
							opponentVocals.volume = 0.8;
							opponentVocals.play();
							opponentVocals.pause();
						}
						else opponentVocals = FlxDestroyUtil.destroy(opponentVocals);
					}
					catch(e:Dynamic)
					{
						opponentVocals = FlxDestroyUtil.destroy(opponentVocals);
					}
				}
		
				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0);
				FlxG.sound.music.volume = 0;
				FlxTween.tween(FlxG.sound.music, {volume: 0.8}, 0.5);
		
				if (audioDisplay != null)
				{
					trace("Playing inst: " + Paths.inst(PlayState.SONG.song));
					audioDisplay.snd = FlxG.sound.music;
					audioDisplay.visible = true;
					audioDisplay.stopUpdate = false;
				}
		
				instPlaying = curSelected;
				player.playingMusic = true;
				player.curTime = 0;
				player.switchPlayMusic();
			};
		
			if (FlxG.sound.music != null && FlxG.sound.music.playing)
			{
				trace("Music playing, amp = " + (FlxG.sound.music.amplitudeLeft + FlxG.sound.music.amplitudeRight) / 2);
				FlxTween.tween(FlxG.sound.music, {volume: 0}, 0.5, {
					onComplete: function(_) {
						if (FlxG.sound.music != null) FlxG.sound.music.stop();
						playNewMusic();
					}
				});
			}
			else
			{
				playNewMusic();
			}
		}

	inline private function _updateSongLastDifficulty()
		songs[curSelected].lastDifficulty = Difficulty.getString(curDifficulty, false);

	private function positionHighscore()
	{
		scoreText.x = FlxG.width - scoreText.width - 6;
		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
		diffText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
		diffText.x -= diffText.width / 2;
	}

	var _drawDistance:Int = 4;
	var _lastVisibles:Array<Int> = [];
	public function updateTexts(elapsed:Float = 0.0)
		{
			lerpSelected = FlxMath.lerp(curSelected, lerpSelected, Math.exp(-elapsed * 9.6));
		
			for (i in _lastVisibles)
			{
				grpSongs.members[i].visible = false;
			}
			_lastVisibles = [];
		
			var centerY:Float = FlxG.height / 2;
			var safeBottom:Float = FlxG.height - 150;
		
			var min:Int = Math.round(Math.max(0, Math.min(songs.length, lerpSelected - _drawDistance)));
			var max:Int = Math.round(Math.max(0, Math.min(songs.length, lerpSelected + _drawDistance)));
		
			for (i in min...max)
			{
				var item:FreeplayItem = grpSongs.members[i];
				var diff:Float = (i - lerpSelected);
				var yPos:Float = centerY + diff * itemSpacing;
		
				if (yPos + item.itemHeight > safeBottom || yPos < 0)
				{
					item.visible = false;
					continue;
				}
		
				item.y = yPos;
				item.visible = true;
				_lastVisibles.push(i);
			}
		}

	override function destroy():Void
	{
		super.destroy();

		FlxG.autoPause = ClientPrefs.data.autoPause;
		if (!FlxG.sound.music.playing && !stopMusicPlay)
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
	}	
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";
	public var lastDifficulty:String = null;

	public function new(song:String, week:Int, songCharacter:String, color:Int)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Mods.currentModDirectory;
		if(this.folder == null) this.folder = '';
	}
}





class FreeplayItem extends FlxSpriteGroup
{
    public var targetY:Int = 0;

    public var outerBg:FlxSprite;
    public var bg:FlxSprite;
    public var text:FlxText;
    public var icon:HealthIcon;
	public var itemHeight:Float;s

    public function new(x:Float, y:Float, songName:String, songCharacter:String, ?fixedWidth:Int = 0)
    {
        super(x, y);

        text = new FlxText(0, 0, 0, songName, 32);
        text.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.BLACK, LEFT);
        text.setBorderStyle(OUTLINE, FlxColor.WHITE, 1);

        var padding:Int = 20;
        var bgWidth:Int = (fixedWidth > 0) ? fixedWidth : Std.int(text.width + padding * 2);
        var bgHeight:Int = Std.int(text.height + padding);

        var outerPadding:Int = 4;
        var outerWidth:Int = bgWidth + outerPadding * 2;
        var outerHeight:Int = bgHeight + outerPadding * 2;
        outerBg = new FlxSprite().makeGraphic(outerWidth, outerHeight, 0xAAADD8E6);
        outerBg.x = -outerPadding;
        outerBg.y = -outerPadding;
        outerBg.alpha = 0.5;
        add(outerBg);

        bg = new FlxSprite().makeGraphic(bgWidth, bgHeight, 0xCCFFFFFF);
        bg.alpha = 0.75;
        bg.x = 0;
        bg.y = 0;
        add(bg);

        text.setPosition((bgWidth - text.width) / 2, (bgHeight - text.height) / 2);
        add(text);

        icon = new HealthIcon(songCharacter);
        icon.setPosition(bgWidth + 10, (bgHeight - icon.height) / 2);
        add(icon);

		itemHeight = bgHeight; 
    }

    public function select(selected:Bool)
    {
        if (selected)
        {
            bg.alpha = 1.0;
            text.color = 0xFFFFFF;
            icon.alpha = 1.0;
            outerBg.alpha = 0.7;
        }
        else
        {
            bg.alpha = 0.75;
            text.color = 0x000000;
            icon.alpha = 0.6;
            outerBg.alpha = 0.5;
        }
    }
}