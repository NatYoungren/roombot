## Global singleton for utility methods
extends Node

func turn_towards(angle: float, target_angle: float, radians: float) -> float:
	var difference: float = wrapf(target_angle - angle, -PI, PI)
	if abs(difference) <= radians: return target_angle # NOTE: Not necessary.
	difference = clampf(difference, -radians, radians)
	return angle + difference
