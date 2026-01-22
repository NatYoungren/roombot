## Global singleton to hold game information
extends Node

var current_level: Node2D
# var all_roombas: Array = []

var money: float:
    set(value):
        money = value
        money_updated.emit(money)

signal money_updated(new_amount: float)


# TODO: Make a filth_manager, to manage multiple filth_layers.
var filth_layer: FilthLayer # Reference to the filth layer in the current level
