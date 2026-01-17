-- Legends Focus - Optimized Version
-- Zero idle CPU usage - only runs when actively zooming

local cam = nil
local isZooming = false
local keyHeld = false -- Track if key is currently held
local zoomFov = Config.FocusMultipllier
local defaultGameplayFov = 70.0
local currentFov = 70.0
local transitioning = false
local transitionSpeed = 2.5

-- Capture the default gameplay FOV once, after the game camera initializes
CreateThread(function()
    Wait(1000)
    local fov = GetGameplayCamFov()
    if fov >= 40.0 and fov <= 90.0 then
        defaultGameplayFov = fov
        currentFov = fov
    end
end)

-- Create camera
local function CreateZoomCamera()
    if not cam or not DoesCamExist(cam) then
        cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        local camCoords = GetGameplayCamCoord()
        local camRot = GetGameplayCamRot(2)
        SetCamCoord(cam, camCoords.x, camCoords.y, camCoords.z)
        SetCamRot(cam, camRot.x, camRot.y, camRot.z, 2)
        SetCamFov(cam, currentFov)
        SetCamActive(cam, true)
        RenderScriptCams(true, false, 0, true, true)
    end
end

-- Destroy camera
local function DestroyZoomCamera()
    if cam and DoesCamExist(cam) then
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(cam, false)
        cam = nil
    end
end

-- Update camera to follow player
local function UpdateCameraToFollowPlayer()
    if cam and DoesCamExist(cam) then
        local plyCoords = GetGameplayCamCoord()
        local plyRot = GetGameplayCamRot(2)
        SetCamCoord(cam, plyCoords.x, plyCoords.y, plyCoords.z)
        SetCamRot(cam, plyRot.x, plyRot.y, plyRot.z, 2)
    end
end

-- Camera update loop - ONLY runs while zooming
local function StartCameraLoop()
    CreateThread(function()
        while isZooming or transitioning do
            UpdateCameraToFollowPlayer()
            Wait(0)
        end
    end)
end

-- Forward declaration
local StopFocus

-- Smooth transition FOV
local function TransitionFov(targetFov, onComplete)
    transitioning = true
    local step = targetFov > currentFov and transitionSpeed or -transitionSpeed

    CreateThread(function()
        while math.abs(currentFov - targetFov) > 0.5 do
            currentFov = currentFov + step
            if cam and DoesCamExist(cam) then
                SetCamFov(cam, currentFov)
            end
            Wait(10)
        end

        currentFov = targetFov
        if cam and DoesCamExist(cam) then
            SetCamFov(cam, currentFov)
        end

        transitioning = false

        if onComplete then
            onComplete()
        elseif isZooming and not keyHeld then
            -- Key was released during zoom-in, immediately start zoom-out
            StopFocus()
        end
    end)
end

-- Start focus (key pressed)
local function StartFocus()
    keyHeld = true
    if not isZooming and not transitioning then
        isZooming = true
        currentFov = defaultGameplayFov
        CreateZoomCamera()
        TransitionFov(zoomFov)
        StartCameraLoop()
    end
end

-- Stop focus (key released)
StopFocus = function()
    keyHeld = false
    if isZooming and not transitioning then
        isZooming = false
        local zoomOutTargetFov = defaultGameplayFov * 0.95
        TransitionFov(zoomOutTargetFov, function()
            DestroyZoomCamera()
        end)
    end
end

-- Event-driven key handling (zero idle cost)
RegisterCommand('+focus', StartFocus, false)
RegisterCommand('-focus', StopFocus, false)

-- Default key mapping - players can rebind in GTA settings
RegisterKeyMapping('+focus', 'Focus/Zoom', 'keyboard', Config.Key)
