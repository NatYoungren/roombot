extends Label

var selected_object: Node2D

func _ready() -> void:
	State.selected.connect(_on_selected_object_changed)

	
func _process(_delta: float) -> void:
	if selected_object is RoombaBase:
		var roomba: RoombaBase = selected_object
		text = "Filth cleaned: %.2f" % roomba.filth_cleaned
		text += "\nMoney earned: $%.2f" % (roomba.filth_cleaned * roomba.filth_to_money_ratio)
		text += "\n$ per Second: $%.2f" % (roomba.filth_cleaned * roomba.filth_to_money_ratio / roomba.time_elapsed)
		text += "\nSpeed: %.2f px/s" % roomba.velocity.length()
	else:
		text = ""

func _on_selected_object_changed(obj: Node2D, is_selected: bool) -> void:
	if not is_selected or obj == null or not obj is RoombaBase:
		selected_object = null
		text = ""
		return
	
	selected_object = obj

	if obj is RoombaBase:
		var roomba: RoombaBase = obj
		text = "Filth cleaned: " + str(roomba.filth_cleaned) + "\nMoney earned: $" + str(roomba.filth_cleaned * roomba.filth_to_money_ratio)
