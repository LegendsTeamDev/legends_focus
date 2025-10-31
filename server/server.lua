-- Resource name protection
local REQUIRED_RESOURCE_NAME = "legends_focus"

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        local currentResourceName = GetCurrentResourceName()
        
        if currentResourceName ~= REQUIRED_RESOURCE_NAME then
            print("^1========================================^7")
            print("^1[ERROR] Resource Name Mismatch!^7")
            print("^1This resource must be named exactly: ^3" .. REQUIRED_RESOURCE_NAME .. "^7")
            print("^1Current name: ^3" .. currentResourceName .. "^7")
            print("^1Resource will not function properly.^7")
            print("^1========================================^7")
            StopResource(currentResourceName)
            return
        end
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    Wait(2000)
    if resourceName == GetCurrentResourceName() then
        local githubRawUrl = 'https://raw.githubusercontent.com/LegendsTeamDev/versionChecks/main/legends_focus.txt?' .. math.random()

        PerformHttpRequest(githubRawUrl, function(statusCode, responseText, headers)
            if statusCode == 200 then
                local success, versionData = pcall(function()
                    return json.decode(responseText)
                end)

                if success then
                    local latestVersion = versionData.version
                    local releaseNotes = versionData.notes
                    local changes = versionData.changes
                    local discordLink = versionData.discordLink

                    local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version', 0)
                    currentVersion = currentVersion:match("^%s*(.-)%s*$")

                    if currentVersion ~= latestVersion then
                        function ColorVersionComparison(currentVersion, latestVersion)
                            local currentParts = {}
                            local latestParts = {}
                        
                            for part in currentVersion:gmatch("[^.]+") do
                                table.insert(currentParts, part)
                            end
                            for part in latestVersion:gmatch("[^.]+") do
                                table.insert(latestParts, part)
                            end
                        
                            local coloredVersionCurrent = ""
                            local coloredVersionLatest = ""
                        
                            for i = 1, math.max(#currentParts, #latestParts) do
                                local currentPart = currentParts[i] or ""
                                local latestPart = latestParts[i] or ""
                            
                                if currentPart == latestPart then
                                    coloredVersionCurrent = coloredVersionCurrent .. "^5" .. currentPart .. "^7."
                                    coloredVersionLatest = coloredVersionLatest .. "^5" .. latestPart .. "^7."
                                else
                                    coloredVersionCurrent = coloredVersionCurrent .. "^1" .. currentPart .. "^7."
                                
                                    coloredVersionLatest = coloredVersionLatest .. "^2" .. latestPart .. "^7."
                                end
                            end
                        
                            coloredVersionCurrent = coloredVersionCurrent:sub(1, -2)
                            coloredVersionLatest = coloredVersionLatest:sub(1, -2)
                        
                            return coloredVersionCurrent, coloredVersionLatest
                        end

                        local coloredVersionCurrent, coloredVersionLatest = ColorVersionComparison(currentVersion, latestVersion)
                        print("^8========== ^1UPDATE REQUIRED ^8==========^0")
                        print("^3Resource:^0 " .. GetCurrentResourceName() .. " ^8is OUTDATED!")
                        print("^3Your Version:^0 " .. coloredVersionCurrent)
                        print("^3Latest Version:^0 " .. coloredVersionLatest)
                        print("^3Release Notes:^0 ^5" .. releaseNotes)
                        print("^3Changes:^0 ^6" .. changes)
                        print("^3Download:^0 ^6https://keymaster.fivem.net/asset-grants")
                        print("^3Read More:^0 ^6" .. discordLink)
                        print("^8========================================^0")
                    end
                else
                    print("Failed to parse JSON response from GitHub.")
                end
            else
                print("Failed to fetch version from GitHub. Status code: " .. statusCode)
            end
        end, 'GET')
    end
end)