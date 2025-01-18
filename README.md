# Modot Distortionator

A battle background editor for earthbound-ish games.

![image](https://github.com/user-attachments/assets/4746f1f3-5599-4b15-bef8-77f0247c2697)

## How to use

Install the Godot Integration Addon (in /addons) in your project.

Then, create a new `.dsp` file anywhere within a valid Godot project and edit away.
[Demonstration video](https://www.youtube.com/watch?v=0OEWLVnX30A&t=32s).

You can upload any textures that are in the Godot project and the exported `.dsp` will attempt to use godot `Resource`s at run time.

## Building from source

It's a Godot project, just run it man...

## FAQ

> Why is this not embedded in the Godot Editor?

This editor was created so you could edit `.dsp`s on [Mother Encore](https://motherencore.com/), which is a large Godot project that takes a while to startup. Having a separate editor allows artists to not even touch Godot.
