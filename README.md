# VRWorkout
Virtual reality workout game for Oculus Quest

##What is this

A virtual reality music workout game built with [Godot Engine](https://godotengine.org/)


**DISCLAIMER: Use at your own risk! This game does not check if you bump into your surroundings. Since this is a physical workout game there is lot's of movement which bears the risk of injury. You acknowledge that this software is free and you are using it at your own risk**

![Logo](https://github.com/mgschwan/VRWorkout/blob/master/web_assets/vrworkout_logo_new.jpg)

For suggestions/feedback joing the discord group [VRWorkout Dojo](https://discord.gg/Vg3vyah)

This game shall - once it's finished - provide a high intensity full body workout similar to punching games but with 4 different playing positions:
* standing
* squatting
* crunches
* pushup position

The game switches between those four positions. Try to hit the hand cues when they are between the two blue poles. The head cue has to be touched (not hit) with your head.

Jog in place to receive a point multiplier, run faster to get up to 4x points.

## Install

* Either directly through [Sidequest](https://sidequestvr.com/#/app/413) 
* or by downloading the latest APK file from the [Releases](https://github.com/mgschwan/VRWorkout/releases) section and installing it via ADB to your device


## How to play

Upon start you will see several different blocks. Touch one of them to select a level. 
To change the difficulty touch the blue pole to your right at different heights.

* Bottom: Hard
* Lower part: Medium
* High: Easy

__Freeplay mode__

To play along your own songs just play them on your own device (smartphone, sound system, smart speaker) and drum in the beats on the blue drum. Once you are satisfied with the beat start one of the Freeplay modes. They will only play the soundeffects and emit the cues according to the beat you have set.

__Beast mode__

Touch the block to your left that reads "Toggle beast mode" to enable the claws. Once enabled make a fist to extend them and open your fist to retract them. At the moment the claws are only eye candy and have no function. If they prove to be reliable they will become an integral part of future gameplay.

## Development

This is my first VR and my first Godot game, so the code may be a bit messy.

Requirements:

* Godot 3.2+  [download here](https://godotengine.org/)
* Godot Oculus Mobile Plugin [install instructions here](https://github.com/GodotVR/godot_oculus_mobile)
* Oculus Quest Headset in Developer mode

Please follow the instructions how to compile and install the [godot_oculus_mobile](https://github.com/GodotVR/godot_oculus_mobile) plugin before reporting problems getting the code to run on your Oculus Quest.  

Once everything is installed import the project.godot file from the godot_project folder to start editing the game.

## Screenshots
![Screenshot 1](https://github.com/mgschwan/VRWorkout/blob/master/web_assets/vrworkout_menu.jpg)
![Screenshot 3](https://github.com/mgschwan/VRWorkout/blob/master/web_assets/vrworkout_side.jpg)
![Screenshot 4](https://github.com/mgschwan/VRWorkout/blob/master/web_assets/vrworkout_play_main.jpg)
![Screenshot 5](https://github.com/mgschwan/VRWorkout/blob/master/web_assets/vrworkout_stand.jpg)
![Screenshot 2](https://github.com/mgschwan/VRWorkout/blob/master/web_assets/vrworkout_double_punch.jpg)
![Screenshot 6](https://github.com/mgschwan/VRWorkout/blob/master/web_assets/vrworkout_main_menu.jpg)
![Screenshot 7](https://github.com/mgschwan/VRWorkout/blob/master/web_assets/vrworkout_beast_mode_claws.jpg)
![Screenshot 8](https://github.com/mgschwan/VRWorkout/blob/master/web_assets/vrworkout_claw_hit2.jpg)
![Screenshot 9](https://github.com/mgschwan/VRWorkout/blob/master/web_assets/vrworkout_claw_hit.jpg)
![Screenshot 10](https://github.com/mgschwan/VRWorkout/blob/master/web_assets/vrworkout_claw2.jpg)


## Sample gameplay

__Latest version__
[![Beast mode update](https://www.youtube.com/watch?v=6TnzuIsVT6o/0.jpg)](https://www.youtube.com/watch?v=6TnzuIsVT6o)

__Older gameplay__
[![Sample gameplay](https://img.youtube.com/vi/mSPQulHXlJo/0.jpg)](https://www.youtube.com/watch?v=mSPQulHXlJo)

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
