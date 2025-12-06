GoldPanningConfig = GoldPanningConfig or {}

GoldPanningConfig.Locations = {
    vector3(-1401.143, 2005.674, 60.833),
}

GoldPanningConfig.MaxDistance = 6.0

GoldPanningConfig.Blip = {
    label = "Gold Panning",
    sprite = 467,
    color = 5,
    scale = 0.8,
    display = 2,
}

GoldPanningConfig.Progress = {
    duration = 10000,
    label = "Gold Panning...",
}

GoldPanningConfig.Rewards = {
   { name = "goldore",      count = 1, chance = 15 },
   { name = "scrapmetal",   count = 1, chance = 18 },
   { name = "petrock",      count = 1, chance = 6 },
   { name = "earrings",     count = 1, chance = 3 },
   { name = "meth_pipe",    count = 1, chance = 9 },
   { name = "foodbag",      count = 1, chance = 21 },
   { name = "crushedrock",  count = 1, chance = 28 },
}