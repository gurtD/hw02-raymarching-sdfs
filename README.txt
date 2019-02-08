Garrett Darley: gdarley
https://gurtd.github.io/hw02-raymarching-sdfs/
Created Scene of a cage with two spheres moving. The cage is made
using a union of three rectangular prisms and subtraction on a cube.
The spheres use a smooth blend to somewhat act like metaballs when 
they move past each other. The spheres are animated to move in the x 
and y direction using a variable controlled by the gui. The color of
the scene is also animated by a gui controlled variable. The two 
tool box functions I used were sin and cos for the movement and color animation.
The shading is done using a normal calucation based of the SDF of the scene.
The normal is then used to calculate the shadow like a normal lambert
shader. There is an issue with the bounding boxes that causes the 
visual artifact on the sphere but with out it the shading is normal. 
It can also be fixed by not using sphere marching and using a constant
distance to increment the ray. The speed at which the spheres move 
and at which the colors cycle is controlled by the gui.
All references are those included in the slides on SDFs