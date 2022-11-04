# Randolio Vape Script for QBCore Framework.


## Add to your qb-core/shared/items.lua

```
["vape"] = {
	["name"] = "vape",
	["label"] = "Vape",
	["weight"] = 2500,
	["type"] = "item",
	["image"] = "vape.png",
	["unique"] = true,
	["useable"] = true,
	["shouldClose"] = true,
	["combinable"] = nil,
	["description"] = "For the kids who think clouds are cool."
},
["vapejuice"] = {
    ["name"] = "vapejuice",
    ["label"] = "Vape Juice",
    ["weight"] = 100,
    ["type"] = "item",
    ["image"] = "vapejuice.png",
    ["unique"] = false,
    ['useable'] = false,
    ["shouldClose"] = true,
    ["combinable"] = nil,
    ["description"] = "100ml Vape Juice."
},
["emptyvape"] = {
    ["name"] = "emptyvape",
    ["label"] = "Juiceless Vape",
    ["weight"] = 100,
    ["type"] = "item",
    ["image"] = "vape.png",
    ["unique"] = false,
    ['useable'] = true,
    ["shouldClose"] = true,
    ["combinable"] = nil,
    ["description"] = "A juiceless vape."
},
```
## Add this emote to your dpemotes.
```
["hitvape"] = {
    "mp_player_inteat@burger",
    "mp_player_int_eat_burger",
        "Hit Vape",
    AnimationOptions = {
        Prop = 'ba_prop_battle_vape_01',
        PropBone = 18905,
        PropPlacement = {
            0.08, -0.00, 0.03, -150.0, 90.0, -10.0
        },
        EmoteMoving = true,
        EmoteLoop = true,
    }
},
```

## Add this your inventory/html/js/app.js underneath the code for the harness (check photo link for reference) https://i.imgur.com/BSGUxV5.png
```
} else if (itemData.name == "vape") {
    $(".item-info-title").html("<p>" + itemData.label + "</p>");
    $(".item-info-description").html(
        "<p>" + itemData.info.uses + "% Juice left.</p>"
    );
```
## Add this your inventory/server/main.lua into the /giveitem command (check photo link for reference) https://i.imgur.com/pko8ACw.png
```
elseif itemData["name"] == "vape" then
	info.uses = 100
```

## Add the .ogg file in [sounds] to interact-sound/client/html/sounds
## Add the images to your inventory image folder.
## Credit Jay for giving me the idea and to expand it: https://github.com/jay-fivem/qb-vape
