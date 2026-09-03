## Global singleton to hold game information
extends Node

# TODO: Add a 'freeze', which lets you select and adjust roomba settings.


var current_level: Node2D

# TODO: Make a filth_manager, to manage multiple filth_layers?
var filth_layer: FilthLayer # Reference to the filth layer in the current level

var all_roombas: Array = []

var selected_object: Node2D
signal selected(obj: Node2D, is_selected: bool)


var money: float:
	set(value):
		money = value
		money_updated.emit(money)

signal money_updated(new_amount: float)


func _process(_delta: float) -> void:
	# # #
	# DEBUG (MOVE THESE TO A GLOBAL/SINGLETON INPUT HANDLER FILE?)

	# Press SPACE to completely fill filth layer, for testing.
	if Input.is_action_just_pressed("ui_accept"):
		filth_layer.debug_fill_image()
	
	# Press LEFT to add random junk filth, for testing.
	if Input.is_action_just_pressed("ui_left"):
		filth_layer.random_junk()

	# On ESC, deselect any selected object.
	if Input.is_action_just_pressed("ui_cancel"):
		_change_selection(null)
	
	# On TAB, cycle select through roombas
	#	If holding shift, cycle backwards.
	if Input.is_action_just_pressed("ui_focus_next"):
		if all_roombas.is_empty():
			_change_selection(null)
			return
		
		var step: int = -1 if Input.is_key_pressed(KEY_SHIFT) else 1
		
		if selected_object == null:
			_change_selection(all_roombas[0] if step > 0 else all_roombas[-1])
		else:
			var idx: int = all_roombas.find(selected_object)
			if idx == -1:
				_change_selection(all_roombas[0] if step > 0 else all_roombas[-1])
			else:
				idx = (idx + step) % all_roombas.size()
				if idx < 0:
					idx += all_roombas.size()
				_change_selection(all_roombas[idx])


func _on_clicked_default(roomba: RoombaBase, button: int) -> void:
	# print("Roomba clicked! Button: ", button)
	if button == MOUSE_BUTTON_LEFT:
		_change_selection(roomba) # Select / display information w/ HUD
	elif button == MOUSE_BUTTON_RIGHT:
		roomba.turn_dir *= -1 # Reverse turn direction

func _change_selection(object: Node2D) -> void:
	if selected_object is RoombaBase:
		selected_object.update_select.emit(false)
		selected.emit(selected_object, false)

	selected_object = object

	if selected_object is RoombaBase:
		selected_object.update_select.emit(true)

	selected.emit(selected_object, true)
	
func _register_roomba(roomba: RoombaBase) -> void:
	all_roombas.append(roomba)
