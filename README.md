# VRWorkout
Virtual reality fitness workout game for Oculus Quest

[![Oculus Quest Download](https://github.com/mgschwan/VRWorkout/raw/master/web_assets/download_button_oculusquest.png)](https://www.oculus.com/experiences/quest/3434050740056916)

[![Windows Download](https://github.com/mgschwan/VRWorkout/raw/master/web_assets/download_button_windows.png)](https://github.com/mgschwan/VRWorkout/releases/latest/download/VRWorkout_win.zip)

[![SideQuest Install](https://github.com/mgschwan/VRWorkout/raw/master/web_assets/install_button_sidequest.png)](https://sidequestvr.com/#/app/413)


For a quick overview take a look at a short gameplay video

[![v0.9.7](https://github.com/mgschwan/VRWorkout/blob/master/web_assets/workout_video_playscreen.jpg)](https://www.youtube.com/watch?v=mknXbyVJm3c)

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

## Install

* Either directly through [AppLab](https://www.oculus.com/experiences/quest/3434050740056916) , [Sidequest](https://sidequestvr.com/#/app/413) 
* or by downloading the latest APK file from the [Releases](https://github.com/mgschwan/VRWorkout/releases) section and installing it via ADB to your device

This game is best played with hand tracking!

__Please enable "Hand Tracking" in the experimental features section of your Oculus Quest.__


## How to play

![Handtracking](https://github.com/mgschwan/VRWorkout/raw/master/web_assets/vrworkout_hand_suggestion.jpg)

* Try to hit the hand cues to the beat of the music. Play with **open palms** to improve tacking
* The head cue has to be touched with your head. Just touch it, no headbutting
* Run in place to receive point multipliers, up to 4x
* If you want to switch out an exercise during play double tap the new exercise twice in the exercise selector to your right

The optimal time to hit the cues is when the marker that rotates around the cue touches the second one.

Upon start you will see several different blocks. Touch one of them at the desired difficulty spot to select a level and difficulty.
To disable exercises switch them on/off with the switches to your left.

Exiting a stage during play:  On the top of the left blue pole is a sign to exit a stage.

__Freeplay mode__

Play with your own music in Freeplay mode*
Put on some music in the background (maybe using the nullnMusic player) and hit the blue drum in the main menu to the beat of the music.
Once the beat is set select one of the freeplay modes to your right. They will send the cues according to the BPM you set but without playing any music.

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

[![v0.9.7](https://github.com/mgschwan/VRWorkout/blob/master/web_assets/workout_video_playscreen.jpg)](https://www.youtube.com/watch?v=mknXbyVJm3c)

__Older gameplay__

[![Side plank update](https://img.youtube.com/vi/FWY8M-wg_mo/0.jpg)](https://www.youtube.com/watch?v=FWY8M-wg_mo)
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

![Logo](https://github.com/mgschwan/VRWorkout/blob/master/web_assets/vrworkout_godot_transparent_figures.jpg)


## Feedback

For suggestions/feedback join the discord group [VRWorkout Dojo](https://discord.gg/Vg3vyah) or send a message to dev@vrworkout.at


## Credits:

### Music
* ‘Duty to Humanity’ composed and performed by Moumoku. [Link to artist](https://artbymoumoku.org/​)
* 'Slayers of the Ice Dragon' composed and performed by Nagoonberries Music. [Link to artist](https://soundcloud.com/nagoonberries)
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
* Tron by 1Angelika_A 
