Docs
----

**Synagal.synagalObj**  
  
Creates a SYNAGAL object  
  
Returns: SYNAGAL object  
  
1\. Model  
type = string  
Path to Pine3D model  
  
2-4. XYZ  
type = number  
X,Y,Z coordinates  
  
5-7. Rotation XYZ  
type = number  
Rotation in X,Y,Z form  
  
8\. Mass  
type = number  
Object mass (1 unit is about 0.1 kg)  
  
9\. (Optional) Collision (true/false)  
type = boolean  
Enables or disables collision  
  
10\. (Optional) Hitbox multiplier  
type = number  
A lower number increases hitbox size

`local objectA = Synagal.synagalObj("models/pineapple", 100, 0, -80, nil, math.pi*0.125, nil, 25, true)`

* * *

**Synagal.impulse**  
  
Returns: void  
  
1\. SYNAGAL object  
type = SYNAGAL object  
  
2\. X,Y,Z spherical  
type = vector  
Vector containing a spherical angle

```
local spherical = vector.new(10,30,60)

Synagal.impulse(spherical,objectA)
```

* * *

**Synagal.setGravity**  
  
Returns: void  
  
1\. SYNAGAL object  
type = SYNAGAL object  
  
2\. Gravity  
type = number  
Amount of gravity (default 1)

`Synagal.setGravity(objectA, 1)`

* * *

**Synagal.setCollision**  
  
Returns: void  
  
1\. SYNAGAL object  
type = SYNAGAL object  
  
2\. Collision  
type = boolean  
Enables or disables collision

`Synagal.setCollision(objectA, true)`

* * *

**Synagal.setMass**  
  
Returns: void  
  
1\. SYNAGAL object  
type = SYNAGAL object  
  
2\. Mass  
type = number  
Mass of object (1 unit is about 0.1 kg)

`Synagal.setMass(objectA, 50)`

* * *

**Synagal.setVelocity**  
  
Returns: void  
  
1\. SYNAGAL object  
type = SYNAGAL object  
  
2-4. X,Y,Z  
type = number  
X,Y,Z velocity

`Synagal.setVelocity(objectA, 10, 5, 30)`

* * *

**Synagal.setVelocityVector**  
  
Returns: void  
  
1\. SYNAGAL object  
type = SYNAGAL object  
  
2\. Vector  
type = vector  
Vector containing velocity values
```
local velocity = vector.new(10,5,30) -- x,y,z

Synagal.setVelocityVector(objectA, velocity)
```

* * *

**Synagal.setHitbox**
  
Returns: void  
  
1\. SYNAGAL object  
type = SYNAGAL object  
  
2\. Hitbox divisor  
type = number  
Sets hitbox size, a lower number is a bigger hitbox

`Syagal.setHitbox(objectA, 1) -- default is 2, size increases the lower the number`

* * *

```
setX
setY
setZ
setvX -- velocity X
setvY
setvZ
setrotX -- rotation X
setrotY
setrotZ
```
All apply to the following  
  
Returns: void  
  
1\. SYNAGAL object  
type = SYNAGAL object  
  
2\. X,Y,Z  
type = number  
Sets either position, rotation, or velocity X Y Z

* * *

Example Program
---------------

```
Synagal = require "Synagal" -- or wherever SYNAGAL is located

local objectA = Synagal.synagalObj("models/plane_modern", 100, 0, -80, nil, math.pi*0.125, nil, 25, true)
local objectB = Synagal.synagalObj("models/plane_modern", 100, 0, 80, nil, math.pi*-0.125, nil, 25, true)

Synagal.setvZ(objectA, 10)
Synagal.setvZ(objectB, -10)

Synagal.setrotY(objectA, 180)

while true do -- Game logic goes into this loop
    sleep(0.05)
    Synagal.cycle()
    Synagal.render()
end
```
