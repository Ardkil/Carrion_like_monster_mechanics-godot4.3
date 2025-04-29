# Carrion_like_monster_mechanics-godot4.3
source code of a 48 hour gamejam game where i remade controls like carrion, you can check it all out, or just the monster file in order to learn how it is done in code, I will also be explaining the logic behind it here

For the body part, each body is connected by super aggressive springs in the order worm, and then are connected to the middle of the worm via a less aggressive spring, this ensures that the creature will be round if possible, but can also fit into small spaces like a worm, moreover, the worm is updated so that each body part is connected to the closest body part so that it won't be stuck in a circular motion

for it to look like a whole creature, each body part draws a vein to the closest to them initially, and a random body part later

then the body part closest to the mouse is selected as the leader (the one the eye follows), the leader casts a ray towards the mouse, the body parts that can see the target will try to move towards it if pressing the left mouse. the bodies that can't see will follow the others due to the springs

Each body part sends out rays in a circle in order to get points where they can send tentacles, then a random point is chosen (it might be better to rate points depending on their distance to the mouse, but it felt good enough to pick randomly so I didn't dabble on it). If the distance between the body part and the tentacle exceeds a certain value, this process repeats. The tentacles are drawn with a line that has a shader adds sin wave to it
If you are idle, all body parts are pulled towards the tentacles they have shot

for the pick up part, within a certain range, a rope like line created with verlet integration is drawn to a pickupable object, then the object is added as our item and is moved towards the mouse within the range
