# VRWorkout
Virtual reality fitness workout game for Oculus Quest

## What is this?

A virtual reality music workout game built with [Godot Engine](https://godotengine.org/)

The game sould be a physically engaging VR experience that is somewhat comparable to a short calisthenics workout (or a long one if you play for extended periods). Compared to other music games like Beat Saber and Box VR there should be more muscle groups activated due to the changes between standing, squatting, pushups, side planks, crunches, jumping and burpees. 

But as with all games it is up to the player to actually work out and not cheat it's way through the movements. The only opponent in this game is the players body itself, if you really engage in it you will feel the exertion it brings with it.

Positions:

* Standing (or running to get point multipliers)
* Jumping. To reach the head cues the player will need to jump a bit
* Squatting. The game will require deep squats
* Crunches. You don't need to do repetitive crunches but be on your back and try to hit the head and double hand cues
* Pushups. Try to hit the hand cues while in the pushup position (one handed punches will activate your core muscles). The head cues will drive your movement up and down
* Burpees. Hit the head cues in the pushup position then immediately jump up to hit the head cue in the jump position.

The game switches between those four positions to avoid a monotone workout.

**DISCLAIMER: Use at your own risk! This game does not check if you bump into your surroundings. Since this is a physical workout game there is lot's of movement which bears the risk of injury. You acknowledge that this software is free and you are using it at your own risk**

![Logo](https://github.com/mgschwan/VRWorkout/blob/master/web_assets/vrworkout_logo_new.jpg)

## Install

* Either directly through [Sidequest](https://sidequestvr.com/#/app/413) 
* or by downloading the latest APK file from the [Releases](https://github.com/mgschwan/VRWorkout/releases) section and installing it via ADB to your device

This game is best played with hand tracking!

__Please enable "Hand Tracking" in the experimental features section of your Oculus Quest.__


## How to play


Upon start you will see several different blocks. Touch one of them to select a level and difficulty. 
Try to stand as upright as possible for the game to determine your height.

Try to hit the hand cues when they are between the two blue poles, you can also see the correct time for the hit when the two white markers at each cue start to overlap. The head cue has to be touched (not hit) with your head (don't try to headbutt them).

Jog in place to receive a point multiplier, run faster to get up to 4x points.

__Freeplay mode__

To play along your own songs just play them on your own device (smartphone, sound system, smart speaker) and drum in the beats on the blue drum. Once you are satisfied with the beat start one of the Freeplay modes. They will only play the soundeffects and emit the cues according to the beat you have set.

__Beast mode__

Touch the block to your left that reads "Toggle beast mode" to enable the claws. Once enabled make a fist to extend them and open your fist to retract them. At the moment the claws are only eye candy and have no function. If they prove to be reliable they will become an integral part of future gameplay.

## VR Fitness results

A test of a ~21 minute session of VRWorkout on "Hard" for all songs burned 288kcal

![Workout Statistic](https://github.com/mgschwan/VRWorkout/blob/master/web_assets/workout_statistics.jpg)

Measurements were done with a Polar H10 heartrate monitor and the Polar Beats app.

## Development

This is my first VR and my first Godot game, so the code may be a bit messy.

Requirements for developing the Oculus Quest based version:

* Godot 3.2+  [download here](https://godotengine.org/)
* Godot Oculus Mobile Plugin from the Asset Library
* Oculus Quest Headset in Developer mode

Requirements for developing the PC based version:

* Godot 3.2+ [download here](https://godotengine.org/)
* OpenVR plugin from the Asset Library
* SteamVR

Once everything is installed import the project.godot file from the godot_project folder to start editing the game.


## Sample gameplay videos

__Latest version__

[![Side plank update](https://img.youtube.com/vi/FWY8M-wg_mo/0.jpg)](https://www.youtube.com/watch?v=FWY8M-wg_mo)

__Older gameplay__

[![Beast mode update](https://img.youtube.com/vi/6TnzuIsVT6o/0.jpg)](https://www.youtube.com/watch?v=6TnzuIsVT6o)
[![Sample gameplay](https://img.youtube.com/vi/mSPQulHXlJo/0.jpg)](https://www.youtube.com/watch?v=mSPQulHXlJo)


## Screenshots
![Standing left hand hit](https://github.com/mgschwan/VRWorkout/blob/master/web_assets/play_screenshots/stand_left_hand2.png.jpg)
Standing - Hand cues

![Crunches](https://github.com/mgschwan/VRWorkout/blob/master/web_assets/play_screenshots/crunch1.png.jpg)
Crunches - Hand cues

![Crunches](https://github.com/mgschwan/VRWorkout/blob/master/web_assets/play_screenshots/crunch2.png.jpg)
Crunches - Head cues

![Jumping](https://github.com/mgschwan/VRWorkout/blob/master/web_assets/play_screenshots/jump.png.jpg)
Jumping

![Pushup left hand hit](https://github.com/mgschwan/VRWorkout/blob/master/web_assets/play_screenshots/pushup_left_hand.png.jpg)
Pushups - Hand cues

![Side plank](https://github.com/mgschwan/VRWorkout/blob/master/web_assets/play_screenshots/side_plank.png.jpg)
Pushups - Side plank

![Squat hand left](https://github.com/mgschwan/VRWorkout/blob/master/web_assets/play_screenshots/squat_hand_left.png.jpg)
Squats - Hand cues

![Squat head](https://github.com/mgschwan/VRWorkout/blob/master/web_assets/play_screenshots/squat_head.png.jpg)
Squats - Head cues

![Stand head](https://github.com/mgschwan/VRWorkout/blob/master/web_assets/play_screenshots/stand_head.png.jpg)
Standing - Head cues

![Screenshot new 4](https://github.com/mgschwan/VRWorkout/blob/master/web_assets/vrworkout_beast_attack.jpg)
Beast mode - Beast attack

![Screenshot new 3](https://github.com/mgschwan/VRWorkout/blob/master/web_assets/vrworkout_instructor3.jpg)

![Screenshot 1](https://github.com/mgschwan/VRWorkout/blob/master/web_assets/vrworkout_menu.jpg)

![Screenshot 3](https://github.com/mgschwan/VRWorkout/blob/master/web_assets/vrworkout_side.jpg)

## Feedback

For suggestions/feedback join the discord group [VRWorkout Dojo](https://discord.gg/Vg3vyah) or send a message to dev@vrworkout.at


## Credits:

### Music
* Odder Stuff (Duckettized) by 7OOP3D (c) copyright 2019 Licensed under a Creative Commons Attribution Noncommercial  (3.0) license. http://dig.ccmixter.org/files/7OOP3D/60150 Ft: Duckett
* Drive by Alex (c) copyright 2013 Licensed under a Creative Commons Attribution (3.0) license. http://dig.ccmixter.org/files/AlexBeroza/43098 Ft: cdk & Darryl J
* Deeper In Yourself (cdk mix) by Analog By Nature (c) copyright 2012 Licensed under a Creative Commons Attribution Noncommercial  (3.0) license. http://dig.ccmixter.org/files/cdk/39241 Ft: Covert
* Like This (cdk Step This mix) by Analog By Nature (c) copyright 2012 Licensed under a Creative Commons Attribution Noncommercial  (3.0) license. http://dig.ccmixter.org/files/cdk/37315 Ft: 4Nsic
* The Game Has Changed (cdk RumbleStep Mix) by Analog By Nature (c) copyright 2013 Licensed under a Creative Commons Attribution (3.0) license. http://dig.ccmixter.org/files/cdk/41830 Ft: My Free Mickey
* Shameless Site Promotion by Platinum Butterfly (c) copyright 2012 Licensed under a Creative Commons Attribution Noncommercial  (3.0) license. http://dig.ccmixter.org/files/F_Fact/38008 Ft: Alex, Ms. Vybe
* Tiny Spaceships by Hans Atom (c) copyright 2019 Licensed under a Creative Commons Attribution (3.0) license. http://dig.ccmixter.org/files/hansatom/60364 Ft: Donnie Ozone
* The Game Has Changed by My Free Mickey (c) copyright 2013 Licensed under a Creative Commons Attribution (3.0) license. http://dig.ccmixter.org/files/myfreemickey/40672 Ft: Kamihamiha
* Clarity* (a moment of) by Scomber (c) copyright 2014 Licensed under a Creative Commons Attribution Noncommercial  (3.0) license. http://dig.ccmixter.org/files/scomber/48133 Ft: My Free Mickey, Kare Square  & Ms.Vybe

### 3D Models

* KF2 Berzerker Perk Symbol by DiabolicMaggot
* Low Poly Forest by isbl 
* Floating Islands by Otis25 
* Open Tatami Room by OSad 
