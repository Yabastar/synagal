-- import library
local Pine3D = require("Pine3D")
local expect = require "cc.expect"
local expect = expect.expect

-- create a new frame
local ThreeDFrame = Pine3D.newFrame()

-- create environment objects
local environmentObjects = {
  ThreeDFrame:newObject(Pine3D.models:mountains({
    color = colors.lightGray,
    y = -0.1,
    res = 12,
    scale = 100,
    randomHeight = 0.5,
    randomOffset = 0.5,
    snow = true,
    snowHeight = 0.6,
  })),
  ThreeDFrame:newObject(Pine3D.models:mountains({
    color = colors.green,
    y = -0.1,
    res = 18,
    scale = 50,
    randomHeight = 0.5,
    randomOffset = 0.5,
  })),
  ThreeDFrame:newObject(Pine3D.models:plane({
    color = colors.lime,
    size = 100,
    y = -0.1,
  })),
}

local function calculateTerminalVelocity(mass)
    local tVC = 5
    local terminalVelocity = tVC * math.sqrt(mass)
    return terminalVelocity
end

local function render()
    ThreeDFrame:drawObjects(environmentObjects)
    ThreeDFrame:drawObjects(objects)
    ThreeDFrame:drawBuffer()
end

function distance3D(x1, y1, z1, x2, y2, z2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2 + (z2 - z1)^2)
end

local function spheresCollide(msize, msize2, dist)
    local radiusSum = msize + msize2
    local distanceSquared = dist * dist
    
    return distanceSquared <= radiusSum * radiusSum
end
-- x = r, y = theta (pitch), z = phi (yaw)
-- thank you JackMacWindows, coolest guy in the computercraft scene
local function sphToRect(vec)
    return vector.new(vec.x * math.sin(vec.y) * math.cos(vec.z), vec.x * math.sin(vec.y) * math.sin(vec.z), vec.x * math.cos(vec.y))
end

local function impulse(vec,i)
    local x,y,z = table.unpack(sphToRect(vec))
    objects[i][13] = x
    objects[i][14] = y
    objects[i][15] = z
end

local objects = {}

local function syngalObj(model,x,y,z,rotx,roty,rotz,mass)
  expect(1,model,"string")
  expect(2,x,"int")
  expect(3,y,"int")
  expect(4,z,"int")
  expect(5,rotx,"int","nil")
  expect(6,roty,"int","nil")
  expect(7,rotz,"int","nil")
  expect(8,mass,"int")
  
  local createobj = ThreeDFrame:newObject(model, x, y, z, rotx, roty, rotz)
  createobj[13] = 0
  createobj[14] = 0
  createobj[15] = 0
  createobj[16] = mass
  table.insert(objects,createobj)
end



-- As of 0.0-b.1, you have to define object data below this comment.

syngalObj("models/pineapple", 100, 0, 80, nil, math.pi*0.125, nil, 10)
syngalObj("models/pineapple", 100, 0, -80, nil, math.pi*0.125, nil, 10)

objects[1][15] = 10
objects[2][15] = -10
objects[1][5] = 180



function _G.pcall(f, ...)
    return xpcall(f, debug.traceback, ...)
    end
    local oldresume = coroutine.resume
    function coroutine.resume(coro, ...)
    local res = table.pack(oldresume(coro, ...))
    if not res[1] then res[2] = debug.traceback(coro, res[2]) end
    return table.unpack(res, 1, res.n)
end

local function elasticequation(massA, massB, velocityA, velocityB)
    local totalMass = massA + massB

    local successA, resultA = pcall(function() return (velocityA:mul(massA - massB) + velocityB:mul(2 * massB)):div(totalMass) end)
    assert(successA, "Error in vector operation for finalvA: " .. textutils.serialise(resultA))

    local successB, resultB = pcall(function() return (velocityB:mul(massB - massA) + velocityA:mul(2 * massA)):div(totalMass) end)
    assert(successB, "Error in vector operation for finalvB: " .. textutils.serialise(resultB))

    return resultA, resultB
end


while true do
    sleep(0.05)
    for i in pairs(objects) do
        local msize = objects[i][8] 
        for j in pairs(objects) do
            if i ~= j then -- Avoid self-comparison
                local msize2 = objects[j][8]
                local dist = distance3D(objects[i][1], objects[i][2], objects[i][3], objects[j][1], objects[j][2], objects[j][3])
                local res = spheresCollide(msize/2, msize2/2, dist)
                local friction = false
                if res == true then
                    local dvector = vector.new(objects[i][13],objects[i][14],objects[i][15])
                    local dvector2 = vector.new(objects[j][13],objects[j][14],objects[j][15])
                    local finalvA,finalvB = elasticequation(objects[i][16],objects[j][16],dvector,dvector2)
                    objects[i][13] = finalvA.x
                    objects[i][14] = finalvA.y
                    objects[i][15] = finalvA.z

                    objects[j][13] = finalvB.x
                    objects[j][14] = finalvB.y
                    objects[j][15] = finalvB.z
                    friction = true
                end
                local curvel = objects[i][14]
                local tV = calculateTerminalVelocity(objects[i][16])
                if (curvel + 0.05) > tV then
                    curvel = tV
                else
                    curvel = curvel + 0.05
                    objects[i][14] = curvel
                end
                objects[i][2] = objects[i][2] - curvel

                objects[i][1] = objects[i][1] + objects[i][13]
                if math.abs(objects[i][13]) > 0 then
                    if objects[i][13] > 0 then
                        if friction == true then
                            if (objects[i][13] - 0.2) > 0 then
                                objects[i][13] = objects[i][13] - 0.2
                            else
                                objects[i][13] = 0
                            end
                        else
                            if (objects[i][13] - 0.1) > 0 then
                                objects[i][13] = objects[i][13] - 0.1
                            else
                                objects[i][13] = 0
                            end
                        end
                    else
                        if friction == true then
                            if (objects[i][13] + 0.2) > 0 then
                                objects[i][13] = 0
                            else
                                objects[i][13] = objects[i][13] + 0.2
                            end
                        else
                            if (objects[i][13] + 0.1) > 0 then
                                objects[i][13] = 0
                            else
                                objects[i][13] = objects[i][13] + 0.1
                            end
                        end
                    end
                end

                objects[i][3] = objects[i][3] + objects[i][15]
                if math.abs(objects[i][15]) > 0 then
                    if objects[i][15] > 0 then
                        if friction == true then
                            if (objects[i][15] - 0.2) > 0 then
                                objects[i][15] = objects[i][15] - 0.2
                            else
                                objects[i][15] = 0
                            end
                        else
                            if (objects[i][15] - 0.1) > 0 then
                                objects[i][15] = objects[i][15] - 0.1
                            else
                                objects[i][15] = 0
                            end
                        end
                    else
                        if friction == true then
                            if (objects[i][15] + 0.2) > 0 then
                                objects[i][15] = 0
                            else
                                objects[i][15] = objects[i][15] + 0.2
                            end
                        else
                            if (objects[i][15] + 0.1) > 0 then
                                objects[i][15] = 0
                            else
                                objects[i][15] = objects[i][15] + 0.1
                            end
                        end
                    end
                end
            end
        end
    end
    render()
end
