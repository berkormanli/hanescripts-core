
core.inputLib = {}

---@class inputDialogOptionsData
---@field type string
---@field title string
---@field description? string
---@field placeholder? string
---@field icon? string
---@field isRequired? boolean
---@field inputName? string



if Config.InputScript == 'ox_lib' then
    if GetResourceState('ox_lib') ~= 'started' then error('Input script is set to ox_lib in config.lua! ox_lib resource should be started!') return end
    --- func desc
    ---@param options inputDialogOptionsData
    ---@return string | number | nil
    core.inputLib.inputDialog = function(options)
        local input = lib.inputDialog('', {
            { type = options.type, label = options.title, description = options.description, placeholder = options.placeholder, icon = options.icon, required = options.isRequired }
        })
        if input ~= nil then
            return input[1]
        else
            return nil
        end
    end
elseif Config.InputScript == 'qb-input' then
    if GetResourceState('qb-input') ~= 'started' then error('Input script is set to qb-input in config.lua! qb-input resource should be started!') return end
    --- func desc
    ---@param options inputDialogOptionsData
    ---@return string | number | nil
    core.inputLib.inputDialog = function(options)
        local p = promise.new()
        local input = exports['qb-input']:ShowInput({
            header = options.title,
            inputs = {
                {
                    text = options.placeholder, -- text you want to be displayed as a place holder
                    name = options.inputName, -- name of the input should be unique otherwise it might override
                    type = options.type, -- type of the input - number will not allow non-number characters in the field so only accepts 0-9
                    isRequired = true, -- Optional [accepted values: true | false] but will submit the form if no value is inputted
                },
            }
        })
        if input then
            if not input[options.inputName] then
                return nil
            end
            p:resolve(input[options.inputName])
        end
        local inputPromise = Citizen.Await(p)
        return tonumber(inputPromise)
    end
end

return core.inputLib