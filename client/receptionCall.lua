local cC <const> = clientConfig.receptionCall

local receptionCallPoint = createPoint(cC.coords, cC.radius, cC.marker)   

receptionCallPoint:inside(function(self)
    zUI.ShowHelpNotification("Appuyer sur E pour interagir", { Color = "#1212e9" })
    
    if IsControlJustPressed(0, 38) then
        menu["reception"]:SetVisible(not menu["reception"]:IsVisible())
    end
end)
