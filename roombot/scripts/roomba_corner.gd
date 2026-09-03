class_name RoombaCorner extends RoombaBase

# Slow down while cleaning.
# Collide with other roombas


# NOTE: Cleaning can be triggered by two conditions:
#	1. Distance traveled since previous cleaning.
#	2. Time since last cleaning.
#		Time is used to clean while motionless/rotating, distance is used to clean while moving.
#		This is done to avoid cleaning on every single frame.

var _turn_pause_time: float = 0.3
var _turn_pause_remaining: float = 0.0
var _turn_tween: Tween

@onready var bumper_sprite: Sprite2D = $BumperSprite


func _process(delta: float) -> void:
	
	# If not turning AND bumper is hit, pick a new target angle to turn towards.
	if _turn_pause_remaining > 0.0:
		_turn_pause_remaining -= delta
		
	elif target_angle == null and _bumper_check():
		_turn_pause_remaining = _turn_pause_time

		rotation = round(rotation/(PI/2) + turn_dir) * PI/2
		tween_bumper_rot(PI/2 * turn_dir)

		velocity = Vector2.ZERO # Stop moving!

	# Move forward.
	else:
		# Accelerates to top speed.
		velocity = velocity.move_toward(Vector2.from_angle(rotation) * top_speed, accel * delta)
		# rotation += randf_range(-0.05, 0.05) # Slight random wobble to movement, looks kinda cool.
	
	super._process(delta)

func tween_bumper_rot(ang: float) -> void:
	if is_instance_valid(_turn_tween):
		_turn_tween.kill()
	
	_turn_tween = create_tween()
	_turn_tween.set_parallel()
	#_turn_tween.tween_property(bumper_sprite, "position.x", ) # Bounce backwards
	_turn_tween.tween_property(bumper_sprite, "rotation", 0.0, 0.3).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT).from(-ang)
	_turn_tween.play()
