@tool
extends GraphNode

class_name Neuron

var id: int = 0
var net: float: set = _set_net, get = _get_net
var output: float: set = _set_output, get = _get_output

func _set_net(value: float) -> void:
	%Net.value = str(value)

func _get_net() -> float:
	return float(%Net.value)

func _set_output(value: float) -> void:
	%Output.value = str(value)

func _get_output() -> float:
	return float(%Output.value)
