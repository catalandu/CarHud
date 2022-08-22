local directions = { [0] = 'N', [45] = 'NW', [90] = 'W', [135] = 'SW', [180] = 'S', [225] = 'SE', [270] = 'E', [315] = 'NE', [360] = 'N', } 

local table_elements = {
    HUD_VEHICLE_NAME = { id = 6, hidden = true },
    HUD_AREA_NAME = { id = 7, hidden = true },
    HUD_VEHICLE_CLASS = { id = 8, hidden = true },
    HUD_STREET_NAME = { id = 9, hidden = true }
}

function round(num, dec)
    local mult = 10^(dec or 0)
    return math.floor(num * mult + 0.5) / mult
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		for k, v in pairs(table_elements) do
			HideHudComponentThisFrame(v.id)
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		local Ped = GetPlayerPed(-1)

		if(IsPedInAnyVehicle(Ped)) then
			local vehicle = GetVehiclePedIsIn(Ped, false)
			local playerCar = GetVehiclePedIsIn(playerPed, false)
			if vehicle then
				local speed = (GetEntitySpeed(vehicle))
				local speed_show = math.ceil(speed * 3.6)
				local rpm_show = GetVehicleCurrentRpm(vehicle)
				if rpm_show > 0.99 then
					rpm_show = rpm_show*100
					rpm_show = rpm_show+math.random(-2,2)
					rpm_show = rpm_show/100
				end
				if rpm_show < 0.25 then
					rpm_show = rpm_show*100
					rpm_show = rpm_show+math.random(-1,1)
					rpm_show = rpm_show/100
				end

				if IsVehicleEngineOn(vehicle) then
					if rpm_show*10000 > 1000 then
						rpm_show = (rpm_show*10000)-1000
					end
				end

				rpm_bar = rpm_show/51.5

				local pos = GetEntityCoords(PlayerPedId())
				local var1, var2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z, Citizen.ResultAsInteger(), Citizen.ResultAsInteger())
				local current_zone = GetLabelText(GetNameOfZone(pos.x, pos.y, pos.z))

				for k,v in pairs(directions)do
					direction = GetEntityHeading(PlayerPedId())
					if(math.abs(direction - k) < 22.5)then
						direction = v
						break
					end
				end

				if GetStreetNameFromHashKey(var2) ~= '' then
					streetlabeltosend = GetStreetNameFromHashKey(var1)..', '..GetStreetNameFromHashKey(var2)
				else
					streetlabeltosend = GetStreetNameFromHashKey(var1)
				end

				local blip = GetFirstBlipInfoId(8)
                local distance = 0
				local ghahahah = 0
                if (blip ~= 0) then
                    local coord = GetBlipCoords(blip)
                    ghahahah = CalculateTravelDistanceBetweenPoints(GetEntityCoords(Citizen.InvokeNative(0x43A66C31C68491C0,-1)), coord)
                    
                    if blip ~= 0 then
                        if ghahahah ~= 0 then
                            distance = ghahahah
                        else
                            distance = 0
                        end
                    end
                end

				if (IsPedInAnyVehicle(Ped)) then
					SendNUIMessage({
						typeSH = 'ui',
						status = true,
						type = 'speedometer_send',
						speed = speed_show,
						rpm = round(rpm_show, 0),
						rpmBar = round(rpm_bar, 1),
						waypoint = distance,
						dirtext = direction,
						zonecur = current_zone,
						streetlabel = streetlabeltosend,
						x = direction .. ' | ' .. streetlabeltosend,
					})
				else
					SendNUIMessage({action = "toggle", show = false})
				end
			else
				SendNUIMessage({
					typeSH = 'ui',
					status = false
				})
			end
		else
			SendNUIMessage({
				typeSH = 'ui',
				status = false
			})
		end

		Citizen.Wait(200)
	end
end)

RegisterNetEvent('gg_cluster:toggleHud')
AddEventHandler('gg_cluster:toggleHud', function(toggle)
	hudShow = toggle
	if toggle then
		forceDisable = false
		--SendNUIMessage({action = "toggle", show = true})
	else
		forceDisable = true
		--SendNUIMessage({action = "toggle", show = false})
	end
end)