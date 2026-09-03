class_name RoombaBasic extends RoombaBase

# NOTE: Roomba 'reliability' goes down as roomba gets dirty/full.
#		Roomba must dock at a station or be interacted with to empty it.
#		Change color of status light (green -> yellow -> orange -> red) to indicate reliability.
#		Could reserve red for 'dead' roombas, which barely function until repaired/recharged.
#		Dead roombas could explode and leave debris on the ground?


var _bonk_tween: Tween
@onready var bumper_sprite: Sprite2D = $BumperSprite
@onready var body_sprite: Sprite2D = $BodySprite
@onready var button_sprite: Sprite2D = $ButtonSprite


func _process(delta: float) -> void:
	# If not turning AND bumper is hit, pick a new target angle to turn towards.
	if target_angle == null and _bumper_check():
		target_angle = wrapf(rotation + turn_dir * randf_range(PI/8, PI * 3/8), -PI, PI)
		tween_bumper_bonk(velocity.length())

		velocity = Vector2.ZERO # Stop moving!
		# velocity *= 0.25 # Stop moving!
	
	# If we have a target angle, turn towards it.
	elif target_angle != null:
		# print("turning towards ", target_angle, " current rotation: ", rotation)
		rotation = Utils.turn_towards(rotation, target_angle, turn_speed * delta)
		
		# If close to desired angle, stop turning. (avoids float precision issues)
		if abs(rotation - target_angle) < 0.05: # TODO: THIS COULD STILL WHIFF. Change to check 'if turned more than x'.
			# print("Reached target angle: ", target_angle)
			target_angle = null
	
	# Move forward.
	else:
		# Accelerates to top speed.
		velocity = velocity.move_toward(Vector2.from_angle(rotation) * top_speed, accel * delta)
		# rotation += randf_range(-0.05, 0.05) # Slight random wobble to movement, looks kinda cool.
	
	super._process(delta)
	body_sprite.global_rotation = 0
	button_sprite.global_rotation = 0

func tween_bumper_bonk(spd: float = 0.0) -> void:
	if spd <= top_speed * 0.5: return
	if is_instance_valid(_bonk_tween):
		_bonk_tween.kill()
	
	_bonk_tween = create_tween()
	#_turn_tween.tween_property(bumper_sprite, "position.x", ) # Bounce backwards
	_bonk_tween.tween_property(bumper_sprite, "position:x", -2, 0.1).from(0)
	_bonk_tween.tween_property(bumper_sprite, "position:x", 0, 0.3).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT).from(-3)
	_bonk_tween.play()
