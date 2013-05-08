local Group, Test = {}, {}


--[[ Group ]]--

function Group:New(name)
	return setmetatable({name = name, tests = {}}, self)
end

function Group:AnySuccess()
	for _, test in pairs(self.tests) do
		if test:AnySuccess() then
			return true
		end
	end
end

function Group:AnyError()
	for _, test in pairs(self.tests) do
		if test:AnyError() then
			return true
		end
	end
end

function Group:__call()
	for _, test in pairs(self.tests) do
		test()
	end
end

function Group:__newindex(key, value)
	if type(value) == 'function' then
		tinsert(self.tests, Test:New(key, value))
	end
end

function Group:__lt(other)
	return self.name < other.name
end


--[[ Test ]]--

function Test:New(name, func)
	local test = {
		name = name,
		func = func,
		errors = {},
		numOk = 0
	}

	return setmetatable(test, self)
end

function Test:AnySuccess()
	return self.numOk > 0
end

function Test:AnyError()
	return #self.errors > 0
end

function Test:__call(...)
	local success, message = pcall(self.func, ...)
	if success then
		self.numOk = self.numOk + 1
	else
		tinsert(self.errors, message)
	end
end

function Test:__lt(other)
	return self.name < other.name
end

Test.__index = Test
WoWTest.Group = Group