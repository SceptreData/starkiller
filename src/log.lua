local util = require 'util'

local fs = love.filesystem

local round = util.round
local strfmt = string.format

local logfile = nil
local COLOR_ENABLED = false

local log = {}
log.__index = log

local stringify = function(...)
  local t = {}
    for i = 1, select('#', ...) do
      local x = select(i, ...)
      if type(x) == 'number' then
        x = round(x, 0.1)
      end
      t[#t + 1] = tostring(x)
    end
    return table.concat(t, " ")
end

local time_str = function()
  return os.date("%H:%M:%S")
end


local info_str = function(log_lvl, dbg)
  return strfmt("[%s] %s: {%s:%s} :",
                time_str(), log_lvl, dbg.short_src, dbg.currentline)
end


local print_log = function(color, info, msg)
  if not COLOR_ENABLED then color = "" end
  print(strfmt("%s%s %s%s", color, info, COLOR_ENABLED and "\27[0m" or "", msg))
end


local new_log = function()
  logfile = fs.newFile('log.txt')
  local start_msg = strfmt("\nStarkiller Log: %s\n", os.date())
  local start_msg = start_msg .. "==========================\n\n"

  log.write(start_msg, NEW_LOG_FILE and 'w' or 'a')
end



log.write = function(msg, mode)
  if not logfile then
    new_log()
  end

  logfile:open(mode or "a")
  logfile:write(msg)
  logfile:close()
end

function log.info(...)
  if DISABLE_LOGS then return end
  local color = "\27[33m"

  local info = strfmt("[%s]", time_str())
  local msg = stringify(...)
  if PRINT_LOGS then 
    print_log(color, info, msg)
  end
 
  local str = strfmt("%s %s\n", info, msg)
  log.write(str)
end

function log.debug(...)
  if DISABLE_LOGS then return end
  local lvl = "DEBUG"
  local color = "\27[36m"
  
  local info = info_str(lvl, debug.getinfo(2, "Sl"))
  local msg = stringify(...)

  if PRINT_LOGS then
    print_log(color, info, msg)
  end

  local str = strfmt("%s %s\n", info, msg)
  log.write(str)
end

function log.error(...)
  if DISABLE_LOGS then return end
  local lvl = "ERROR"
  local color = "\27[35m"
  
  local info = info_str(lvl, debug.getinfo(2, "Sl"))
  local msg = stringify(...)

  if PRINT_LOGS then
    print_log(color, info, msg)
  end

  local str = strfmt("%s %s\n", info, msg)
  log.write(str)
end


return setmetatable(log, {__call = function(_, ...) return log.info(...) end})
