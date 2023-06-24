if not _VERSION:find('5.4') then
	error('^1Lua 5.4 must be enabled in the resource manifest!^0', 2)
end

local hanecore = 'hanescripts-core'
local export = exports[hanecore]

if not GetResourceState(hanecore):find('start') then
	error('^1hanescripts-core should be started before this resource.^0', 2)
end

-----------------------------------------------------------------------------------------------
-- Module
-----------------------------------------------------------------------------------------------

local LoadResourceFile = LoadResourceFile
local context = IsDuplicityVersion() and 'server' or 'client'
local function noop() end

local function loadModule(self, module)
	local dir = ('modules/%s'):format(module)
	local chunk = LoadResourceFile(hanecore, ('%s/%s.lua'):format(dir, context))
	local shared = LoadResourceFile(hanecore, ('%s/shared.lua'):format(dir))

	if shared then
		chunk = (chunk and ('%s\n%s'):format(shared, chunk)) or shared
	end

	if chunk then
		local fn, err = load(chunk, ('@@hanescripts-core/%s/%s.lua'):format(module, context))

		if not fn or err then
			return error(('\n^1Error importing module (%s): %s^0'):format(dir, err), 3)
        end

        local result = fn()
        self[module] = result or noop
        return self[module]
	end
end

local function loadResourceConfig()
    local dir = 'config.lua'
    local config = LoadResourceFile(GetCurrentResourceName(), dir)

    if config then
		local fn, err = load(config)
		if not fn or err then
			return error(('\n^1Error importing config for (%s)^0'):format(GetCurrentResourceName()), 3)
        end

        local result = fn()

        return result
    end

end

-----------------------------------------------------------------------------------------------
-- API
-----------------------------------------------------------------------------------------------

local function call(self, index, ...)
	local module = rawget(self, index)

	if not module then
        self[index] = noop
		module = loadModule(self, index)

		if not module then
			local function method(...)
				return export[index](nil, ...)
			end

			if not ... then
				self[index] = method
			end

			return method
		end
	end

	return module
end

core = setmetatable({
	name = hanecore,
	context = context,
	exports = {},
    resource = GetCurrentResourceName(),
    config = loadResourceConfig()

}, {
	__index = call,
	__call = call,
})

