# Features: 
- More realistic vehicle damage
- Seatbelt & harness functionality
- Tire loss and ejection on impact
- Prevent vehicle control while airborne/flipped
- No random ejections (desync between clients)

# Dependencies
* [qbcore](https://github.com/qbcore-framework)
* [ox_inventory](https://github.com/overextended/ox_inventory) or [qb-inventory](https://github.com/qbcore-framework/qb-inventory)
* [ox_lib](https://github.com/overextended/ox_lib)                  *(Optional)*
* [progressbar](https://github.com/qbcore-framework/progressbar)    *(Optional)*

# Installation
1. **Delete old `qb-vehiclefailure`**
2. **Delete `seatbelt.lua` located in *qb-smallresources/client***
3. **Place `qb-vehiclehandler` inside of `[qb]`**
4. **If necessary, update `exports['qb-smallresources']:HasHarness()`**

## Update Export
- **Replace export on line 80 in *ps-hud/client.lua*** 
```lua
exports['qb-vehiclefailure']:HasHarness()
```
