--- @class Points
--- @field public coords vector3 The coordinates of the point
--- @field public radius number The radius of the point
--- @field public isInside boolean Whether the player is inside the point
--- @field public onEnterCallback function The callback function when the player enters the point
--- @field public onExitCallback function The callback function when the player exits the point
--- @field public insideCallback function The callback function called every frame while inside the point
--- @field public lastCheckTime number The last time the point was checked
--- @field public insideThread number The thread ID for inside callback
local Points = {}
Points.__index = Points
local points = {}

--- Point constructor
--- @param coords vector3 The coordinates of the point
--- @param radius number The radius of the point
--- @return Points The point object
function Points.new(coords, radius)
    local self = setmetatable({}, Points)
    self.coords = coords
    self.radius = radius
    self.isInside = false
    self.onEnterCallback = nil
    self.onExitCallback = nil
    self.insideCallback = nil
    self.lastCheckTime = 0
    self.insideThread = nil
    
    points[#points + 1] = self
    
    return self
end

--- Set onEnter callback
--- @param callback function The callback function when the player enters the point
function Points:onEnter(callback)
    self.onEnterCallback = callback
end

--- Set onExit callback
--- @param callback function The callback function when the player exits the point
function Points:onExit(callback)
    self.onExitCallback = callback
end

--- Set inside callback (called every frame while inside)
--- @param callback function The callback function called every frame while inside the point
function Points:inside(callback)
    self.insideCallback = callback
end

--- Start inside thread
function Points:startInsideThread()
    if self.insideThread then return end
    
    self.insideThread = CreateThread(function()
        while self.isInside do
            if self.insideCallback then
                self.insideCallback()
            end
            Wait(0)
        end
    end)
end

--- Stop inside thread
function Points:stopInsideThread()
    if self.insideThread then
        self.insideThread = nil
    end
end

--- Update the point state
function Points:update()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local distance = #(playerCoords - self.coords)

    if distance <= self.radius then
        if not self.isInside then
            self.isInside = true
            if self.onEnterCallback then
                self.onEnterCallback()
            end
            self:startInsideThread()
        end
    else
        if self.isInside then
            self.isInside = false
            if self.onExitCallback then
                self.onExitCallback()
            end
            self:stopInsideThread()
        end
    end

    if distance <= 10.0 then
        DrawMarker(1, self.coords.x, self.coords.y, self.coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, self.radius * 2.0, self.radius * 2.0, 0.5, 0, 255, 0, 150, false, false, 2, nil, nil, false)
    end
end

CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        for i = 1, #points do
            local point = points[i]
            local distance = #(playerCoords - point.coords)
            if distance <= point.radius + 10.0 then
                point:update()
            end
        end
        
        Wait(500)
    end
end)

local receptionPoint = Points.new(clientConfig.receptionCall.coords, clientConfig.receptionCall.radius)

receptionPoint:onEnter(function()
    print('Player entered reception point')
end)

receptionPoint:inside(function()
    print('Player is inside reception point')
end)

receptionPoint:onExit(function()
    print('Player exited reception point')
end)
