local points = {}
local markerThread = nil
local activeMarkers = {}

--- Set callback function
--- @param callback function The callback function
--- @param callbackType string The type of callback ('onEnterCallback', 'onExitCallback', or 'insideCallback')
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