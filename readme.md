
To create a new object, use syngalObj
syngalObj("models/pineapple", 100, 0, 80, nil,  math.pi*0.125, nil, 10)


1. Model path
   
2-4. XYZ
   
5-7. Rotation XYZ

8. Mass


Objects are in variable objects

Index 1 handles X
Index 2 handles Y
Index 3 handles Z

Index 4 handles rotation X
Index 5 handles rotation Y
Index 6 handles rotation Z

Index 13 handles velocity X
Index 14 handles velocity Y
Index 15 handles velocity Z

Index 16 handles mass

Create an impulse using spherical rotation with x = r, y = theta (pitch), z = phi (yaw) using impulse(vector,object)

To create an impulse, for example r=10, theta=30, phi=60, object 1, do

local spherical = vector.new(10,30,60)
impulse(spherical,1)
