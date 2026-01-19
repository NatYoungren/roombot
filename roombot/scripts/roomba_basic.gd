class_name RoombaBasic extends CharacterBody2D

@onready var bumper_area: Area2D = $bumper_area

var top_speed: float = 100.0
var accel: float = 200.0

func _process(delta: float) -> void:
	
	if _bumper_check():
		rotation += PI * delta
		velocity = Vector2.ZERO
	else:
		velocity = velocity.move_toward(Vector2.from_angle(rotation) * top_speed, accel * delta)
	
func _physics_process(_delta: float) -> void:
	move_and_slide()

func _bumper_check() -> bool:
	return not bumper_area.get_overlapping_bodies().is_empty()
