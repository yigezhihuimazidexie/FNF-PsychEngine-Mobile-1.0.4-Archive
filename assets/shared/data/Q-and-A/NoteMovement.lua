-- SCRIPT BY ADA_FUNNI
-- Do not remove this watermark, or you have zero rights to use this script.
local dadMoveAmount = 20
local bfMoveAmount = 20
local gfMoveAmount = 20
local returnDelay = 0.1
local cameraLockedTarget = nil
local cameraLockLoop = false
local disableNoteMovement = false

function onUpdatePost()
	if disableNoteMovement then
		return
	end
	if cameraLockLoop and cameraLockedTarget then
		return
	end
	
	if mustHitSection and getProperty('boyfriend.animation.curAnim') == 'idle' then
		runTimer('move it back', returnDelay);
	elseif not mustHitSection and getProperty('dad.animation.curAnim') == 'idle' then
		runTimer('move it back', returnDelay);
	end
end

local function moveCameraGF(direction)
	cameraSetGF();
	if direction == 0 then
		setProperty('camFollow.x', getProperty('camFollow.x') - gfMoveAmount);
	elseif direction == 1 then
		setProperty('camFollow.y', getProperty('camFollow.y') + gfMoveAmount);
	elseif direction == 2 then
		setProperty('camFollow.y', getProperty('camFollow.y') - gfMoveAmount);
	elseif direction == 3 then
		setProperty('camFollow.x', getProperty('camFollow.x') + gfMoveAmount);
	end
end

function goodNoteHit(id, direction, noteType, isSustainNote)
	if disableNoteMovement then
		return
	end
	if cameraLockLoop then
		return
	end
	
	if mustHitSection then
		if not gfSection then
			cameraSetTarget('boyfriend');
			if direction == 0 then
				setProperty('camFollow.x', getProperty('camFollow.x') - bfMoveAmount);
			elseif direction == 1 then
				setProperty('camFollow.y', getProperty('camFollow.y') + bfMoveAmount);
			elseif direction == 2 then
				setProperty('camFollow.y', getProperty('camFollow.y') - bfMoveAmount);
			elseif direction == 3 then
				setProperty('camFollow.x', getProperty('camFollow.x') + bfMoveAmount);
			end
		else
			moveCameraGF(direction);
		end
	end
end

function cameraSetGF()
	setProperty('camFollow.x', getMidpointX('gf') + getProperty('gf.cameraPosition[0]') + getProperty('girlfriendCameraOffset[0]'));
	setProperty('camFollow.y', getMidpointY('gf') + getProperty('gf.cameraPosition[1]') + getProperty('girlfriendCameraOffset[1]'));
end

function opponentNoteHit(id, direction, noteType, isSustainNote)
	if disableNoteMovement then
		return
	end
	if cameraLockLoop then
		return
	end
	
	if not mustHitSection then
		if not gfSection then
			cameraSetTarget('dad')
			if direction == 0 then
				setProperty('camFollow.x', getProperty('camFollow.x') - dadMoveAmount);
			elseif direction == 1 then
				setProperty('camFollow.y', getProperty('camFollow.y') + dadMoveAmount);
			elseif direction == 2 then
				setProperty('camFollow.y', getProperty('camFollow.y') - dadMoveAmount);
			elseif direction == 3 then
				setProperty('camFollow.x', getProperty('camFollow.x') + dadMoveAmount);
			end
		else
			moveCameraGF(direction);
		end
	end
end

function onTimerCompleted(tag, loops, loopsLeft)
	if disableNoteMovement then
		return
	end
	if cameraLockLoop then
		return
	end
	
	if tag == 'move it back' then
		if mustHitSection then
			if gfSection then
				cameraSetGF();
			else
				cameraSetTarget('boyfriend');
			end
		else
			cameraSetTarget('dad');
		end
	end
end

function onEvent(name, value1, value2)
	if name == 'cameraSetTarget' then
		cameraLockedTarget = value1
		
		if value2 ~= '' then
			cameraLockLoop = (value2 == 'true')
		else
			cameraLockLoop = false
		end
		
		cameraSetTarget(value1);
	
	elseif name == 'onInstant' then
		disableNoteMovement = true
		setProperty('cameraSpeed', 999.99)   
	elseif name == 'offInstant' then
		disableNoteMovement = false
		setProperty('cameraSpeed', 2)       
	end
end

function onSectionHit()
	if cameraLockLoop and cameraLockedTarget then
		cameraSetTarget(cameraLockedTarget);
	end
end