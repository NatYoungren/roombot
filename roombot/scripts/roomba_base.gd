class_name RoombaBase extends CharacterBody2D

# Slow down while cleaning?
# Collide with other roombas?

signal roomba_clicked(roomba: RoombaBase, button: int)
signal update_select(selected: bool)

@export_category("Nodes")
## Highlight sprite, used for selection fx.
@export var outline_sprite: Sprite2D

## Bumper area, for collision detection.
@export var bumper_area: Area2D

## Cleaner node, defines cleaning area/shape.
@export var cleaner: BaseCleaner # Cleaning AoE


@export_category("Movement")

## Max speed of the roomba.
@export var top_speed: float = 100.0

## Acceleration of the roomba.
@export var accel: float = 200.0

## Radians per second of turning speed.
@export var turn_speed: float = PI

## Turn direction when bumper is hit.
@export var turn_dir: int = 1

## Angle (radians) that roomba is currently turning towards.
## If null, roomba is moving forward.
var target_angle = null # NOTE: Not used by RoombaCorner. Remove or move to subclass?


@export_category("Cleaning")

# NOTE: Cleaning can be triggered by two conditions:
#	1. Distance traveled since previous cleaning.
#	2. Time since last cleaning.
#		Time is used to clean while motionless/rotating, distance is used to clean while moving.
#		This is done to avoid cleaning on every single frame.

## Travel distance between cleaning triggers, in pixels.
@export var clean_distance: float = 2.0 
var prev_clean_position: Vector2 = Vector2.ZERO # Position of previous cleaning
var clean_timer: Timer # Timer between automatic cleaning triggers
var time_elapsed: float = 0.0 # Time spent cleaning since object creation, in seconds.


## Conversion ratio of filth cleaned to money earned.
@export var filth_to_money_ratio: float = 0.01 
var filth_cleaned: float = 0.0 # Tally of cleaned filth (pixel opacity)



func _process(_delta: float) -> void:
	time_elapsed += _delta
	# If we've moved far enough since last cleaning, clean again.
	if position.distance_to(prev_clean_position) >= clean_distance:
		clean_filth()
	

func _physics_process(_delta: float) -> void:
	move_and_slide()


# Returns true if the bumper area is colliding with anything.
func _bumper_check() -> bool:
	return bumper_area.get_overlapping_bodies().size() > 1
	#return not bumper_area.get_overlapping_bodies().is_empty() # For non-self overlap check


# Activate cleaner node, reset stored position and timer.
func clean_filth() -> void:
	var cleaned: float = cleaner.clean(State.filth_layer)
	filth_cleaned += cleaned
	State.money += cleaned * filth_to_money_ratio

	prev_clean_position = position
	clean_timer.start()
	#print("Filth cleaned: ", filth_cleaned)


# NOTE: Requires pickable == true
func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		roomba_clicked.emit(self, event.button_index)

	# # TODO: Handle tap/double-tap
	# if event is InputEventScreenTouch and event.pressed:
	# 	roomba_clicked.emit(self, MOUSE_BUTTON_LEFT)


# Create clean_timer
func _ready() -> void:
	clean_timer = Timer.new()
	clean_timer.wait_time = 0.2
	clean_timer.one_shot = false
	clean_timer.autostart = true
	clean_timer.timeout.connect(clean_filth)
	add_child(clean_timer)

	_register()

# Connect signals
func _register():
	roomba_clicked.connect(State._on_clicked_default)
	update_select.connect(_update_selected_state)
	State._register_roomba(self)


# Display outline fx while selected.
var _selected_tween: Tween
func _update_selected_state(is_selected: bool) -> void:
	if is_instance_valid(_selected_tween):
		_selected_tween.kill()
	
	outline_sprite.visible = is_selected
	
	if is_selected:
		_selected_tween = create_tween()
		_selected_tween.set_loops()
		_selected_tween.tween_property(outline_sprite, "modulate:a", 1.0, 0.5)
		_selected_tween.parallel().tween_property(outline_sprite, "scale", Vector2.ONE*1.1, 0.5)
		_selected_tween.tween_property(outline_sprite, "modulate:a", 0.5, 0.5)
		_selected_tween.parallel().tween_property(outline_sprite, "scale", Vector2.ONE, 0.5)
		_selected_tween.play()
