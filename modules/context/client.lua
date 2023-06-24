
core.contextLib = {}

---@class optionMetadata
---@field value number
---@field label string

---@class contextOptions
---@field metadata optionMetadata
---@field title string
---@field description string
---@field disabled boolean
---@field onSelect fun()

---@class contextData
---@field id? string
---@field title? string
---@field icon? string
---@field options contextOptions

--[[RegisterNetEvent('contextLib:client:triggerFunction')
AddEventHandler('contextLib:client:triggerFunction', function(data)
    -- Possible check if there is some kind of bug abuse or event triggered by Lua executor.
    if core.resource ~= GetCurrentResourceName() then return end
    data.method()
end)]]

if Config.InputScript == 'ox_lib' then
    if GetResourceState('ox_lib') ~= 'started' then error('Context script is set to ox_lib in config.lua! ox_lib resource should be started!') return end
    --- func desc
    ---@param contextOptions contextData
    ---@return contextOptions
    local function createContextOptions(contextOptions, ...)
        return contextOptions.options
    end

    --- func desc
    ---@param contextOptions contextData
    core.contextLib.showContext = function(contextOptions, ...)
        lib.registerContext({
            id = contextOptions.id,
            title = contextOptions.title,
            options = createContextOptions(contextOptions)
            })
        lib.showContext(contextOptions.id)
    end
elseif Config.ContextLib == 'qb-menu' then
    if GetResourceState('qb-menu') ~= 'started' then error('Context script is set to qb-menu in config.lua! qb-menu resource should be started!') return end
    --- func desc
    ---@param contextOptions contextData
    local function createContextOptions(contextOptions, ingredientsString)
        local options = {
          {
            header = contextOptions.title,
            icon = contextOptions.icon,
            isMenuHeader = true,
          }
        }
        for _, option in ipairs(contextOptions.options) do
          local ingredientText = ingredientsString..'<p>'
          if option.metadata then
            for _, ingredient in ipairs(option.metadata) do
              ingredientText = ingredientText..' '..ingredient.value..' '..ingredient.label..'<br>'
            end
            ingredientText = ingredientText..'</p>'
          end
          options[#options+1] = {
            header = option.title,
            txt = option.metadata and option.description..ingredientText or option.description,
            isMenuHeader = option.disabled,
            params = option.onSelect and {
              event = 'contextLib:client:triggerFunction',
              args = {
                method = option.onSelect
              }
            } or nil
          }
        end
        return options
    end

    --- func desc
    ---@param contextOptions contextData
    core.contextLib.showContext = function(contextOptions, ingredientsString)
        exports['qb-menu']:openMenu(createContextOptions(contextOptions, ingredientsString))
    end
end

return core.contextLib