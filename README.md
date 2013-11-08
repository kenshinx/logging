
Lua Logging Library

=====

### Usage

Basic Usage

```
local log = require "log"
local logger = log.Logging:new("Foo","INFO")

logger.debug("debug message")  --Default level: INFO, so debug log will no output.
logger.info("info message")
logger.warn("warning message")
```

### File Handler

```
local log = require "log"
local handler = log.FileHandler("lua.log")
logger = log.Logging:new("Foo","INFO",handler)

logger.info("This message will be save into :%s","lua.log")
``` 

If not set handler, log will be redirect to stdout default.


### Log Format

default format:

```
local DEFAULT_FORMAT = "${asctime} [${name}] ${level}: ${message}"
```

The format can be reset with above four attribute.