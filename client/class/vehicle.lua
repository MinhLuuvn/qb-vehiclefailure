Vehicle = {}
Vehicle.__index = Vehicle

function Vehicle:createData()
    local data = {
        ref = nil,
        class = nil,
        seat = nil,
        maxSeats = nil,
        active = false,
        seatbelt = false,
        harness = false,
    }
    setmetatable(data, Vehicle)
    return data
end

function Vehicle:setData(veh, seat, active)
    self.ref = veh
    self.class = GetVehicleClass(veh) or nil
    self.seat = seat
    self.maxSeats = GetVehicleModelNumberOfSeats(GetEntityModel(veh)) or nil
    self.active = active
    return self
end

function Vehicle:resetData()
    self.ref = nil
    self.class = nil
    self.seat = nil
    self.maxSeats = nil
    self.active = false
    return self
end

function Vehicle:setSeatbelt(beltState)
    self.seatbelt = beltState
end

function Vehicle:setHarness(harnessState)
    self.harness = harnessState
end

function Vehicle:isDriver()
    return (self.seat == -1)
end

function Vehicle:isClassDisabled()
    return Config.DisabledClass[self.class]
end