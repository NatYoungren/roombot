class_name RoombaBasic extends CharacterBody2D

@onready var bumper_area: Area2D = $bumper_area

@onready var cleaner: BaseCleaner = $CircleCleaner # Cleaning AoE
#@onready var cleaner: BaseCleaner = $RectCleaner # Cleaning AoE (Testing rectangular shape)


## Max speed of the roomba.
@export var top_speed: float = 100.0

## Acceleration of the roomba.
@export var accel: float = 200.0

## Radians per second of turning speed.
@export var turn_speed: float = PI

## Angle (radians) that roomba is currently turning towards.
## If null, roomba is moving forward.
var target_angle = null 


# NOTE: Cleaning can be triggered by two conditions:
#	1. Distance traveled since previous cleaning.
#	2. Time since last cleaning.
#		Time is used to clean while motionless/rotating, distance is used to clean while moving.
#		This is done to avoid cleaning on every single frame.
var prev_clean_position: Vector2 = Vector2.ZERO # Position of previous cleaning
var clean_distance: float = 2.0 # Distance from prev_clean_position which triggers cleaning
var clean_timer: Timer # Timer between cleaning triggers


var filth_cleaned: float = 0.0 # Tally of cleaned filth (pixel opacity)
var filth_to_money_ratio: float = 0.1 # Conversion ratio of filth cleaned to money earned



func _process(delta: float) -> void:
	
	# If not turning AND bumper is hit, pick a new target angle to turn towards.
	if target_angle == null and _bumper_check():
		target_angle = wrapf(rotation + randf_range(PI/8, PI * 3/8), -PI, PI)
		velocity = Vector2.ZERO # Stop moving!
		# print("Bumper hit! New target angle: ", target_angle)

	# If we have a target angle, turn towards it.
	elif target_angle != null:
		# print("turning towards ", target_angle, " current rotation: ", rotation)
		rotation = Utils.turn_towards(rotation, target_angle, turn_speed * delta)
		
	 	# If close to desired angle, stop turning. (avoids float precision issues)
		if abs(rotation - target_angle) < 0.05:
			# print("Reached target angle: ", target_angle)
			target_angle = null
	
	# Move forward.
	else:
		# Accelerates to top speed.
		velocity = velocity.move_toward(Vector2.from_angle(rotation) * top_speed, accel * delta)
		# rotation += randf_range(-0.05, 0.05) # Slight random wobble to movement, looks kinda cool.
	
	# If we've moved far enough since last cleaning, clean again.
	if position.distance_to(prev_clean_position) >= clean_distance:
		clean_filth()
	
	# # #
	# DEBUG (MOVE THESE TO A GLOBAL/SINGLETON INPUT HANDLER FILE?)
	
	# Press SPACE to completely fill filth layer, for testing.
	if Input.is_action_just_pressed("ui_accept"):
		State.filth_layer.debug_fill_image()
	
	# Press LEFT to add random junk filth, for testing.
	if Input.is_action_just_pressed("ui_left"):
		State.filth_layer.random_junk()


func _physics_process(_delta: float) -> void:
	move_and_slide()


# Returns true if the bumper area is colliding with anything.
func _bumper_check() -> bool:
	return not bumper_area.get_overlapping_bodies().is_empty()


# Activate cleaner node, reset stored position and timer.
func clean_filth() -> void:
	var cleaned: float = cleaner.clean(State.filth_layer)
	filth_cleaned += cleaned
	State.money += cleaned * filth_to_money_ratio

	prev_clean_position = position
	clean_timer.start()
	#print("Filth cleaned: ", filth_cleaned)


# Create clean_timer
func _ready() -> void:
	clean_timer = Timer.new()
	clean_timer.wait_time = 0.2
	clean_timer.one_shot = false
	clean_timer.autostart = true
	clean_timer.timeout.connect(clean_filth)
	add_child(clean_timer)
