
local LOG_LEVEL = {
	DEBUG = 1,
	INFO = 2,
	WARNING = 3,
	ERROR = 4,
	FATAL = 5
}

local DEFAULT_FORMAT = "${asctime} [${name}] ${level}: ${message}"

local function interp(s, tab)
  return (s:gsub('($%b{})', function(w) return tab[w:sub(3, -2)] or w end))
end

local function now()
	return os.date("%Y-%m-%d %H:%M:%S")
end 

local Formatter = {}

function Formatter.new(fmt)
	local fmt  = fmt or DEFAULT_FORMAT
	return function(name,level,message)
		local paras = {name=name,level=level,message=message,asctime=now()}
		local f = interp(fmt,paras)
		return f
	end
end


local ConsoleHandler = {}

ConsoleHandler.__index = ConsoleHandler

function ConsoleHandler:new()
	return setmetatable({},self)
end

function ConsoleHandler.write(self,message)
	io.stdout:write(message,'\n')
end


local FileHandler = {}

FileHandler.__index = FileHandler

function FileHandler:new(file)
	return setmetatable({file=file},self)
end

function FileHandler.write(self,message)
	f = io.open(self.file,"a")
	f:write(message,'\n')
	f:close()

end



local Logging = {}

function Logging:new(name,level,handler,format)
	local level = LOG_LEVEL[level] or LOG_LEVEL.INFO 
	local handler = handler or ConsoleHandler:new()
	local format = format or DEFAULT_FORMAT
	local formatter = Formatter.new(format)
	local logger = {
		name = name,
		level = level,
		formatter = formatter,
		handler = handler
	}
	setmetatable(logger,self)
	self.__index = self
	return logger
end

function Logging.set_level(self,level)
	if LOG_LEVEL[level] ~= nil then
		self.level = LOG_LEVEL[level]
	else
		error(string.format("%s is not a valid log level",level))
	end
end

function Logging.get_level(self)
	for k,v in pairs(LOG_LEVEL) do
		if v == self.level then return k end
	end
end

function Logging.write(self,level,message)
	if LOG_LEVEL[level] < self.level then
		return
	end
	log = self.formatter(self.name,level,message)
	self.handler:write(log)
end


function Logging.debug(self, message, ...)
	self:write("DEBUG",message:format(...))
end

function Logging.info(self,message,...)
	self:write("INFO",message:format(...))
end


function Logging.warn(self,message,...)
	self:write("WARNING",message:format(...))
end

function Logging.error(self,message,...)
	self:write("ERROR",message:format(...))
end



local log = {
	Logging = Logging,
	ConsoleHandler = ConsoleHandler,
	FileHandler = FileHandler
}


return log



