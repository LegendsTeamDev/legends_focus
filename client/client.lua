-- Resource name protection
local REQUIRED_RESOURCE_NAME = "legends_focus"
local resourceValid = false

Citizen.CreateThread(function()
    local currentResourceName = GetCurrentResourceName()
    
    if currentResourceName ~= REQUIRED_RESOURCE_NAME then
        while true do
            Citizen.Wait(0)
            SetTextFont(0)
            SetTextScale(0.0, 0.5)
            SetTextColour(255, 0, 0, 255)
            SetTextDropshadow(0, 0, 0, 0, 255)
            SetTextEdge(1, 0, 0, 0, 255)
            SetTextDropShadow()
            SetTextOutline()
            SetTextEntry("STRING")
            AddTextComponentString("~r~[ERROR] Resource name must be: " .. REQUIRED_RESOURCE_NAME)
            DrawText(0.5, 0.5)
        end
    else
        resourceValid = true
    end
end)

local cam = nil
local isZooming = false
local zoomFov = Config.FocusMultipllier
local defaultGameplayFov = 70.0
local currentFov = 70.0
local transitioning = false
local transitionSpeed = 2.5 -- Increase for faster zoom

-- Capture the default gameplay FOV once, after the game camera initializes
Citizen.CreateThread(function()
    Citizen.Wait(1000) -- wait for game camera to be ready
    local fov = GetGameplayCamFov()
    if fov >= 40.0 and fov <= 90.0 then
        defaultGameplayFov = fov
        currentFov = fov
    end
end)

-- Create camera
function CreateZoomCamera()
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
function DestroyZoomCamera()
    if cam and DoesCamExist(cam) then
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(cam, false)
        cam = nil
    end
end

-- Update camera to follow player
function UpdateCameraToFollowPlayer()
    if cam and DoesCamExist(cam) then
        local plyCoords = GetGameplayCamCoord()
        local plyRot = GetGameplayCamRot(2)
        SetCamCoord(cam, plyCoords.x, plyCoords.y, plyCoords.z)
        SetCamRot(cam, plyRot.x, plyRot.y, plyRot.z, 2)
    end
end

-- Smooth transition FOV
function TransitionFov(targetFov, onComplete)
    transitioning = true
    local step = targetFov > currentFov and transitionSpeed or -transitionSpeed

    Citizen.CreateThread(function()
        while math.abs(currentFov - targetFov) > 0.5 do
            currentFov = currentFov + step
            if cam and DoesCamExist(cam) then
                SetCamFov(cam, currentFov)
                UpdateCameraToFollowPlayer()
            end
            Citizen.Wait(10)
        end

        currentFov = targetFov
        if cam and DoesCamExist(cam) then
            SetCamFov(cam, currentFov)
        end

        transitioning = false
        if onComplete then onComplete() end
    end)
end

-- Main loop
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if not resourceValid then
            goto continue
        end

        if IsControlPressed(0, Config.Key) then -- E key
            if not isZooming and not transitioning then
                isZooming = true
                -- Use the default gameplay FOV captured at start
                currentFov = defaultGameplayFov
                CreateZoomCamera()
                TransitionFov(zoomFov)
            end
            UpdateCameraToFollowPlayer()

        elseif isZooming and not transitioning then
            isZooming = false
            -- Zoom out a bit less than default FOV to avoid overshoot (95%)
            local zoomOutTargetFov = defaultGameplayFov * 0.95
            TransitionFov(zoomOutTargetFov, function()
                DestroyZoomCamera()
            end)
        end

        ::continue::
    end
end)
