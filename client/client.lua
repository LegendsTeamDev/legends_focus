local cam = nil
local isZooming = false
local keyHeld = false
local pendingZoomOut = false
local transitioning = false
local currentFov = 70.0
local defaultGameplayFov = 70.0
local zoomFov = Config.FocusMultipllier
local transitionSpeed = 2.5
local lastKeyTime = 0

CreateThread(function()
    Wait(1000)
    local fov = GetGameplayCamFov()
    if fov >= 40.0 and fov <= 90.0 then
        defaultGameplayFov = fov
        currentFov = fov
    end
end)

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

local function DestroyZoomCamera()
    if cam and DoesCamExist(cam) then
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(cam, false)
        cam = nil
    end
end

local function UpdateCameraToFollowPlayer()
    if cam and DoesCamExist(cam) then
        local plyCoords = GetGameplayCamCoord()
        local plyRot = GetGameplayCamRot(2)
        SetCamCoord(cam, plyCoords.x, plyCoords.y, plyCoords.z)
        SetCamRot(cam, plyRot.x, plyRot.y, plyRot.z, 2)
    end
end

local function StartCameraLoop()
    CreateThread(function()
        while isZooming or transitioning do
            UpdateCameraToFollowPlayer()
            Wait(0)
        end
    end)
end

local StopFocus

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
        elseif pendingZoomOut and not keyHeld then
            pendingZoomOut = false
            isZooming = false
            local zoomOutTarget = defaultGameplayFov * 0.95
            TransitionFov(zoomOutTarget, function()
                DestroyZoomCamera()
            end)
        else
            pendingZoomOut = false
        end
    end)
end

local function StartFocus()
    local now = GetGameTimer()
    if now - lastKeyTime < 100 then return end
    lastKeyTime = now

    keyHeld = true
    pendingZoomOut = false

    if not isZooming and not transitioning then
        isZooming = true
        currentFov = defaultGameplayFov
        CreateZoomCamera()
        TransitionFov(zoomFov)
        StartCameraLoop()
    end
end

StopFocus = function()
    keyHeld = false

    if transitioning then
        pendingZoomOut = true
    elseif isZooming then
        isZooming = false
        local zoomOutTarget = defaultGameplayFov * 0.95
        TransitionFov(zoomOutTarget, function()
            DestroyZoomCamera()
        end)
    end
end

RegisterCommand('+focus', StartFocus, false)
RegisterCommand('-focus', StopFocus, false)
RegisterKeyMapping('+focus', 'Focus/Zoom', 'keyboard', 'CAPSLOCK')
