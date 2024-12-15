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

--- Set callback function
--- @param callback function The callback function
--- @param callbackType string The type of callback ('onEnterCallback', 'onExitCallback', or 'insideCallback')
--- @return Points The point object
local function setCallback(self, callback, callbackType)
    local callbackTypes = {
        enter = 'onEnterCallback',
        exit = 'onExitCallback',
        inside = 'insideCallback'
    }
    
    local type = callbackTypes[callbackType]
    if type then
        self[type] = callback
    end
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
            table.remove(points, i)
            break
        end
    end
end

-- Fonction utilitaire pour obtenir les valeurs du marker avec des valeurs par défaut
local function getMarkerValue(marker, key, subkey, default)
    if not marker[key] then return default end
    if subkey then
        return marker[key][subkey] or default
    end
    return marker[key] or default
end

--- Start marker thread
local function startMarkerThread()
    markerThread = CreateThread(function()
        while next(activeMarkers) do
            for _, point in pairs(activeMarkers) do
                local m = point.marker
                DrawMarker(
                    getMarkerValue(m, 'type', nil, 1),
                    point.coords.x, point.coords.y, point.coords.z,
                    getMarkerValue(m, 'dir', 'x', 0.0),
                    getMarkerValue(m, 'dir', 'y', 0.0),
                    getMarkerValue(m, 'dir', 'z', 0.0),
                    getMarkerValue(m, 'rot', 'x', 0.0),
                    getMarkerValue(m, 'rot', 'y', 0.0),
                    getMarkerValue(m, 'rot', 'z', 0.0),
                    getMarkerValue(m, 'scale', 'x', point.radius * 2.0),
                    getMarkerValue(m, 'scale', 'y', point.radius * 2.0),
                    getMarkerValue(m, 'scale', 'z', 0.5),
                    getMarkerValue(m, 'color', 'r', 0),
                    getMarkerValue(m, 'color', 'g', 255),
                    getMarkerValue(m, 'color', 'b', 0),
                    getMarkerValue(m, 'color', 'a', 150),
                    getMarkerValue(m, 'bobUpAndDown', nil, false),
                    getMarkerValue(m, 'faceCamera', nil, false),
                    getMarkerValue(m, 'p19', nil, 2),
                    getMarkerValue(m, 'rotate', nil, false),
                    getMarkerValue(m, 'textureDict', nil, nil),
                    getMarkerValue(m, 'textureName', nil, nil),
                    getMarkerValue(m, 'drawOnEnts', nil, false)
                )
            end
            Wait(0)
        end
        markerThread = nil
    end)
end

--- Update the point state
local function update(self)
    local playerCoords = GetEntityCoords(PlayerPedId())
    local distance = #(playerCoords - self.coords)
    local wasInside = self.isInside

    self.isInside = distance <= self.radius

    if self.isInside ~= wasInside then
        if self.isInside then
            if self.onEnterCallback then self.onEnterCallback(self) end
            self:startInsideThread()
        else
            if self.onExitCallback then self.onExitCallback(self) end
            self:stopInsideThread()
        end
    end

    if self.marker and self.showMarker then
        local isNearMarker = distance <= 10.0
        local isMarkerActive = activeMarkers[self.id] ~= nil

        if isNearMarker ~= isMarkerActive then
            if isNearMarker then
                activeMarkers[self.id] = self
                if not markerThread then startMarkerThread() end
            else
                activeMarkers[self.id] = nil
            end
        end
    end
end

--- Point constructor
--- @param coords vector3 The coordinates of the point
--- @param radius number The radius of the point
--- @param marker? table The marker configuration
--- @return Points The point object
function createPoint(coords, radius, marker)
    local self = {
        id = #points + 1,
        coords = coords,
        radius = radius,
        isInside = false,
        onEnterCallback = nil,
        onExitCallback = nil,
        insideCallback = nil,
        lastCheckTime = 0,
        insideThread = nil,
        marker = marker,
        showMarker = marker and marker.show or false,
        onEnter = function(self, callback) return setCallback(self, callback, 'enter') end,
        onExit = function(self, callback) return setCallback(self, callback, 'exit') end,
        inside = function(self, callback) return setCallback(self, callback, 'inside') end,
        startInsideThread = startInsideThread,
        stopInsideThread = stopInsideThread,
        update = update,
        remove = remove
    }
    
    points[#points + 1] = self
    return self
end

-- Thread for verify points
CreateThread(function()
    local wait = 500
    while true do
        local playerCoords = GetEntityCoords(PlayerPedId())
        local hasNearbyPoints = false

        for i = 1, #points do
            local point = points[i]
            if point then
                local distance = #(playerCoords - point.coords)
                if distance <= point.radius + 10.0 then
                    point:update()
                    hasNearbyPoints = true
                end
            end
        end

        wait = hasNearbyPoints and 100 or 500
        Wait(wait)
    end
end)

local receptionPoint = createPoint(clientConfig.receptionCall.coords, clientConfig.receptionCall.radius, {
        show = true,
        type = 1,
        scale = {x = 1.5, y = 1.5, z = 0.5},
        color = {r = 0, g = 255, b = 0, a = 150},
        zOffset = -1.0
    }
)   

receptionPoint:onEnter(function(self)
    print('Player entered reception point')
end)

receptionPoint:inside(function(self)
    print('Player is inside reception point')
end)

receptionPoint:onExit(function(self)
    print('Player exited reception point')
end)