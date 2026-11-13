# Fivem-Roller-Shutter

animated storefront roller shutter for FiveM
=============================================================

Install
  1. Put the roller_shutter folder in your server's resources folder.
  2. Add  ensure roller_shutter  to server.cfg.

Place shutters
  - Stand in the shop doorway (on the line where the shutter should come down),
    centred, facing INTO the shop, and type  /shutter_here
  - Copy the line printed in the F8 console into Config.Shutters in config.lua.
  - Restart the resource.

Use
  - Walk up to it and press E, or use ox_target if it is running.
  - Set  job = 'police'  (any job name) on a shutter to lock it to that job.
  - Admins with the ACE  roller_shutter.admin  can always toggle.
  - Other resources: exports.roller_shutter:SetOpen(id, true/false), exports.roller_shutter:IsOpen(id)

Model
  prop_roller_shutter: 3.0 m wide x 2.8 m tall opening. Housing sits in front of the wall above the opening.
  Clips (prop_roller_shutter.ycd): open, close (5 s each), opened, closed.
