@tool
extends GraphNode

class_name InputOutput

var id: int: set = _set_id, get = _get_id
var value: float: set = _set_value, get = _get_value

func _set_id(value: int) -> void:
	self.title = Global.get_input_output_name(value + 1)
	id = value

func _get_id() -> int:
	return id

func _set_value(value: float) -> void:
	if !self.is_node_ready():
		await self.ready
	%Value.text = value

func _get_value() -> float:
	return float(%Value.text)
