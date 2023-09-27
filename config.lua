Config = {}

Config.Progress  = 'ox'						-- Supported progress bars: (qb, ox, none)
Config.Inventory = 'ox'						-- Supported inventories: 	(qb, ox)

Config.Triggers = {						-- Lower these values to trigger more easily
	speed = {
		activation = 50.0,				-- Speed difference needed to trigger main ejection logic (LastSpeed - CurrentSpeed)
		override = 100.0,				-- Speed difference needed to snap seatbelt and force ejection
	},
	frame = 35.0,						-- Body damage difference needed to trigger main ejection logic (LastBodyHealth - CurrentBodyHealth)
}

Config.Settings = {
	limpMode = false,					-- If true, the engine never fails completely, so you will always be able to get to a mechanic unless you flip your vehicle and preventVehicleFlip is set to true
	limpModeMultiplier = 0.15,				-- The torque multiplier to use when vehicle is limping. Sane values are 0.05 to 0.25
	compatibilityMode = false,				-- prevents other scripts from modifying the fuel tank health to avoid random engine failure with BVA 2.01 (Downside is it disabled explosion prevention)

	torqueMultiplierEnabled = true,				-- Decrease engine torque as engine gets more and more damaged
	preventVehicleFlip = true,				-- If true, you can't turn over an upside down vehicle or control a vehicle while airborne

	deformationMultiplier = -1,				-- How much should the vehicle visually deform from a collision. Range 0.0 to 10.0 Where 0.0 is no deformation and 10.0 is 10x deformation. -1 = Don't touch. Visual damage does not sync well to other players.
	deformationExponent = 0.5,				-- How much should the handling file deformation setting be compressed toward 1.0. (Make cars more similar). A value of 1=no change. Lower values will compress more, values above 1 it will expand. Dont set to zero or negative.
	collisionDamageExponent = 0.5,				-- How much should the handling file deformation setting be compressed toward 1.0. (Make cars more similar). A value of 1=no change. Lower values will compress more, values above 1 it will expand. Dont set to zero or negative.

	damageFactorEngine = 20.0,				-- Sane values are 1 to 100. Higher values means more damage to vehicle. A good starting point is 10
	damageFactorBody = 20.0,				-- Sane values are 1 to 100. Higher values means more damage to vehicle. A good starting point is 10
	damageFactorPetrolTank = 32.0,				-- Sane values are 1 to 200. Higher values means more damage to vehicle. A good starting point is 64
	engineDamageExponent = 0.3,				-- How much should the handling file engine damage setting be compressed toward 1.0. (Make cars more similar). A value of 1=no change. Lower values will compress more, values above 1 it will expand. Dont set to zero or negative.
	weaponsDamageMultiplier = 1.2,				-- How much damage should the vehicle get from weapons fire. Range 0.0 to 10.0, where 0.0 is no damage and 10.0 is 10x damage. -1 = don't touch
	degradingHealthSpeedFactor = 2,				-- Speed of slowly degrading health, but not failure. Value of 10 means that it will take about 0.25 second per health point, so degradation from 800 to 305 will take about 2 minutes of clean driving. Higher values means faster degradation
	cascadingFailureSpeedFactor = 4.0,			-- Sane values are 1 to 100. When vehicle health drops below a certain point, cascading failure sets in, and the health drops rapidly until the vehicle dies. Higher values means faster failure. A good starting point is 8

	degradingFailureThreshold = 100.0,			-- Below this value, slow health degradation will set in
	cascadingFailureThreshold = 50.0,			-- Below this value, health cascading failure will set in
	engineSafeGuard = 30.0,					-- Final failure value. Set it too high, and the vehicle won't smoke when disabled. Set too low, and the car will catch fire from a single bullet to the engine. At health 100 a typical car can take 3-4 bullets to the engine before catching fire.

	classDamageMultiplier = {
		[0] = 	1.0,		--	0: Compacts
				1.0,		--	1: Sedans
				1.0,		--	2: SUVs
				0.95,		--	3: Coupes
				1.0,		--	4: Muscle
				0.95,		--	5: Sports Classics
				0.95,		--	6: Sports
				0.95,		--	7: Super
				0.27,		--	8: Motorcycles
				0.7,		--	9: Off-road
				0.25,		--	10: Industrial
				0.35,		--	11: Utility
				0.85,		--	12: Vans
				1.0,		--	13: Cycles
				0.4,		--	14: Boats
				0.7,		--	15: Helicopters
				0.7,		--	16: Planes
				0.75,		--	17: Service
				0.65,		--	18: Emergency
				0.67,		--	19: Military
				0.43,		--	20: Commercial
				0.1			--	21: Trains
	},
}

Config.DisabledClass = {
    [0] = true, --compacts
    [1] = true, --sedans
    [2] = true, --SUV's
    [3] = true, --coupes
    [4] = true, --muscle
    [5] = true, --sport classic
    [6] = true, --sport
    [7] = true, --super
    [8] = false, --motorcycle
    [9] = true, --offroad
    [10] = true, --industrial
    [11] = true, --utility
    [12] = true, --vans
    [13] = false, --bicycles
    [14] = false, --boats
    [15] = false, --helicopter
    [16] = false, --plane
    [17] = true, --service
    [18] = true, --emergency
    [19] = false --military
}

Config.BackEngine = {
    [`ninef`] = true,
    [`adder`] = true,
    [`vagner`] = true,
    [`t20`] = true,
    [`infernus`] = true,
    [`zentorno`] = true,
    [`reaper`] = true,
    [`comet2`] = true,
    [`jester`] = true,
    [`jester2`] = true,
    [`cheetah`] = true,
    [`cheetah2`] = true,
    [`prototipo`] = true,
    [`turismor`] = true,
    [`pfister811`] = true,
    [`ardent`] = true,
    [`nero`] = true,
    [`nero2`] = true,
    [`tempesta`] = true,
    [`vacca`] = true,
    [`bullet`] = true,
    [`osiris`] = true,
    [`entityxf`] = true,
    [`turismo2`] = true,
    [`fmj`] = true,
    [`re7b`] = true,
    [`tyrus`] = true,
    [`italigtb`] = true,
    [`penetrator`] = true,
    [`monroe`] = true,
    [`ninef2`] = true,
    [`stingergt`] = true,
    [`surfer`] = true,
    [`surfer2`] = true,
    [`comet3`] = true,
}
