# Features: 
- More realistic vehicle damage
- Seatbelt & harness functionality
- Tire loss and ejection on impact

# Dependencies
* [qbcore](https://github.com/qbcore-framework)
* [qb-inventory](https://github.com/qbcore-framework/qb-inventory)  *(Optional)*
* [progressbar](https://github.com/qbcore-framework/progressbar)    *(Optional)*
* [ox_inventory](https://github.com/overextended/ox_inventory)      *(Optional)*
* [ox_lib](https://github.com/overextended/ox_lib)                  *(Optional)*

# Installation
1. **Delete old `qb-vehiclefailure`**
2. **Delete `seatbelt.lua` located in qb-smallresources/client**
3. **If necessary, update `exports['qb-smallresources']:HasHarness()`**

## Update Export
- **Replace export on line 80 in *ps-hud/client.lua*** 
```lua
exports['qb-vehiclehandler']:HasHarness()
```