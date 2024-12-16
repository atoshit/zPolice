menu["reception"] = zUI.CreateMenu("Police", "Menu de réception", "Bienvenue à la réception", nil, nil, nil)

menu["reception"]:SetItems(function(Items)
    Items:AddButton("Demander un agent", nil, {RightBadge = 'https://img.icons8.com/ios_filled/512/FFFFFF/apple-phone.png'}, function(onSelected)
        if onSelected then
            print("Option 1 sélectionnée.")
        end
    end)

    Items:AddLinkButton("Se faire recruter", nil, {RightBadge = 'https://img.icons8.com/win10/512/FFFFFF/plus.png'}, "https://discord.gg/zPolice")
end)


menu["reception"]:OnOpen(function()
    FreezeEntityPosition(PlayerPedId(), true)
end)

menu["reception"]:OnClose(function()
    FreezeEntityPosition(PlayerPedId(), false)
end)
