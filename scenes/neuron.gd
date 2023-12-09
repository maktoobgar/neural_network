@tool
extends GraphNode

class_name Neuron

var id: int: set = _set_id, get = _get_id
var net: float: set = _set_net, get = _get_net
var output: float: set = _set_output, get = _get_output

func _set_id(value: int) -> void:
	self.title = Global.get_neuron_name(value + 1)
	id = value

func _get_id() -> int:
	return id

func _set_net(value: float) -> void:
	%Net.value = str(value)

func _get_net() -> float:
	return float(%Net.value)

func _set_output(value: float) -> void:
	%Output.value = str(value)

func _get_output() -> float:
	return float(%Output.value)

func _on_close_request():
	%Details.visible = true
	%ValuesContainer.visible = false
	self.size.y = 0

func _on_show_button_up():
	%Details.visible = false
	%ValuesContainer.visible = true
