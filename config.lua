Config = {}

Config.Model = `prop_roller_shutter`
Config.AnimDict = 'prop_roller_shutter'
Config.AnimDuration = 5000      -- ms, length of the open / close clips

-- Model size: 3.0 m wide x 2.8 m tall opening. The origin is on the floor, centred in the opening,
-- on the curtain plane. Heading = direction the shutter faces (towards the street).
-- Stand on the street side, centred in the doorway, facing the shop, and run /shutter_here:
-- it prints a ready-made vector4 (heading already flipped to face the street).
Config.Shutters = {
    -- { id = 'example_shop', coords = vector4(25.70, -1347.30, 29.50, 270.0), job = nil, open = false },
}

-- Who may toggle: a job name per shutter (Qbox/QBCore job, checked server side), or anyone if job = nil.
-- Players with the ACE permission below can always toggle.
Config.AdminAce = 'roller_shutter.admin'

Config.InteractDistance = 2.0   -- metres from the curtain centre
Config.SpawnDistance = 120.0    -- local objects are created/removed around the player
Config.Key = 38                 -- E
Config.UseOxTarget = true       -- uses ox_target when it is running, otherwise a key prompt
