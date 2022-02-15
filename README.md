# My first 3D game
![Tennis game](/images/game.png)

&emsp;&emsp; Video games have become more sophisticated and demanding, by implementing high-level systems for intelligent agents, simulating physics, rendering graphics. At the same time, exists and are being developed software programs with various features and tools that shorten the required working time needed to create virtual worlds as accurately as possible and simulations of some parts of reality.</br>
&emsp;&emsp; I created a 3D video game of tennis with its specific rules and events that can actually happen, along with the physical elements that make up the game framework. By finishing this project for the bachelor’s thesis, I tried to prove to myself that I am able to build my own 3D game, which I could only imagine until the moment I started working on the project.

------------------------------------------------------------------------------------------------------------------------------------------
# Technologies used

&emsp;&emsp; To develop the game of tennis I used Blender to import, edit, create 3D models and to animate the character of a tennis player model. I exported these to the Godot game engine, where I arranged with them the 3D scene and implicitly the game objects. There I set the interaction between the elements and programmed the logic of the game by attaching the necessary scripts to the specific nodes of some objects in the game.

## Digital 3D graphics - [Blender](https://www.blender.org/) (version 2.8)

Creation of 3D graphics is composed of 3 basic steps:
- Modeling
- Setting up the scene
- Rendering

![Blender tennis court scene objects](/images/blender_tennis_court.png)
  #### &emsp;&emsp; Tennis court 
1. Creating tennis court in Blender
2. Dividing elements of the court into separate objects
3. Exporting from Blender (plugin: [godot-blender-exporter](https://github.com/godotengine/godot-blender-exporter))

#### &emsp;&emsp; Tennis ball
To represent the tennis ball, it is enough to create a sphere on which a material that resembles the surface of the ball from reality or only applying the yellow color. In my case, there are two materials on the surface of the ball, yellow and white, the mesh of the sphere having a little depth along white line.

#### &emsp;&emsp; Racket
The racket is a 3D model that has a true representation from reality, having a very complex mesh structure and being composed of several surfaces with different materials. It isn't necessary for the racket to be detailed, as it will not be implemented that the mechanics of the ball will be affected by the shape of the rocket and the laws of physics involved under the action of a blow. This is very difficult to be achieved even for great developers.

![Blender character and animation](/images/blender_animation.png)
#### &emsp;&emsp; Character and animations
Tennis players can be represented by a character with a human body with a less detailed polygonal network. Character animation is done by creating an armature using bone-based animation. Through each bone is determined the transformation of the part of the body under which it is found. The main goal is to shape the character hierarchically to simulate rest, gait, running, serving movements, forehand and backhand.Setting interpolation points with keyframing method, placed at different timeframes determines the animation. 

To make the animation as accurate as possible, videos can be integrated into Blender to reference the desired copy motion. The video is transposed in the form of a plan as close as possible to the character or to section him and is dimensioned so that the character in the video is approximately the same size as the character to animate.

  ## Game engine - [Godot](https://godotengine.org/) (version 3.2)
   * integrates APIs, SDKs, libraries, and libraries (provides reusable components)
   * graphical interface (GUI)
   * rendering engine (Direct3D, OpenGL, Vulkan)
   * physics engine (real time)
   * audio, networking, scripting, built-in debugger, etc.

&emsp;&emsp; This are the major steps realised for the construction of the game, by combining the necessary knowledge with those acquired in college in various subjects and used especially to implement the code for game logic:
  1. Importing 3D models for the game objects
  2. Configuring the playground scene
  3. Setting collisions and physics for each object
  4. Programming the game menu executable
  5. Implementing character for tennis players </br>
   \- using trees for animating it </br>
   \- programming animation functions </br>
   \- programming racket control and movement </br>
  6. Implementing player controlled by user
  7. Implementing non-player character and his intelligent agent  
  8. Implementing the game logic

----------------------------------------------------------------------------------------------------------------------------------------
# Implementation of game scripts
GDScript is a dynamic programming language with a syntax similar to Python and is based on class inheritance. *Object* is the base class for almost all programmable structures. Most of the classes in Godot are inherited directly or indirectly from it, forming the structure of a class tree. The legacy is simple due to the fact that a new class can expand and must be a single class. So each script file will represent a class.

![Playground nodes](/images/playground_hierarchy.png)

In Godot each scene is a collection of nodes with a tree-shaped structure, with a base node (root) and the other nodes or sub-scenes to which it is subordinated.

#### &emsp;&emsp; [Game executable](/Scripts/Game.gd)
![Game hierarchy](/images/game_hierarchy.png)

When application starts and base node becomes active, function *_enter_tree()* hides 2D overlayed elements and stagnates progress of 3D game scene. By pressing the start button, *_on_Button_pressed()* hides the cursor and sets mouse capturing in order to be used in the gameplay. The menu will be freed by deleting its node from the scene tree, then the resolution of the game windo will be increased to full screen. At the end of the function previous hidden 2D elements will be displayed on the screen together with the starting gameplay scene. Otherwise, at pressing the exit button signaling function *_on_Button2_pressed()* will close the menu including game application.
![Menu](/images/start_menu_screen.png)

#### &emsp;&emsp; [Camera](/Scripts/Camera.gd)
The camera for viewing during the game is fixed and allows user to see all the elements of the game. </br>
![Gameplay view](/images/in_game.png)

I implemented another camera for a free viewing system. The scene can be seen freely by pressing the "Esc" key which frozes the gameplay. By adding a *Spatial* node and a child node of the same type under which a *Camera* node type is attached, I created a kind of gimbal with the help of which I implemented a free view mode, using transformations functions on the root node to which I attached the script, the child node of it or the leaf node *Camera*. Free view involves free movement within the game scene using the "w", "a", "s", "d" keys, arrows and mouse. Pressing the "Esc" key will change the camera during play with the free viewing one or vice versa. In this way it can be seen the place where the ball touches the ground due to the fact that I implemented that the impact of the ball with the ground creates a texture similar to a trace. </br>
![Free camera](/images/free_camera.png)
- gimbal stabilizer
- role to set the game to pause to view the moment
- translation of the cardan shaft through the arena depending on the direction of the room frame
- it raises or lowers the cardan shaft
- implementing camera rotation and zooming in with the mouse </br>
![Free camera view](/images/freeze_free_camera_view.png)

#### &emsp;&emsp; [Tennis Ball](/Scripts/Ball.gd)
\- function *_process(delta)* constantly verifies if ball needs to be hold by a player </br>
\- function *pick_up_by(character: KinematicBody)* designates the player that holds the ball, which is given through parameter </br>
\- function *drop()* disables control of the ball from a player hand </br>

#### &emsp;&emsp; [Tennis player character](/Scripts/Character.gd)
\- constants for motion, moving states and swing </br>
\- variables for players movement, hitting the ball, serving </br>
\- function *_process(delta)* allows calling of functions for moving and serving animations to be played </br>
\- function *_physics_process(delta)* keeps the racket attached to character and in case of serving swing it angles the racket to make possible collision with ball </br>
\- function *animate_movement()* animates the movement of the players </br>
\- function *animate_serve()* animates the movement of the players serve and makes a player drop the ball </br>
\- function *animate_swing(var type, var seek_position, var time_scale)* animates the swing of the players, setting through parameters if it is backhand or forehand and speed of the swing movement </br>

#### &emsp;&emsp; [User player character](/Scripts/PC.gd)
\- function *_process(delta)* calls control functions which will change the global variables of character based on the input actions of user </br>
\- function *move(d: float)* determines the change of the value of the movement and implicitly of the animation, then applies the movement depending on the direction and the resulting speed</br>
\- function *aim(var d: float)* moves the visual target for the aiming and sets the corresponding variable from the inherited class </br>
\- function *serve()* the function that allows the service to be executed by switching a variable, and then start the animation in the inherited class, only if a designated input button is pressed and a variable indicates that it can be served </br>
\- function *swing(var speed: float)* is for loading the shot, sets the variable strength of the rocket swing and visually loads a progress bar depending on how long the designated key is held down </br>
Functions are having passed the *delta* parameter to set a smooth control of the player regardless of the amount of frames per second. Also, the direction of movement and the direction of aiming are normalized to ensure a constant translation. </br>
![Serving](/images/serving.png)

#### &emsp;&emsp; [Racket](/Scripts/Racket.gd)
It implements funtions that are called by the signals triggered at the entrance of an object in one of the designated areas. The areas where added to character nodes to be trigged when the ball reaches near player in order to set the swing or serve when player tries to hit the ball.
\- function *_on_Area_body_entered(body)* is called when the ball is in area for serving and executes the hitting of the ball directing it towards the aim target </br>
\- function *_on_LeftArea_body_entered(body)* executes the backhand swing if ball entered the area, directing the ball towards the aim target </br>
\- function *_on_RightArea_body_entered(body)* executes the forehand swing if ball entered the area, directing the ball towards the aim target </br>
\- function *_on_Area_body_exited(body)* sets repositioning of the racket after a serve or a swing </br>
\- function *sound_distance(var body)* returns the distance between the camera position and the ball to adjust the sound intensity according to the distance from which the impact is seen </br>
![Racket node](/images/racket_node.png)

#### &emsp;&emsp; [Non-player character](/Scripts/NPC.gd)
As with user player character, this script for non-player character(NPC) uses *_process(delta)* which calls functions for movement, aiming, swinging the racket or serving. So:
\- function *move_aim_swing(d: float)* performs the movement, aiming or hitting the ball depending on the state of the gameplay (cases during serving, cases after serving and which of the players is the server and which is the receiver) </br>
\- function *serve()* is called if NPC must serve, but with a delay to not rush gameplay </br>
\- function *aim_for_serve()* is called if it is during the serving move, setting the target according to the position of where NPC needs to serve </br>
\- function *aim_and_swing()* sets the target according to the opponent's position and then the swing power according to the distance of the target </br>
Here is implemented an intelligent agent who perceives the "environment" based on the state of play and will act automatically depending on the movement and position of the ball in order to intercept it and then depending on the position of the opponent on the field it aims and hits the ball accordingly. </br>
![Intelligent agent](/images/intelligent_agent.png)


#### &emsp;&emsp; [Game logic](/Scripts/World.gd)
The script of the root node for gameplay has the set of states that determines the rules of tennis to be imposed. Global variables retain the player to serve, the area to serve, the number of services available of a player. 
\- function *_ready()*, when a gameplay starts, picks a random player to start the serve and calls the function to start a serve </br>
\- function *_process(delta)*, when a player must serve, verifies the possitioning and sets variables that allows serving or not </br>
\- function *_input(event)*, when an input is detected, allows the setted keys to pause/unpause the game or reset players position if players aren't diputing a point </br>
\- function *startNewServe()* sets off a new serve by starting a timer for repositioning of players at serving </br>
\- function *_on_Timer_timeout()* repositions the players for serving </br>
\- function *_on_Ball_body_entered(body)* implements the change of states, which uses the signal when the ball comes in contact with an object of type *PhysicsBody*; depending on the current state and condition, the necessary changes will be applied </br>
\- function *is_ball_in_service_court()* returns true if the ball is in court to be served in </br>
\- function *is_ball_in_player_court(player_name: String)* returns true if the ball is in court of the player given to parameter </br>
\- function *receiver()* returns the name of the player that is the current receiver </br>

The set of states during a point of the tennis game that determines the rules to be imposed:
```
# Possible states during the service:
	"S0 - One of the players must serve.", #-> initial state
	"S1 - Ball has been served.",
	"S2 - Lost service. A new sevice will start.", #-> final state
	"S3 - Ball touched the court to serve in.",
	"S4 - Ball touched net after service hit. (Let)",
	"S5 - Server wins the point.", #-> final state
	"S6 - Ball touched the court to serve in after touching the net. Repeating service.", #-> final state
# After serving the ball the following states can be reached:
	"S7 - Receiver hits the ball.",
	"S8 - Ball touched server's court.",
	"S9 - Ball touches net being hit by receiver.",
	"S10 - Server hits the ball.",
	"S11 - Receiver wins the point.", #-> final state
	"S12 - Ball touched receiver's court.",
	"S13 - Ball touches net being hit by server."
```

The figure below shows the finite machine made for the states in the game in which the input alphabet has the following set of symbols assigned to the objects with which the ball comes in contact:
```
a = server's racket
b = receiver's racket
c = server's court
d = receiver's court
e = court to serve in
f = net
g = serving player
h = receiving player
Σ\M = all other possible objects minus/other than those from a subset M of set {a, b, c, d, e, f, g, h}
```
![Game states](/images/tennis_logic_states.png)

#### &emsp;&emsp; [Score](/Scripts/Score.gd)
The script extends a label class that displays the score on the screen with function *_process(delta)*. In order to take into account the score, I created two structure type variables, each for PC and NPC, in which the data about points, games and sets won by the respective player are retained. Function *add_point_to(player: String)* adds point to player given as to paramater and calculates the score depending of the points, games and sets of tennis match. 

 ---------------------------------------------------------------------------------------------------------------------------------------
