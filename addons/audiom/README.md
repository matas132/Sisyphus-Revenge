AudioM: Godot Audio Manager
===========================

A Godot audio manager plugin inspired by the FMOD workflow.

Usage
-----

### Install

1. Add the `audiom` folder to your `addons` folder.
2. Add a `AudioMManager` to your tree.
3. Link an event tree to it.

### Creating an event tree

The event tree is the node tree that will house all your audio events. Regular `Node` objects can be used to organise events into different groups and subgroups.

Add a child `Node` to your `AudioMManager` and set the `event_tree` property to it using the inspector.

Here's an example tree:

- Event `: Node` (root)
  - SFX `: Node`
	- UI
	  - ButtonClick `: AudioMEvent`
  - Music `: Node`
	- Track1 `: AudioMEvent`

An `event_path` parameter or property can refer to any descending `AudioMEvent`. In the example, to target ButtonClick the path would be `"SFX/UI/ButtonClick"`.

### Sound channels

The `AudioMManager` defines how many audio channels will be useable for simultaneous sounds. You should edit the `channel_count` and `channel_count_2d` according to your needs.

`channel_count` is used for events launched globally and from `AudioMEventInstance`. `channel_count_2d` is used for events launched from `AudioMEventInstance2D`.

### Playing a "one shot"

Use `AudioM.play` to play "one shot" or quick sound to play in its entirety:

```py
AudioM.play("SFX/UI/ButtonClick")
```

### Creating an event instance

Use the `AudioMEventInstance` to manage the state of the event:

```
@onready music_instance: AudioMEventInstance = $Track1
```

to play:

```py
music_instance.play()
```

or stop a sound:

```py
music_instance.stop()
```

Use `AudioMEventInstance2D` alongside `AudioListener2D` instead for positional audio.

### Event parameters

Events can define parameters that will modulate various sound properties.

Parameters can be changed globally:

```py
AudioM.set_parameter('instensity', 1)
# Always a float between 0 and 1 (so 1 == 100% intensity)
```

or locally:

```py
music_instance.set_parameter('instensity', 1)
```

For global parameters to work, they need to be defined on the `AudioMManager`, and events must make them `global`.
