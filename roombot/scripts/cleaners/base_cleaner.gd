## Base class for all cleaner nodes.
class_name BaseCleaner extends Node2D

func clean(_filth_layer: Node2D) -> float:
	push_error("BaseCleaner.clean_filth: This method should be overridden in subclasses.")
	return 0.0
