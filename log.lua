-- Usage
-- local log = require "log"
-- local handler = log.FileHandler("lua.log")
-- local logger = log.Logging:new("Foo","INFO","handler")

-- logger.debug("debug message")  
-- logger.info("info message")
-- logger.warn("warning message")
-- 


local LOG_LEVEL = {
    DEBUG = 1,
    INFO = 2,
    WARNING = 3,
    NOTICE = 4,
    ERROR = 5,
    FATAL = 6
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


local StreamHandler = {}

StreamHandler.__index = StreamHandler

function StreamHandler:new()
    return setmetatable({},self)
end

function StreamHandler.write(self,message)
    io.stdout:write(message,'\n')
end


local FileHandler = {}

FileHandler.__index = FileHandler

function FileHandler:new(file)
    return setmetatable({file=file},self)
end

function FileHandler.write(self,message)
    local f = io.open(self.file,"a")
    f:write(message,'\n')
    f:close()

end


local SyslogHandler = {}

SyslogHandler.__index = SyslogHandler

function SyslogHandler:new(address,facility)
    return setmetatable({address=address,facility=facility}, self)
end

function SyslogHandler:write(message)
    -- TODO
end



local Logging = {}

function Logging:new(name,level,handler,format)
    local level = LOG_LEVEL[level] or LOG_LEVEL.INFO 
    local handler = handler or StreamHandler:new()
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

function Logging.write(self,level,message,...)
    if LOG_LEVEL[level] < self.level then
        return
    end
    if not message then
        message = ''
    end
    if type(message) == "string" then
        message  = string.format(message,...)
    elseif type(message) == "table" then
        message = string.format("%s",message)
    end
    log = self.formatter(self.name,level,message)
    self.handler:write(log)
end


function Logging.debug(self, message, ...)
    self:write("DEBUG", message, ...)
end

function Logging.info(self,message,...)
    self:write("INFO", message, ...)
end


function Logging.warn(self,message,...)
    self:write("WARNING", message, ...)
end

function Logging.notice(self,message,...)
    self:write("NOTICE", message, ...)
end

function Logging.error(self,message,...)
    self:write("ERROR", message, ...)
end

function Logging.fatal(self,message,...)
    self:write("FATAL", message, ...)
end


local log = {
    Logging = Logging,
    StreamHandler = StreamHandler,
    FileHandler = FileHandler,
}


return log



