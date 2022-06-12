local vein = exports['vein']
local controlWidth = 0.133
local labelWidth = 0.1
local isChecked = false

local function upgradeVehicle(vehicle)
    local modTypes = {11, 12, 13, 15, 16}

    SetVehicleModKit(vehicle, 0) -- must call to apply mods

    for _, modType in ipairs(modTypes) do
        local maxMod = GetNumVehicleMods(vehicle, modType) - 1
        SetVehicleMod(vehicle, modType, maxMod, false)
    end

    ToggleVehicleMod(vehicle, 18, true)
end

local function spawnVehicle(vehicleName, upgrades)
    if not IsModelInCdimage(vehicleName) or not IsModelAVehicle(vehicleName) then
        print('Invalid Vehicle Model')
        return
    end

    RequestModel(vehicleName)
    while not HasModelLoaded(vehicleName) do
        Wait(500)
    end

    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local vehicle = CreateVehicle(vehicleName, pos.x, pos.y, pos.z, GetEntityHeading(ped), true, false)

    SetPedIntoVehicle(ped, vehicle, -1)
    SetEntityAsNoLongerNeeded(vehicle)
    SetModelAsNoLongerNeeded(vehicleName)

    if upgrades == true then
        upgradeVehicle(vehicle)
    end
end

local function deleteVehicle(vehicle)
    SetEntityAsMissionEntity(vehicle, true, false)
    DeleteVehicle(vehicle)
end

local function showVehicleMenu()
    local isWindowOpened = true
    local windowX
    local windowY

    while isWindowOpened do
        Wait(0)

        vein:beginWindow(windowX, windowY)
        vein:heading('Vehicle Menu')

        vein:beginRow()
            isChecked = vein:checkBox(isChecked, 'Spawn with Upgrades')
        vein:endRow()

        vein:beginRow()
            vein:label('Vehicle Name')

            _, text = vein:textEdit(text, 'Vehicle Name', 30, false)

            if vein:button('Spawn Vehicle') then
                if isChecked then
                    if not IsModelInCdimage(text) or not IsModelAVehicle(text) then
                        print('Invalid Vehicle Model')
                    else
                        spawnVehicle(text, true)
                        isWindowOpened = false

                        print('Spawned Vehicle: ' .. text:lower() .. ' | with Upgrades')
                    end
                else
                    if not IsModelInCdimage(text) or not IsModelAVehicle(text) then
                        print('Invalid Vehicle Model')
                    else
                        spawnVehicle(text, false)
                        isWindowOpened = false

                        print('Spawned Vehicle: ' .. text:lower() .. ' | without Upgrades')
                    end
                end
            end
        vein:endRow()

        vein:beginRow()
            if vein:button('Apply Upgrades') then
                upgradeVehicle(GetVehiclePedIsIn(PlayerPedId(), false))
            end

            if vein:button('Delete Vehicle') then
                deleteVehicle(GetVehiclePedIsIn(PlayerPedId(), false))
            end
        vein:endRow()

        vein:spacing()

        if vein:button('Close') then
            isWindowOpened = false
        end

        windowX, windowY = vein:endWindow()
    end
end

RegisterCommand('vehicleMenu', function()
    showVehicleMenu()
end)
