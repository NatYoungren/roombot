class_name WallOutlet extends Node2D

# TODO: Add a convenient scene for DoubleWallPlug (2x next to each other)


@onready var sprite_2d: Sprite2D = $Sprite2D

var is_connected: bool:
	get:
		return is_connected
	set(value):
		is_connected = value

var connection: BaseStation
