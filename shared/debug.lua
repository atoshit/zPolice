--- Debug
--- @param text string The text to debug
function debug(text)
    if mainConfig.printDebug then
        return print(text)
    end
end