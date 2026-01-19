class_name RoombaBasic extends CharacterBody2D

@onready var bumper_area: Area2D = $bumper_area

@onready var cleaner: Cleaner = $Cleaner # Cleaning AoE


## Max speed of the roomba.
var top_speed: float = 100.0

## Acceleration of the roomba.
var accel: float = 200.0

## Radians per second of turning speed.
var turn_speed: float = PI

## Angle (radians) that roomba is currently turning towards.
## If null, roomba is moving forward.
var target_angle = null 


var prev_clean_position: Vector2 = Vector2.ZERO
var clean_timer: Timer
var clean_distance: float = 2.0


var filth_cleaned: float = 0.0



func _process(delta: float) -> void:
	
	# If moving forward and bumper is hit, pick a new target angle to turn towards.
	if target_angle == null and _bumper_check():
		target_angle = wrapf(rotation + randf_range(PI/8, PI * 3/8), -PI, PI)
		velocity = Vector2.ZERO
		# print("Bumper hit! New target angle: ", target_angle)

	# If we have a target angle, turn towards it.
	elif target_angle != null:
		rotation = Utils.turn_towards(rotation, target_angle, turn_speed * delta)
		# print("turning towards ", target_angle, " current rotation: ", rotation)
		if abs(rotation - target_angle) < 0.05:
			# print("Reached target angle: ", target_angle)
			target_angle = null
	
	# Move forward.
	else:
		velocity = velocity.move_toward(Vector2.from_angle(rotation) * top_speed, accel * delta)
	
	# If we've moved far enough since last cleaning, clean again.
	if position.distance_to(prev_clean_position) >= clean_distance:
		clean_filth()

func _physics_process(_delta: float) -> void:
	move_and_slide()


# Returns true if the bumper area is colliding with anything.
func _bumper_check() -> bool:
	return not bumper_area.get_overlapping_bodies().is_empty()


func clean_filth() -> void:
	filth_cleaned += cleaner.clean_filth(State.filth_layer)
	prev_clean_position = position
	clean_timer.start()

	print(filth_cleaned)


func _ready() -> void:
	clean_timer = Timer.new()
	clean_timer.wait_time = 0.2
	clean_timer.one_shot = false
	clean_timer.autostart = true
	clean_timer.timeout.connect(clean_filth)
	add_child(clean_timer)
