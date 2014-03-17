
Lua Logging Library

=====

### Usage

Basic Usage

```
local log = require "log"
local logger = log.Logging:new("Foo","INFO")
logger:info("info message")
```

Adcance Usage

```
local log = require "log"
local handler = log.FileHandler("lua.log")
local level = "DEBUG"
local format = "${asctime} [${name}] ${level}: ${message}"
local logger = log.Logging:new("foo",
                                level,
                                handler,
                                format)
```

### File Handler

```
local log = require "log"
local handler = log.FileHandler("lua.log")
logger = log.Logging:new("Foo","INFO",handler)

logger:info("This message will be save into :%s","lua.log")
``` 

If not set handler, log will be redirect to stdout default.


### Log Format

default format:

```
local DEFAULT_FORMAT = "${asctime} [${name}] ${level}: ${message}"
```

The format can be reset with above four attribute.