

core.progressbarLib = {}

---------------------------------
-- [[ PROGRESSBAR FUNCTIONS ]] --
---------------------------------

---@class progressbarDisableTable
---@field disableMovement? boolean
---@field disableCarMovement? boolean
---@field disableCombat? boolean
---@field disableMouse? boolean

---@class oxLibDisableTable
---@field move? boolean
---@field car? boolean
---@field combat? boolean
---@field mouse? boolean

--- func desc
---@param controlDisables progressbarDisableTable
---@return oxLibDisableTable
local function getOxLibDisableTable(controlDisables)
    local disable = {}

    if controlDisables.disableMovement then disable.move = true end
    if controlDisables.disableCarMovement then disable.car = true end
    if controlDisables.disableCombat then disable.combat = true end
    if controlDisables.disableMouse then disable.mouse = true end

    return disable
end

---@class progressbarPropTable
---@field model number
---@field bones? number
---@field coords? {x: number, y: number, z: number}
---@field rotation? {x: number, y: number, z: number}

---@class oxLibPropTable
---@field model number
---@field bone? number
---@field pos vector3
---@field rot vector3

--- func desc
---@param prop progressbarPropTable
---@param proptwo progressbarPropTable
---@return oxLibPropTable[] | oxLibPropTable | nil
local function getOxLibPropsTable(prop, proptwo)
    local oxProp = {}
    if next(prop) == nil and next(proptwo) == nil then
        return nil
    elseif next(prop) ~= nil and next(proptwo) ~= nil then
        local firstProp = {}
        local secondProp = {}
        firstProp.model = prop.model
        if prop.bones then firstProp.bone = prop.bones end
        if prop.coords then
            firstProp.pos = prop.coords
        else
            firstProp.pos = vector3(0.0, 0.0, 0.0)
        end
        if prop.rotation then
            firstProp.rot = prop.rotation
        else
            firstProp.rot = vector3(0.0, 0.0, 0.0)
        end
        table.insert(oxProp, firstProp)
        secondProp.model = proptwo.model
        if proptwo.bones then secondProp.bone = proptwo.bones end
        if proptwo.coords then
            firstProp.pos = proptwo.coords
        else
            firstProp.pos = vector3(0.0, 0.0, 0.0)
        end
        if proptwo.rotation then
            firstProp.rot = proptwo.rotation
        else
            firstProp.rot = vector3(0.0, 0.0, 0.0)
        end
        table.insert(oxProp, secondProp)
    elseif next(prop) ~= nil and next(proptwo) == nil then
        oxProp.model = prop.model
        if prop.bones then oxProp.bone = prop.bones end
        if prop.coords then
            oxProp.pos = prop.coords
        else
            oxProp.pos = vector3(0.0, 0.0, 0.0)
        end
        if prop.rotation then
            oxProp.rot = prop.rotation
        else
            oxProp.rot = vector3(0.0, 0.0, 0.0)
        end
    end

    return oxProp
end


---@class progressbarAnimTable
---@field animDict string
---@field anim string
---@field flag? integer

---@class progressbarScenarioTable
---@field task string
---@field flag? integer

---@class oxAnimTable
---@field dict string
---@field clip string
---@field flag? integer

---@class oxScenarioTable
---@field scenario string
---@field flag? integer

--- func desc
---@param anim progressbarAnimTable | progressbarScenarioTable
---@return oxAnimTable | oxScenarioTable | nil
local function getOxLibAnimTable(anim)
    local oxAnim = {}

    if next(anim) == nil then return nil end

    if anim.task ~= nil then oxAnim.scenario = anim.task
    elseif anim.animDict ~= nil and anim.anim ~= nil then
        oxAnim.dict = anim.animDict
        oxAnim.clip = anim.anim
    end
    if anim.flag then oxAnim.flag = anim.flag end

    return oxAnim
end

---@class progressbarData
---@field name string
---@field duration integer
---@field label string
---@field useWhileDead boolean
---@field canCancel boolean
---@field controlDisables progressbarDisableTable
---@field animation progressbarAnimTable | progressbarScenarioTable
---@field prop progressbarPropTable
---@field propTwo progressbarPropTable

---@class oxLibData
---@field duration integer
---@field label string
---@field useWhileDead boolean
---@field canCancel boolean
---@field controlDisables progressbarDisableTable
---@field animation progressbarAnimTable | progressbarScenarioTable
---@field prop progressbarPropTable
---@field propTwo progressbarPropTable

if Config.ProgressbarScript == 'ox_lib' then
    if GetResourceState('ox_lib') ~= 'started' then error('Progressbar script is set to ox_lib in config.lua! ox_lib resource should be started!') return end
    --- func desc
    ---@param data oxLibData
    ---@param success fun()
    ---@param failure fun()
    core.progressbarLib.startProgress = function(data, success, failure)
        if lib.progressBar({
            duration = data.duration,
            label = data.label,
            useWhileDead = data.useWhileDead,
            canCancel = data.canCancel,
            disable = getOxLibDisableTable(data.controlDisables),
            anim = getOxLibAnimTable(data.animation),
            prop = getOxLibPropsTable(data.prop, data.propTwo),
        }) then success() else failure() end
    end
elseif Config.ProgressbarScript == 'progressbar' then
    if GetResourceState('progressbar') ~= 'started' then error('Progressbar script is set to progressbar in config.lua! progressbar resource should be started!') return end
    --- func desc
    ---@param data progressbarData
    ---@param success fun()
    ---@param failure fun()
    core.progressbarLib.startProgress = function(data, success, failure)
        exports['progressbar']:Progress({
            name = data.name,
            duration = data.duration,
            label = data.label,
            useWhileDead = data.useWhileDead,
            canCancel = data.canCancel,
            controlDisables = data.controlDisables,
            animation = data.animation,
            prop = data.prop,
            propTwo = data.propTwo,
        }, function(cancelled)
            if not cancelled then
                ClearPedTasks(PlayerPedId())
                success()
            else
                failure()
            end
        end)
    end
end