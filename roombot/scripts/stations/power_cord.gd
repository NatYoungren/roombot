extends Node2D


@export var pref_length: float = 100.0
@export_range(2, 64, 1) var curve_samples: int = 24
@export_range(0.0, 1.0, 0.01) var curve_strength: float = 0.35
@export var pixel_size: float = 2.0
@export var cord_color: Color = Color(0.2, 0.18, 0.14)
@export var socket_length: float = 10.0

@export var node1: Node2D
@export var node2: Node2D

@export var node1_local_offset: Vector2 = Vector2.ZERO
@export var node2_local_offset: Vector2 = Vector2.ZERO

@export var node1_local_angle_offset: float = 0.0
@export var node2_local_angle_offset: float = PI

@onready var plug1: Sprite2D = $Plug1
@onready var plug2: Sprite2D = $Plug2


func _ready() -> void:
	queue_redraw()


func _process(_delta: float) -> void:
	if not is_instance_valid(node1) or not is_instance_valid(node2):
		visible = false
		return

	visible = true
	_update_plugs()
	queue_redraw()


func _draw() -> void:
	if not is_instance_valid(node1) or not is_instance_valid(node2):
		return

	var curve := _build_curve()
	if curve.size() < 2:
		return

	_draw_pixel_curve(curve)


func _build_curve() -> PackedVector2Array:
	var start_point := _get_socket_point(node1, node1_local_offset, node1_local_angle_offset)
	var end_point := _get_socket_point(node2, node2_local_offset, node2_local_angle_offset)
	var chord := end_point - start_point
	var distance: float = chord.length()

	var start_tangent := Vector2.RIGHT.rotated(node1.global_rotation + node1_local_angle_offset)
	var end_tangent := Vector2.RIGHT.rotated(node2.global_rotation + node2_local_angle_offset)
	var handle_length: float = max(socket_length, distance * 0.35)

	var slack: float = 0.0
	if pref_length > 0.001:
		slack = clampf((pref_length - distance) / pref_length, 0.0, 1.0)

	var bend_direction := Vector2.ZERO
	if distance > 0.001:
		bend_direction = Vector2(-chord.y, chord.x).normalized()

	var bend_amount: float = distance * curve_strength * slack * 0.5
	var control1 := start_point + start_tangent * handle_length + bend_direction * bend_amount
	var control2 := end_point - end_tangent * handle_length + bend_direction * bend_amount

	var samples: int = curve_samples
	if samples < 2:
		samples = 2

	var points := PackedVector2Array()
	points.resize(samples + 1)
	for i in range(samples + 1):
		var t: float = float(i) / float(samples)
		points[i] = _cubic_bezier(start_point, control1, control2, end_point, t)

	return points


func _update_plugs() -> void:
	var start_point := _get_socket_point(node1, node1_local_offset, node1_local_angle_offset)
	var end_point := _get_socket_point(node2, node2_local_offset, node2_local_angle_offset)
	var chord := end_point - start_point
	var distance: float = chord.length()

	var start_tangent := Vector2.RIGHT.rotated(node1.global_rotation + node1_local_angle_offset)
	var end_tangent := Vector2.RIGHT.rotated(node2.global_rotation + node2_local_angle_offset)
	var handle_length: float = max(socket_length, distance * 0.35)

	var slack: float = 0.0
	if pref_length > 0.001:
		slack = clampf((pref_length - distance) / pref_length, 0.0, 1.0)

	var bend_direction := Vector2.ZERO
	if distance > 0.001:
		bend_direction = Vector2(-chord.y, chord.x).normalized()

	var bend_amount: float = distance * curve_strength * slack * 0.5
	var control1 := start_point + start_tangent * handle_length + bend_direction * bend_amount
	var control2 := end_point - end_tangent * handle_length + bend_direction * bend_amount

	plug1.global_position = start_point
	plug2.global_position = end_point
	plug1.global_rotation = node1_local_angle_offset + (control1 - start_point).angle()
	plug2.global_rotation = node2_local_angle_offset + (end_point - control2).angle()


func _get_socket_point(anchor: Node2D, local_offset: Vector2, local_angle_offset: float) -> Vector2:
	var anchor_point := anchor.to_global(local_offset)
	var socket_direction := Vector2.RIGHT.rotated(anchor.global_rotation + local_angle_offset)
	return anchor_point + socket_direction * socket_length


func _cubic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, t: float) -> Vector2:
	var u: float = 1.0 - t
	var tt: float = t * t
	var uu: float = u * u
	var uuu: float = uu * u
	var ttt: float = tt * t
	return p0 * uuu + p1 * (3.0 * uu * t) + p2 * (3.0 * u * tt) + p3 * ttt


func _draw_pixel_curve(points: PackedVector2Array) -> void:
	var size: float = max(1.0, pixel_size)
	var half_size := Vector2.ONE * size * 0.5
	var step_size: float = max(1.0, size * 0.5)

	for i in range(points.size() - 1):
		var start := points[i]
		var end := points[i + 1]
		var span_length := start.distance_to(end)
		var span_steps: int = int(ceil(span_length / step_size))
		if span_steps < 1:
			span_steps = 1

		for step in range(span_steps + 1):
			var t: float = float(step) / float(span_steps)
			var snapped_global := _snap_to_pixel_grid(start.lerp(end, t))
			var point := to_local(snapped_global)
			draw_rect(Rect2(point - half_size, Vector2.ONE * size), cord_color)


func _snap_to_pixel_grid(point: Vector2) -> Vector2:
	return Vector2(round(point.x), round(point.y))
