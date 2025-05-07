Config = {}

-- Players can't hit any gasstation with vehicles to get an explotion.
Config.PumpModels = {
    [-2007231801] = true,
    [1339433404] = true,
    [1694452750] = true,
    [1933174915] = true,
    [-462817101] = true,
    [-469694731] = true,
    [-164877493] = true
}

-- Save Zones
Config.Zones = {
    --Legion Square
    {
        disableControl = true,
        disableCollision = true,
        displayBlip = false,
        coords = vector3(195.4455, -934.0938, 30.2746),
        radius = 150,
        jobs = {["police"] = true}, -- Ignore the job for disable controlls
    }, {
        disableControl = true,
        disableCollision = true,
        displayBlip = false,
        coords = vector3(447.4954, -997.1366, 25.3492),
        radius = 70,
        jobs = {["police"] = true}, -- Ignore the job for disable controlls
    }
}