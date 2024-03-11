-- import library
local Pine3D = require("Pine3D")

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

local objects = {}
Synagal = {}

function Synagal.synagalObj(model,x,y,z,rotx,roty,rotz,mass,collision,hitboxMul)
    local createobj = ThreeDFrame:newObject(model,x,y,z,rotx,roty,rotz)
    createobj[13] = 0
    createobj[14] = 0
    createobj[15] = 0
    createobj[16] = mass
    if collision == true then
        createobj[17] = true
        if hitboxMul ~= nil then
            createobj[18] = hitboxMul
        else
            createobj[18] = 2
        end
    else
        createobj[17] = false
        createobj[18] = 2
    end
    createobj[19] = 1
    createobj[20] = 1
    table.insert(objects,createobj)
    return createobj
end

local function calculateTerminalVelocity(mass)
    local tVC = 5
    local terminalVelocity = tVC * math.sqrt(mass)
    return terminalVelocity
end

function Synagal.setCollision(object, setting)
    object[17] = setting
end

function Synagal.setHitbox(object, number)
    object[18] = number
end

function Synagal.setVelocity(object,x,y,z)
    object[13] = x
    object[14] = y
    object[15] = z
end

function Synagal.setVelocityVector(object,vec)
    object[13] = vec.x
    object[14] = vec.y
    object[15] = vec.z
end

function Synagal.setvX(object,x)
    object[13] = x
end

function Synagal.setvY(object,y)
    object[14] = y
end

function Synagal.setvZ(object,z)
    object[15] = z
end

function Synagal.setX(object,x)
    object[1] = x
end

function Synagal.setY(object,y)
    object[2] = y
end

function Synagal.setZ(object,z)
    object[3] = z
end

function Synagal.setrotX(object,x)
    object[4] = x
end

function Synagal.setrotY(object,y)
    object[5] = y
end

function Synagal.setrotZ(object,z)
    object[6] = z
end

function Synagal.setMass(object,mass)
    object[16] = mass
end

function Synagal.setGravity(object,gravity)
    object[19] = gravity
end

function Synagal.setFriction(object,friction)
    object[20] = (friction*0.1)+0.1
end

function Synagal.render()
    ThreeDFrame:drawObjects(environmentObjects)
    ThreeDFrame:drawObjects(objects)
    ThreeDFrame:drawBuffer()
end

local function distance3D(x1, y1, z1, x2, y2, z2)
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

function Synagal.impulse(vec,object)
    local x,y,z = table.unpack(sphToRect(vec))
    object[13] = x
    object[14] = y
    object[15] = z
end


local function elasticequation(massA, massB, velocityA, velocityB, hitboxMulA, hitboxMulB)
    local function npcall(f, ...)
        return xpcall(f, debug.traceback, ...)
        end
        local oldresume = coroutine.resume
        function coroutine.resume(coro, ...)
        local res = table.pack(oldresume(coro, ...))
        if not res[1] then res[2] = debug.traceback(coro, res[2]) end
        return table.unpack(res, 1, res.n)
    end
    local totalMass = massA + massB

    local successA, resultA = npcall(function() return (velocityA:mul(massA - massB) + velocityB:mul(hitboxMulA * massB)):div(totalMass) end)
    assert(successA, "Error in vector operation for finalvA: " .. textutils.serialise(resultA))

    local successB, resultB = npcall(function() return (velocityB:mul(massB - massA) + velocityA:mul(hitboxMulB * massA)):div(totalMass) end)
    assert(successB, "Error in vector operation for finalvB: " .. textutils.serialise(resultB))

    return resultA, resultB
end


function Synagal.cycle()
    for i in pairs(objects) do
        local msize = objects[i][8] 
        for j in pairs(objects) do
            if i ~= j then -- Avoid self-comparison
                local msize2 = objects[j][8]
                local dist = distance3D(objects[i][1], objects[i][2], objects[i][3], objects[j][1], objects[j][2], objects[j][3])
                local res = spheresCollide(msize/2, msize2/2, dist)
                local friction = false
                if res == true then
                    if objects[i][17] == true then
                        local dvector = vector.new(objects[i][13],objects[i][14],objects[i][15])
                        local dvector2 = vector.new(objects[j][13],objects[j][14],objects[j][15])
                        local finalvA,finalvB = elasticequation(objects[i][16],objects[j][16],dvector,dvector2,objects[i][18],objects[j][18])
                        objects[i][13] = finalvA.x
                        objects[i][14] = finalvA.y
                        objects[i][15] = finalvA.z

                        objects[j][13] = finalvB.x
                        objects[j][14] = finalvB.y
                        objects[j][15] = finalvB.z
                        friction = true
                    end
                end
                local curvel = objects[i][14]
                local gravity = objects[i][19]
                local objFriction = objects[i][20]
                local tV = calculateTerminalVelocity(objects[i][16])
                if (curvel + ((gravity*0.05)*(objects[i][16]/10))) > (tV*gravity) then
                    curvel = (tV*gravity)
                else
                    curvel = curvel + ((gravity*0.05)*(objects[i][16]/10))
                    objects[i][14] = curvel
                end
                objects[i][2] = objects[i][2] - curvel

                objects[i][1] = objects[i][1] + objects[i][13]
                if math.abs(objects[i][13]) > 0 then
                    if objects[i][13] > 0 then
                        if friction == true then
                            if (objects[i][13] - objFriction) > 0 then
                                objects[i][13] = objects[i][13] - objFriction
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
                            if (objects[i][13] + objFriction) > 0 then
                                objects[i][13] = 0
                            else
                                objects[i][13] = objects[i][13] + objFriction
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
                            if (objects[i][15] - objFriction) > 0 then
                                objects[i][15] = objects[i][15] - objFriction
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
                            if (objects[i][15] + objFriction) > 0 then
                                objects[i][15] = 0
                            else
                                objects[i][15] = objects[i][15] + objFriction
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
end

return Synagal
