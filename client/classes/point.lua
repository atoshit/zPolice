--- @class Points
--- @field public coords vector3 The coordinates of the point
--- @field public radius number The radius of the point
--- @field public isInside boolean Whether the player is inside the point
--- @field public onEnterCallback function The callback function when the player enters the point
--- @field public onExitCallback function The callback function when the player exits the point
--- @field public insideCallback function The callback function called every frame while inside the point
--- @field public lastCheckTime number The last time the point was checked
--- @field public insideThread number The thread ID for inside callback
--- @field public id number The unique identifier of the point
local Points = {}
local points = {}

--- Set onEnter callback
--- @param callback function The callback function when the player enters the point
local function onEnter(self, callback)
    self.onEnterCallback = callback
    return self
end

--- Set onExit callback
--- @param callback function The callback function when the player exits the point
local function onExit(self, callback)
    self.onExitCallback = callback
    return self
end

--- Set inside callback (called every frame while inside)
--- @param callback function The callback function called every frame while inside the point
local function inside(self, callback)
    self.insideCallback = callback
    return self
end

--- Start inside thread
local function startInsideThread(self)
    if self.insideThread then return end
    
    self.insideThread = CreateThread(function()
        while self.isInside do
            if self.insideCallback then
                self.insideCallback(self)
            end
            Wait(0)
        end
    end)
end

--- Stop inside thread
local function stopInsideThread(self)
    if self.insideThread then
        self.insideThread = nil
    end
end

--- Delete a point
--- @param point Points The point to delete
local function remove(self)
    for i = 1, #points do
        if points[i] == self then
            if self.isInside then
                self:stopInsideThread()
            end
            points[i] = nil
            break
        end
    end
end

--- Update the point state
local function update(self)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local distance = #(playerCoords - self.coords)

    if distance <= self.radius then
        if not self.isInside then
            self.isInside = true
            if self.onEnterCallback then
                self.onEnterCallback(self)
            end
            self:startInsideThread()
        end
    else
        if self.isInside then
            self.isInside = false
            if self.onExitCallback then
                self.onExitCallback(self)
            end
            self:stopInsideThread()
        end
    end

    if distance <= 10.0 then
        DrawMarker(1, self.coords.x, self.coords.y, self.coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, self.radius * 2.0, self.radius * 2.0, 0.5, 0, 255, 0, 150, false, false, 2, nil, nil, false)
    end
end

--- Point constructor
--- @param coords vector3 The coordinates of the point
--- @param radius number The radius of the point
--- @return Points The point object
function createPoint(coords, radius)
    local self = {}
    self.id = #points + 1
    self.coords = coords
    self.radius = radius
    self.isInside = false
    self.onEnterCallback = nil
    self.onExitCallback = nil
    self.insideCallback = nil
    self.lastCheckTime = 0
    self.insideThread = nil
    
    points[#points + 1] = self
    
    self.onEnter = onEnter
    self.onExit = onExit
    self.inside = inside
    self.startInsideThread = startInsideThread
    self.stopInsideThread = stopInsideThread
    self.update = update
    self.remove = remove
    
    return self
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

local receptionPoint = createPoint(clientConfig.receptionCall.coords, clientConfig.receptionCall.radius)

receptionPoint:onEnter(function(self)
    print('Player entered reception point')
end)

receptionPoint:inside(function(self)
    print('Player is inside reception point')
    print(self.id)
end)

receptionPoint:onExit(function(self)
    print('Player exited reception point')
end)
