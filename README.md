iOS Space Invaders Clone
========================

A simple Space Invaders clone for iOS.  Optimized for iPads and targeting iOS 8.1.

Controls and Gameplay
----------------------

*	Game is landscape only
*	You are the red "ship" in the bottom of the screen.  Your goal is to destroy all of the "Invaders" - the other blocks - before they deplete your health or reach your ship.
*	Score is shown in the upper right of the screen.  Your score increases for each Invader destroyed.  More points are granted for higher difficulty levels
*	Health is shown in the upper right of the screen.  Each time you are hit by and Invader, your health drops by 10%
*	Difficulty can be changed from the main menu - the first screen you see when you start the game.  The higher the difficulty, the less time you have until the Invaders reach you.
*	Your ship is controlled by the accelerometer on your device.  Tilt your device left or right to move.When the device is level, you will stop moving.
*	Your ships fires whenever you tap the screen.  It's as simple as that!



Building/Editing 
---------------------   

Requires that Cocoapods be installed to build.  If you do not have Cocoapods, use the command

    sudo gem install cocoapods

in a terminal window.

After Cocoapods is installed, navigate to the ios-space-invaders-clone folder and use the command

    pod install

in a terminal window to download all required dependencies and generate a workspace.

Open the SpaceInvaders.xcworkspace file with Xcode.

More information about Cocoapods can be found [here](http://guides.cocoapods.org/)

Acknowlegements
-----------------

*	Explosion Sound :
	*	 Mike Koenig [Bomb Explosion 1](http://soundbible.com/107-Bomb-Explosion-1.html)

*	Firing Sound : 
	*	Mike Koenig [Laser](http://soundbible.com/1087-Laser.html)

*	Game Over Sound : 
	*	Mike Devils [End Fx](http://soundbible.com/2017-End-Fx.html)

*	Button Press Sound : 
	*	Marianne Gagnon [Button Press 3](http://soundbible.com/1689-Button-Press-3.html)

*	Music : 
	*	[Meteor Blaze! - Zimboldt](https://soundcloud.com/zimbolt/meteor-blaze)
