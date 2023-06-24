core.zoneLib = {}

-----------------------------
-- [[ UTILITY FUNCTIONS ]] --
-----------------------------

--- A helper function that converts array of numbers or vector4 to vector3
---@param coords number[] | vector4
---@return vector3
local function convertToVector3(coords)
    local _type = type(coords)

    if _type ~= 'vector3' then
        if _type == 'table' or _type == 'vector4' then
            return vec3(coords[1] or coords.x, coords[2] or coords.y, coords[3] or coords.z)
        end

        error(("expected type 'vector4' or 'table' (received %s)"):format(_type))
    end

    return coords
end

--- A helper function that converts array of numbers, vector4 or vector3 to vector2
---@param coords number[] | vector4 | vector3
---@return vector2
local function convertToVector2(coords)
    local _type = type(coords)

    if _type ~= 'vector2' then
        if _type == 'table' or _type == 'vector4' or _type == 'vector3' then
            return vec2(coords[1] or coords.x, coords[2] or coords.y)
        end

        error(("expected type 'vector3' or 'table' (received %s)"):format(_type))
    end

    return coords
end

----------------------------
--- [[ ZONE FUNCTIONS ]] ---
----------------------------

---@class sharedZoneOptions
---@field name string
---@field coords vector3
---@field size vector3
---@field offset number[]
---@field scale number[]
---@field rotation number
---@field debug boolean
---@field onEnter fun()
---@field onExit fun()
---@field [string] any

if Config.ZoneScript == 'PolyZone' then
    if GetResourceState('PolyZone') ~= 'started' then error('Zone script is set to PolyZone in config.lua! PolyZone resource should be started!') return end

    --- Wrapper function for creating Box zone.
    ---@param self any
    ---@param sharedZoneOption sharedZoneOptions
    core.zoneLib.createBoxZone = function(self, sharedZoneOption)
        local boxZone = BoxZone:Create(convertToVector3(sharedZoneOption.coords), sharedZoneOption.size.y, sharedZoneOption.size.x, {
            heading = sharedZoneOption.rotation,
            name = sharedZoneOption.name,
            offset=sharedZoneOption.offset,
            scale=sharedZoneOption.scale,
            debugPoly=sharedZoneOption.debug,
            data = {
                coords = convertToVector3(sharedZoneOption.coords),
                rotation = sharedZoneOption.rotation,
                targetSize = sharedZoneOption.targetSize,
                targetDebug = sharedZoneOption.targetDebug,
                seatModel = sharedZoneOption.seatModel,
                tableModel = sharedZoneOption.tableModel,
                seats = sharedZoneOption.seats,
                table = sharedZoneOption.tableNum,
                waiterLoc = sharedZoneOption.waiterLoc
            }
        })

        boxZone:onPlayerInOut(function(isPointInside)
            if isPointInside then
                sharedZoneOption.onEnter(boxZone)
            else
                sharedZoneOption.onExit(boxZone)
            end
        end)
        return boxZone
    end

    core.zoneLib.createPolyZone = function(self, sharedZoneOption)
        local points = {}
        for _, point in ipairs(sharedZoneOption.points) do
            points[#points+1] = convertToVector2(point)
        end
        local polyZone = PolyZone:Create(points, {
            name=sharedZoneOption.name,
            minZ=sharedZoneOption.minZ or nil,
            maxZ=sharedZoneOption.maxZ or nil,
            debugGrid=sharedZoneOption.debug or false,
            gridDivisions=sharedZoneOption.gridDivisions or 30
        })
        polyZone:onPlayerInOut(function(isPointInside)
            if isPointInside then
                sharedZoneOption.onEnter()
            else
                sharedZoneOption.onExit()
            end
        end)
        return polyZone
    end

    core.zoneLib.removeZone = function(self, zone)
        zone:destroy()
    end
elseif Config.ZoneScript == 'ox_lib' then
    if GetResourceState('ox_lib') ~= 'started' then error('Zone script is set to ox_lib in config.lua! ox_lib resource should be started!') return end

    --- Wrapper function for creating Box zone.
    ---@param self any
    ---@param sharedZoneOption sharedZoneOptions
    core.zoneLib.createBoxZone = function(self, sharedZoneOption)
        local boxZone = lib.zones.box({
            coords = convertToVector3(sharedZoneOption.coords),
            size = sharedZoneOption.size,
            targetSize = sharedZoneOption.targetSize,
            rotation = sharedZoneOption.rotation,
            debug = sharedZoneOption.debug,
            targetDebug = sharedZoneOption.targetDebug,
            inside = sharedZoneOption.inside or function()end,
            onEnter = sharedZoneOption.onEnter,
            onExit = sharedZoneOption.onExit,
            seatModel = sharedZoneOption.seatModel,
            tableModel = sharedZoneOption.tableModel,
            seats = sharedZoneOption.seats,
            table = sharedZoneOption.tableNum,
            waiterLoc = sharedZoneOption.waiterLoc
        })
        return boxZone
    end

    core.zoneLib.createPolyZone = function(self, sharedZoneOption)
        local polyZone = lib.zones.poly({
            points = sharedZoneOption.points,
            thickness = sharedZoneOption.thickness,
            debug = sharedZoneOption.debug or false,
            inside = sharedZoneOption.inside or function()end,
            onEnter = sharedZoneOption.onEnter,
            onExit = sharedZoneOption.onExit
        })
        return polyZone
    end

    core.zoneLib.removeZone = function(self, zone)
        zone:remove()
    end
end

return core.zoneLib