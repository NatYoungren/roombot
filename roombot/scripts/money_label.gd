extends Label

func _ready() -> void:
	State.money_updated.connect(update_money_label)
	update_money_label(State.money)

func update_money_label(value: float) -> void:
	text = "$" + str(int(value))
