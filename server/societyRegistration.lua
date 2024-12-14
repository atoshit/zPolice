local mC <const> = mainConfig

local societyName <const> = mC.societyData.name
local societyLabel <const> = mC.societyData.label
local societyAccount <const> = mC.societyData.account
local societyType <const> = mC.societyData.type

--- Register Society
--- @param name string The name of the society
--- @param label string The label of the society
--- @param account string The account of the society
--- @param type string The type of the society
local function registerSociety(name, label, account, type)
    TriggerEvent('esx_society:registerSociety', name, label, account, account, account, {type = type})
    debug('[name: ^4' .. name .. '^7, label: ^4' .. label .. '^7, account: ^4' .. account .. '^7, type: ^4' .. type .. '^7]')
end

registerSociety(societyName, societyLabel, societyAccount, societyType)