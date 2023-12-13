@tool
extends GraphNode

class_name InputOutput

var id: int: set = _set_id, get = _get_id
var value: float: set = _set_value, get = _get_value
var desired_output: float: set = _set_desired_output, get = _get_desired_output
var activation_function: String: set = _set_activation_function, get = _get_activation_function

func _ready() -> void:
	var layer_type = self.get_meta("layer_type", Global.LayerType.NeuronsInput)
	if layer_type == Global.LayerType.NeuronsOutput:
		%DesiredOutput.visible = true
		%ActivationFunction.visible = true
		%Value.editable = false

func _set_id(value: int) -> void:
	self.title = Global.get_input_output_name(value + 1)
	id = value

func _get_id() -> int:
	return id

func _set_color(active: bool) -> void:
	var theme_color = Color("#89ff81") if active else Color("#ff7664")
	self.add_theme_color_override("title_color", theme_color)

func _reset_color() -> void:
	self.remove_theme_color_override("title_color")

func _set_value(value: float) -> void:
	if !self.is_node_ready():
		await self.ready
	if activation_function == "Same":
		%Value.value = str(value)
		_reset_color()
	elif activation_function == "Out>0":
		%Value.value = str(1.0 if value > 0.0 else 0.0)
		_set_color(value > 0.0)
	elif activation_function == "Out>0.5":
		%Value.value = str(1.0 if value > 0.5 else 0.0)
		_set_color(value > 0.5)

func _get_value() -> float:
	return float(%Value.value)

func _set_desired_output(value: float) -> void:
	%DesiredOutput.value = str(value)

func _get_desired_output() -> float:
	return float(%DesiredOutput.value)

func _set_activation_function(value: String) -> void:
	%ActivationFunction.value = value

func _get_activation_function() -> String:
	return %ActivationFunction.value

func update_value(value: float) -> void:
	self.value = value
