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
--- @field public marker table The marker configuration
--- @field public showMarker boolean Whether to show the marker or not
local Points = {}
local points = {}
local markerThread = nil
local activeMarkers = {}

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
            activeMarkers[self.id] = nil
            points[i] = nil
            break
        end
    end
end

local function startMarkerThread()
    markerThread = CreateThread(function()
        while next(activeMarkers) do
            for _, point in pairs(activeMarkers) do
                DrawMarker(
                    point.marker.type or 1,
                    point.coords.x,
                    point.coords.y,
                    point.coords.z,
                    point.marker.dir and point.marker.dir.x or 0.0,
                    point.marker.dir and point.marker.dir.y or 0.0,
                    point.marker.dir and point.marker.dir.z or 0.0,
                    point.marker.rot and point.marker.rot.x or 0.0,
                    point.marker.rot and point.marker.rot.y or 0.0,
                    point.marker.rot and point.marker.rot.z or 0.0,
                    point.marker.scale and point.marker.scale.x or (point.radius * 2.0),
                    point.marker.scale and point.marker.scale.y or (point.radius * 2.0),
                    point.marker.scale and point.marker.scale.z or 0.5,
                    point.marker.color and point.marker.color.r or 0,
                    point.marker.color and point.marker.color.g or 255,
                    point.marker.color and point.marker.color.b or 0,
                    point.marker.color and point.marker.color.a or 150,
                    point.marker.bobUpAndDown or false,
                    point.marker.faceCamera or false,
                    point.marker.p19 or 2,
                    point.marker.rotate or false,
                    point.marker.textureDict or nil,
                    point.marker.textureName or nil,
                    point.marker.drawOnEnts or false
                )
            end
            Wait(0)
        end
    end)
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

    -- Gestion des markers
    if self.marker and self.showMarker then
        if distance <= 10.0 then
            if not activeMarkers[self.id] then
                activeMarkers[self.id] = self
                if not markerThread then
                    startMarkerThread()
                end
            end
        else
            if activeMarkers[self.id] then
                activeMarkers[self.id] = nil
                if not next(activeMarkers) then
                    markerThread = nil
                end
            end
        end
    end
end

--- Point constructor
--- @param coords vector3 The coordinates of the point
--- @param radius number The radius of the point
--- @param marker? table The marker configuration {type, scale, color, zOffset, dir, rot, bobUpAndDown, faceCamera, p19, rotate, textureDict, textureName, drawOnEnts}
--- @return Points The point object
function createPoint(coords, radius, marker)
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
    self.marker = marker
    self.showMarker = marker.show or false
    
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

-- Thread pour la vérification des points
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
