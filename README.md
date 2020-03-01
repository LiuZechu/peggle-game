# CS3217 Problem Set 4

**Name:** Liu Zechu

**Matric No:** A0188295L

## Tips
1. CS3217's docs is at https://cs3217.netlify.com. Do visit the docs often, as
   it contains all things relevant to CS3217.
2. A Swiftlint configuration file is provided for you. It is recommended for you
   to use Swiftlint and follow this configuration. We opted in all rules and
   then slowly removed some rules we found unwieldy; as such, if you discover
   any rule that you think should be added/removed, do notify the teaching staff
   and we will consider changing it!

   In addition, keep in mind that, ultimately, this tool is only a guideline;
   some exceptions may be made as long as code quality is not compromised.
3. Do not burn out. Have fun!

## Dev Guide
You may put your dev guide either in this section, or in a new file entirely.
You are encouraged to include diagrams where appropriate in order to enhance
your guide.

Please refer to the following diagram for an overview of the architecture of this application. (solid arrows indicate that the source component holds a reference to and utilises the functionalities provided by the destination component, whereas a dotted arrow indicate that the source component uses the destination component as a function argument)

![image of architecture diagram](https://github.com/cs3217-1920/2020-ps4-LiuZechu/blob/master/overall-architecture.png)


### Model Component

This component is used by both the Level Designer and Game Engine.

Each level is represented by a `GameBoard` which has the name of the level and a set of `Peg`s. Each `Peg` records its colour, location on the screen, radius, shape and angle of rotation. `LevelDesignerViewController` accesses the Model component through `LevelDesignerModelManager`, which is the concrete class that conforms to the `LevelDesignerModel` protocol. `LevelDesignerModelManager` holds a reference to the current game board displayed on the screen, and it has methods that get information from or manipulate this `GameBoard`. `LevelDesignerModel` serves as the interface between other parts in the level designer feature and the Model component. How the game engine utilises the Model component will be explained below under Game Engine component.

- `Peg` and `CannonBall`:
Each of these objects holds a reference to a `PhysicsBody`, a representation of their physical self in the world of phyiscs. `Peg` also has an `isHit` boolean flag to indicate whether it has been collided by the ball. When an external client, say the `Renderer`, requests the location of one of these objects, it does so through `PeggleGameEngine`, which will then obtain this information by accessing the location of the corresponding `PhysicsBody`. When a `Peg` or a `CannonBall` is deleted, its corresponding `PhysicsBody` is deleted from the physics engine as well.

- `Bucket`:
This represents the moving bucket on the screen. The game engine (explained below) holds a reference to a `Bucket` and moves this bucket on screen while updating its location through the game loop.

### Storage Component

The Storage component is in charge of persisting data to local storage. `StorageManager` is the implementation of `Storage` protocol. It has methods that take in a model and save it to memory, or fetch data to `LevelDesignerLogic`. Data persistence uses Core Data.

### Level Designer Logic Component

The Level Designer Logic component holds references to a `LevelDesignerModel` object and a `Storage` object. It has methods that call functionalities of `LevelDesignerModel` and `Storage`, or pass `LevelDesignerModel` to `Storage` for persistence. `LevelDesignerLogicManager` is the concrete class for `LevelDesignerLogic` protocol. `LevelDesignerLogic` serves as the interface between domain logic and presentation logic of the level designer feature. It is the only entry point for `LevelDesignerViewController` to access the business logic of the application.

### Level Designer View Component
`LevelDesignerViewController` holds a reference to `LevelDesignerLogic`, through which `LevelDesignerViewController` gets information from and updates `LevelDesignerModel`. `LevelDesignerViewController` is tightly linked to the View, and it controls what the user sees and also gets information from user actions. `LevelDesignerViewController` acts as an intermediary in the sense that when it gets a user action, such as a touch or drag, it updates both View and Model (through `LevelDesignerLogic`), such that neither View or Model knows about the existence of each other.

An example of what happens when the user drags a peg around, illustrated using a sequence diagram.

![image of sequence diagram for dragging a peg](https://github.com/cs3217-1920/2020-ps2-LiuZechu/blob/master/Peggle%20sequence%20diagram.png)


### Physics Engine component

- `PhysicsEngine`:
This class is in charge of simulating the rules of physics governing interaction of physics bodies. It contains a set of movable `PhysicsBody` and a set of immovable `PhysicsBody`. `PhysicsEngine` has methods that detect and resolve collisions between two movable bodies or between a movable body and an immovable one. It also handles collisions with "walls" (boundaries of the screen). It can handle circle-circle collisions as well as circle-triangle collisions. Its `update()` function updates the positions and velocities of all `PhysicsBody`s residing inside this simulation in the next moment in time. All launched movable bodies in this world is subject to a constant downward gravitational acceleration. 

- `PhysicsBody` :
This is the representation of an object interacting inside the world of `PhysicsEngine`.  Each body can either be movable or immovable, circular or triangular, and it has other attributes such as mass, velocity, position, radius, elasticity (an elasticity of 1 means that the body doesn't lose kinetic energy upon collision; 0 means the object loses all kinatic energy upon collision) and so on. It also has an array of forces and a computed property of `resultantForce`. At each instant of time, the `update()` method of the body is called by the `update()` method of the governing physics engine. The former will update the position and velocity of the body based on the resultant force.

### Game Engine component

- `PeggleGameEngine`:
This class holds references to a `PhysicsEngine`, a `GameBoard`, a `CannonBall`, a `Bucket` and a `Renderer`. `PeggleGameEngine` is the sole entry point for `GameViewControl` to access the domain logic. The `GameBoard`, `Bucket` and  `CannonBall` represent models of the game. The game loop resides in this game engine, where `CADisplayLink` is used to for the game loop. At every frame, the physics engine is updated, and the renderer renders the views in the next moment on the screen.

### Game View and Renderer component
- `Renderer`:
This protocol only has one method, `render()`, which updates the view every time it is called by the game loop.

- `GameViewController`:
This class conforms to `Renderer` protocol. It is also in charge of receiving user actions, such as a tap on the screen, and calling relevant functions from `PeggleGameEngine`. It also handles other user interaction things such as alert windows to tell the user how to start the game and restart the game after all the pegs are cleared.

In summary, the game play part of this application is divided into three components: physics engine, game engine and UI/renderer. The physics engine knows about no one other than its own world of physics. The game engine only knows about its models and the physics engine. The game loop also calls `renderer()` in the renderer through the `Renderer` protocol. The renderer only knows about the game engine but not the physics engine.

Please refer to the following simplified sequence diagram for what happens at every frame of the game loop, when `update()` is called on `PeggleGameEngine`.

![image of architecture diagram](https://github.com/cs3217-1920/2020-ps3-LiuZechu/blob/master/sequence_diagram.png)

### How the View Controllers interact
There are four View Controllers in this application, namely, `LevelDesignerViewController`, `LevelTableViewController`, `MenuScreenViewController`, and `GameViewController`. They interact with each other through segues and delegates.



## Rules of the Game
Please write the rules of your game here. This section should include the
following sub-sections. You can keep the heading format here, and you can add
more headings to explain the rules of your game in a structured manner.
Alternatively, you can rewrite this section in your own style. You may also
write this section in a new file entirely, if you wish.

### Cannon Direction
Please explain how the player moves the cannon.

To launch the ball, drag your finger across the background to rotate the cannon. Upon releasing the finger, the ball will be launched in the direction of the cannon.

### Win and Lose Conditions
Please explain how the player wins/loses the game.

The player is provided with 10 balls in total. To win the game, the player has to clear all orange pegs on the screen before the 10 balls are used up. If the player does not manage to clear all the orange pegs within 10 balls, they lose the game. Note that when the ball enters the bucket, an extra ball will be awarded. This can be seen from the number of balls left at the top-right corner not decrementing after the ball falls out of bounds (normally the number will decrement by 1). 

## Level Designer Additional Features

### Peg Rotation
Please explain how the player rotates the triangular pegs.
To rotate a triangular peg, tap on the peg. Two sliders will appear in the middle of the screen. Slide the bar with a clockwise circular arrow icon to rotate the peg being tapped. To make the sliders disappear, tap the peg again.

### Peg Resizing
Please explain how the player resizes the pegs.
To resize a peg, tap on the peg. Two sliders will appear in the middle of the screen for triangular pegs. One slider will appear for a circular peg. Slide the bar with a double outward arrows icon to resize the peg being tapped. To make the sliders disappear, tap the peg again.

## Bells and Whistles
Please write all of the additional features that you have implemented so that
your grader can award you credit.

## Tests
If you decide to write how you are going to do your tests instead of writing
actual tests, please write in this section. If you decide to write all of your
tests in code, please delete this section.

## Written Answers

### Reflecting on your Design
> Now that you have integrated the previous parts, comment on your architecture
> in problem sets 2 and 3. Here are some guiding questions:
> - do you think you have designed your code in the previous problem sets well
>   enough?
> - is there any technical debt that you need to clean in this problem set?
> - if you were to redo the entire application, is there anything you would
>   have done differently?

Your answer here
