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

`MenuScreenViewController` is the entry point of the application. Clicking on `Design a Level` will segue into `LevelDesignerViewController`. Clicking on `Select a Level` will segue into `LevelTableViewController` while passing the latter an instance of `LevelDesignerLogic`, through which `LevelTableViewController` can access the storage component and load all the saved levels. After choosing a level, the view will segue into `GameViewController`, which will then access the loaded game board through a delegate.

`LevelDesignerViewController` deals with the view for designing a level. Clicking on `LOAD` button will segue into `LevelTableViewController`. After choosing a level, it will segue back into `LevelDesignerViewController`, display the loaded game board on screen through a delegate. When clicking on `START` button, the application will segue into `GameViewController`.

`GameViewController` deals with the view for the main game feature. Clicking on `BACK` button will segue back to `MenuScreenViewController`.


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

### Stuck Condition
If the ball gets trapped between pegs and will never fall out of bounds, it will gradually lose energy due to inelastic collisions and slow down. After being trapped for a sufficiently long time, the ball and hit pegs will disappear and another ball is replenished. This is checked by counting the number of hits of the ball. Once the hit count exceeds `10 * totalNumberOfPegs`, the ball is considered stuck.

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

1. Sound effects: 
    * When the game starts, a background music will start playing. This music continues throughout the game, and will stop once the user returns to the main menu (either through the BACK button or when the game ends)
    * When the ball hits a peg, a bouncing sound effect will play.
    * When the user wins or loses, a cheering sound effect will play. This sound is played even when the user loses so as to cheer them up :)
    
2. Windy Mode:
    * When starting the game, the user will be prompted by a popup window to choose a powerup or a mode of the game. There are two extra modes, namely, `Windy Mode` and `CHAOS MODE` (which will be explained below). 
    * For Windy Mode, each time the ball is launched from the cannon, there will be a wind of random magnitude, either to the left or to the right. The ball will move as if there is a (strong) wind, in addition to gravity. Powerups are not activated in this mode.

3. Chaos Mode:
    * When the user chooses `CHAOS MODE`, the game will enter the Chaos Mode. 
    * In this mode, a circular peg of any colour will turn red once it is hit.
    * Once a peg turns red, it will become a free-moving body, launched at a random speed and direction.
    * The delocalised pegs will act as balls, hitting other pegs and turning them into free-moving bodies. 
    * When a circular peg is delocalised, the peg is launched at a random speed and direction.
    * Triangular pegs will not delocalise or turn red when hit. They will stay stationary, but will light up.
    * Once all the free-moving pegs and the ball exit the screen, any remaining lit up pegs on the screen will fade out, and the cannon will be ready to launch again (same as the original game)
    * The win/lose conditions are the same as original.
    * To better experience this mode, please try it on the Preloaded Level named **Third Level**.
    
## Tests
If you decide to write how you are going to do your tests instead of writing
actual tests, please write in this section. If you decide to write all of your
tests in code, please delete this section.

(Please refer to code for unit tests.)

### Initial Menu tests
1. Upon launching the app
    * initial screen
        * upon opening the app, a screen with a blue background should appear. There should be two buttons named `Design a Level` and `Select a Level`.
        * tapping/dragging/touching anywhere other than the two buttons on the screen multiple times, nothing should happen.
    * Design a Level button
        * when tapped, the app should display the screen for Level Designer
    * Select a Level button
        * when tapped, the app should display a table of levels saved in storage. Three preloaded levels named `First Level`,  `Second Level`,  and `Third Level` should appear in the table. Tapping any one of them should cause the app to display the game playing screen, with pegs displayed on the screen.
        * when tapped, the app should display a table of levels saved in storage. Sliding the table downwards should dismiss the table.

2. When returning back to main menu
    * When the user returns to this main menu from either Level Designer or the Game, the above tests should still pass.

### Level Designer tests
1. Test palette
      * blue, orange and green, circular and triangular buttons
        * when tapped, it should be fully bright/highlighted, whereas the other buttons should become faint. If it's already highlighted before tapping, nothing changes.
      * delete button
        * when tapped, it should be fully bright/highlighted, whereas the other buttons should become faint. If it's already highlighted before tapping, nothing changes. 
      * LOAD button
        * when tapped, a table should pop up. The table has all the previously-saved level names. Tapping on a level name should load its peg arrangement onto the screen. (refer to 3. Test persistence for more). Swiping down should close this table
      * SAVE button
        * when tapped, a popup window with the title `Enter level name` should appear, with a text field. If it's the first save after opening the app, there will be two buttons, `Cancel` and `New Level` respectively. If the level is a Preloaded Level, there will also be two buttons, `Cancel` and `New Level` respectively, since a preloaded level cannot be overwritten. Otherwise, there will be an additional button `Edit Current Level`. After entering a level name in the text field and tapping one of the two saving buttons, the current game board will be persisted to storage. Tapping `Cancel` returns to the game board without saving. (refer to 3. Test persistence for more)
      * RESET button
        * when tapped, a popup alert window should appear, with the title `Reset game board`. Clicking `Reset` will dismiss the window, and all the pegs currently on the game board will be cleared. Clicking `Cancel` will only dismiss the window, without any changes to the pegs on the screen. Note that the clearing action is not saved unless SAVE button is used afterwards.
      * START button 
        * when tapped, the screen should display the game area, with a pop-up window that allows the user to choose a powerup. All the pegs on the screen of Level Designer will appear in the same arrangement on the game area. Note that the level is not saved if the user did not press SAVE. (refer to tests on the game for more)
      * BACK button
        * when tapped, a pop-up window should appear. Tapping `Cancel` dismisses the window. Tapping `Yes` should return to the main menu.
      * level name text label
        * after saving or loading a level, the name of the level (whose pegs are currently displayed on the background) will be displayed near the bottom of the palette
  
2. Test background
    * when a peg button is highlighted
        * tapping anywhere on the background should cause a peg corresponding to the button to appear, centred at the tap location 
        * tapping on anywhere outside the blue background shouldn't cause a blue peg to appear
        * tapping on an existing peg, or within a short distance outside a peg's border (i.e. its radius' length), should not result in the creation of a peg image, as no two pegs can overlap
    * when delete button is highlighted
        * tapping any peg on the background should make the peg disappear
        * tapping anywhere else shouldn't have any effect
    * at any point of time when the blue background is fully visible
        * long pressing a peg of any color should cause it to disappear
        * dragging a peg of any color and shape should cause the peg image to move with the fingertip. When the drag is released, the peg should stay where it is if it doesn't overlap with any other peg or if it's within the blue background. Otherwise, it will return back to its original location where the drag started (drag it on top of another peg or out of the blue background to test it out).
    * when there is a circular peg on the screen
        * tapping the peg, a slider should appear in the middle of the screen. Sliding it to the right will enlarge the peg, whereas sliding it to the left will shrink the peg. Keep sliding it left and right to see the peg enlarging and shrinking. When the user stops sliding, the peg should stay that size.
        * when there is a slider on the screen, tapping the peg will cause the slider to disappear.
    * when there is a triangular peg on the screen
        * tapping the peg, two sliders should appear in the middle of the screen. Sliding the one with double outward arrows to the right will enlarge the peg, whereas sliding it to the left will shrink the peg. Keep sliding it left and right to see the peg enlarging and shrinking. When the user stops sliding, the peg should stay that size.
        * Sliding the one with a clockwise circular arrow will rotate the peg clockwise when slided to the right, counterclockwise when slided to the left. 
        * when there is a slider/sliders on the screen, tapping the peg will cause the slider(s) to disappear.
        * sliding the slider of a peg should not affect any other peg on the screen
     * when tapping an enlarged/rotated peg
        * the slider level should be pre-set to indicate the current size/angle of the peg, relative to the min/max value.
3. Test persistence
    * Put some pegs on the screen, then tap SAVE, and name it `some level`. Tap `New Level`. The bottom label on the palette should change the name to  `some level`.
    * Then, tap LOAD, a level named `some level` should appear in the table view, together with preloaded levels called `First Level`, `Second Level`, and `Third Level`. Dismiss the table by swiping it down.
    * Then, modify the game board a bit, and tap SAVE again. Change the name to `first level plus`. This time, tap `Edit Current Level`. Then tap LOAD. The table should show one entry named `first level plus`, and the previous `first level` is gone. This is because the same level has been modified.
    * Now, put a few more pegs and drag them around. Tap SAVE. Name it `2nd level` and tap `New Level`. Then tap LOAD. Both `first level plus` (from the previous step) and `2nd level` should appear in the table. This is because a new level called `2nd level` has been created. Tapping on `first level plus` should cause the previous peg arrangement to appear on the screen, with the level name at the bottom of the palette changed accordingly.
    * Create a few more levels and use the LOAD button and the popup table menu to switch between different levels.
    * Tap SAVE again, and give a name that already exists, or is blank. Tapping either of the two saving options. An alert window should pop up, reminding the user that this name isn't valid. Tapping the only button on the window should return back to the naming window just now. If you tap `Cancel`, this game board won't be saved.
4. Test preloaded levels
    * Launch the app on any iPad device. Go to `Design a Level` and tap LOAD. A table with `First Level`, `Second Level`, `Third Level` should appear. Tap each of these levels, a blue background displaying predetermined peg arrangment should appear. Take a screen shot of this arrangement.
    * Now, launch the app on another iPad device of a different screen size. Repeat the above steps to display the same preloaded level, and compare with the screenshot taken just now. The peg arrangement as well as peg sizes should adjust based on the screen size, so that the relative distance of all pegs to the screen boundaries should remain the same, as if the screenshot "looks the same" as the device screen, but just bigger/smaller.
    * When the screen displays a preloaded level, modify it, and tap SAVE. A pop-up window with `New Level` option should appear, but with `Edit Current Level` option. Tapping `New Level` without changing the name, the user will be prompted to rename. Changing the name and tapping `New Level` will save the current arrangement as another level.
    * After the above step is done, tap LOAD. The original preloaded level should still be there, and opening it should show that it is not modified (preloaded levels cannot be overwritten). Opening the level corresponding to the modified level should show the arrangement of pegs in the previous step.


### Game tests
1. Test initial screen
    * pop-up window
        * when the game is just launched either from the main menu or from Level Designer, a popup window titled `Start Game` should immediately appear and provide instructions on how to launch the ball. There will be two options, `Space Blast` and `Spooky Ball`. Tapping one of them will start the game, and set the green pegs' powerup to the selected one (more below).
2. Test gameplay:
(Before testing, go to Level Designer to create a level with a few blue, orange and green pegs of different shapes, sizes and angles, and start the game to test)
    * downward cannon
        * tapping anywhere on the screen repeatedly (except the BACK button), nothing should happen 
        * when the user has not dragged on the background, the cannon should stay stationary, slightly below the upper boundary of the screen, centred horizontally regardless of screen sizes, pointing downwards.
        * when dragging across the screen, the cannon should rotate according to movement of the finger. Upon releasing the finger, a grey ball should be launched in that direction.
        * when dragging the cannon to above the horizontal line on which the cannon is situated, the cannon should stop rotating and point horizontally towards left/right (it should not point upwards). When the finger leaves the screen, a ball will be launched in the direction of the cannon.
    * moving grey ball
        * when the grey ball is moving, it should accelerate if it's travelling downwards, and decelerate if it's travelling upwards. When moving across the screen, it should follow a parabolic path.
        * direct the grey ball to hit a peg of any colour. The blue peg should light up and remain lit up as long as the ball is still visible on the background (i.e. not out of lower boundary). The grey ball should bounce away according to the laws of physics, according to the different shapes, sizes and angles of the pegs.
        * direct the grey ball to hit one of the side walls. The ball should get reflected off the wall according to physics.
        * when the grey ball is moving, tap or press and hold or drag any where on the screen (except the home button and BACK button) multiple times, nothing should happen and the ball will continue moving according to physics.
        * when the grey ball is moving, exit the app (but don't remove it from the background activities), and then re-enter the app. The app should not crash. The ball should continue moving with the same rules of physics and same gravitational effects. The ball should continue traveling even when the app is in the background.
        * when the grey ball is moving, the bucket should move horizontallly leftwards/rightwards at a constant speed, changing directions when hitting the side walls.
    * grey ball out of bounds
        * when the grey ball falls to a position lower than the lower boundary of the screen, i.e. the entire grey ball is not visible, all the lit up pegs will starting fading out at the same time.
        * when all the lit up pegs have disappeared completely, but there are still pegs remaining on screen, the bucket should stop moving, and the cannon should point at the last launch position. Rotating the cannon and releasing the finger should launch another grey ball. The bucket should resume moving.
        * when the ball is out of bounds, tap anywhere on the screen multiple times, nothing should happen.
    * BACK button
        * at any time of the game, tapping the BACK button at top-left corner should cause a popup window to appear. Tapping `Cancel` should dismiss the window and continue with the game. Tapping `Yes` should quit the game and return to the main menu. When the window is on the screen, the game should still continue in the background.
        * after quitting the game, tap `Select a Level` and choose the same level again to start the game. The game should start as a new game, and the previous progress should not be saved.

3. Test bucket:
    * when the ball is moving, the bucket should be moving too.
    * when the bucket is moving
        * only the top rim of the bucket should be visible (similar to the original Peggle)
        * when the grey ball goes inside the bucket through the center opening of the bucket, a popup window titled `Good Job!` should appear, telling the user a new ball is rewarded. This can be seen from the observation that the `Balls left` on top right hand corner does not decrement after this round.
        * when the grey ball falls anywhere outside the bucket, or barely touches the side of the bucket, the popup window should not appear and no extra ball should be rewarded. This can be seen from that the  `Balls left` on top right hand corner decrements by 1 after this round.
        * when the bucket hits a side wall, it should change direction but still moves with constant speed.

4. Test trapped ball:
    * Go to Level Designer and designer a level with many pegs to trap the ball, such that the grey ball will never reach the bottom. Then tap START. Launch the ball, and it will be trapped by those pegs. The ball will slowly lose energy and reduce speed until it is almost stationary. After a while (a few minutes), the game will detect that an unreasonable amount of collisions have happened, and all the hit pegs together with the ball will be removed from the screen. A new round will start.

5. Test powerups:
(Before testing, go to Level Designer to create a level with a few blue, orange and green pegs of different shapes, sizes and angles; Also, arrange some green pegs around other pegs, and some green pegs far from the rest)
    * when Space Blast is chosen at the start of the game
        * when the grey ball hits a green peg of any shape, size and angle, the green peg will light up. All pegs near the hit green peg will light up too. If another green peg is lit up, pegs around this green peg should light up too.
        * when the grey ball hits a green peg, pegs that are far from this peg should not light up.
        * when the ball falls out of screen, all the lit up pegs should be removed as usual.
     * when Spooky Ball is chosen at the start of the game
        *   when the grey ball hits a green peg of any shape, size and angle, the green peg will light up. Then the game should proceed as usual. When the ball falls out of the lower boundary, it should reappear as if it is falling down from the ceiling, with the same velocity, acceleration and at the same x position. The ball should appear faster due to acceleration. If the ball hits another green peg this time, the "spooky" action will happen again. Otherwise, the ball will fall out of the screen, and all hit pegs should fade out before the cannon is ready for launch again.
        *  when the grey ball does not hit any green peg in this round, the game should proceed as usual. All the lit up pegs should fade out once the ball falls out of screen, before the cannon is ready for launch again.

6. Test win/lose conditions:
    * At the top-right corner of the screen, the `Balls left` label should indicate the number of balls left for the user to launch.
    * When the ball flies out of screen and another round started, `Balls left`  should decrement by 1 unless the ball has just entered the bucket.
    * When all the orange pegs, regards of shape, size and angle, are cleared, and the number of balls left is not zero, a popup window should appear, titled `You Won`. Tapping the button on the window should bring the user back to the main menu.
    * When the number of balls left is 0 and there are still orange pegs left on the screen, once the current ball falls out of screen, a popup window should appear, titled `You Lost`. Tapping the button on the window should bring the user back to the main menu.
    * When the user creates a level with no orange pegs, the user should be allowed to play the game for one round. After the ball exits the screen, a popup window with `You Won` should appear since there are no more orange pegs.
    * To test winning condition, you may create a level with one orange peg, and clear it. A popup window with `You Won` should appear as described above.
    * To test losing condition, you may create a level with one orange peg, and use up all the 10 balls without hitting the orange peg. A popup window with `You Lost` should appear as described above.

7. Test other scenarios:
    * closing the app
        * After closing the app and removing it from the background, and then re-opening it, the current progress should be lost. The initial screen is launched, same as the first time the app is opened. However, persisted storage is not affected.
    * upper boundary
        * at any point of time, if the grey ball touches the upper boundary of the game screen, it should be reflected downwards as if the upper boundary is a ceiling.
    * energy loss
        * since each collision dissipates kinetic energy due to friction, one way this can be seen is the height reached by the ball after each upward bounce should be lower than the previous one.
    * difference in screen sizes
        * run the game on different iPad screen sizes. Everything described above should still hold.
    * many pegs
        * put as many pegs on the screen as possible in the Level Designer, then start the game. Since the peg size has a minimum, there is a finite number of pegs allowable on the screen. When playing the game with this amount of pegs, the ball movement should not appear to be laggy.

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

For my problem set 2, I separated different modules quite clearly. The interactions between different components are more distinct and clear. This is due to the use of protocols with a relatively small number of functions as the entry points for lower level components. As a result, almost all the classes could be reused without much changes for PS3 and PS4. In fact, only the `Peg` class was modified to accommodate for different sizes/shapes/rotations. However, the View Controller in my PS2 was too big, and separation of concerns on the VC level was not done well. This caused the VC to grow even larger when more feateures are added. 

For my problem set 3, I feel that I did not separate the VC and game engine component clearly. This resulted in a highly-coupled game engine and renderer (VC). When more game features were added, many bugs appeared due to the interactions between VC and game engine. I had to spend some time to move some of the responsibilities of VC back to game engine. If I were to redo this app, I would put more thoughts into designing the architecture between game engine and VC, and make VC lighter by moving more game logic related stuff to the game engine.  

Also, the physics engine collision checking in PS3 was designed only for circle-cirlce collision. More work had to be done to enable it to handle circle-triangle collisions as well. However, this is still not optimal. If I were to do the app again, I should not think of the objects as circles only, but instead I should model the objects as more flexible shapes (i.e. define an object using a list of vertices) and allow for more universal collision rules. 

Nevertheless, the interaction between physics engine and game engine was largely unchanged, as the game engine calls the `update()` function of physics engine, and cares about the locations of the bodies. No major work needed to be done regarding the interaction between these two engines.
