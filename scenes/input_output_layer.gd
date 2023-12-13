@tool
extends GraphNode

class_name InputOutputLayer

@export var layer_type: Global.LayerType = 0: get = _get_layer_type, set = _set_layer_type
@export var inputs_outputs_count: int = 0: get = _get_inputs_outputs_count, set = _set_inputs_outputs_count
var activation_function: String: get = _get_activation_function

var inputs_outputs: Array[InputOutput] = []

func _get_layer_type() -> Global.LayerType:
	return layer_type

func _set_layer_type(value: Global.LayerType) -> void:
	if !self.is_node_ready():
		await self.ready
	for i in range(self.get_child_count()):
		if i == 0:
			self.set_slot(i, false, 0, Color("#2b9900"), false, 0, Color("#00a7ec"))
			continue
		self.get_child(i).set_meta("layer_type", value)
		if value == Global.LayerType.NeuronsInput:
			self.set_slot(i, false, 0, Color("#2b9900"), true, 0, Color("#00a7ec"))
		elif value == Global.LayerType.NeuronsOutput:
			self.set_slot(i, true, 0, Color("#2b9900"), false, 0, Color("#00a7ec"))
	self.title = Global.get_input_output_layer_name(value)
	if value == Global.LayerType.NeuronsOutput:
		%ActivationFunction.visible = true
	else:
		%ActivationFunction.visible = false
	layer_type = value

func _get_inputs_outputs_count() -> int:
	return inputs_outputs_count

func _set_inputs_outputs_count(value: int) -> void:
	if !self.is_node_ready():
		await self.ready
	value = max(value, 0)
	var children_count = max(self.get_child_count() - 2, -1)
	for i in range(value):
		if children_count >= i:
			continue
		var input_output: InputOutput = SceneManager.create_scene_instance("input_output")
		inputs_outputs.append(input_output)
		input_output.set_meta("layer_type", layer_type)
		input_output.id = i
		if layer_type == Global.LayerType.NeuronsInput:
			self.set_slot(i + 1, false, 0, Color("#2b9900"), true, 0, Color("#00a7ec"))
		elif layer_type == Global.LayerType.NeuronsOutput:
			self.set_slot(i + 1, true, 0, Color("#2b9900"), false, 0, Color("#00a7ec"))
		self.add_child(input_output)

	var difference = (self.get_child_count() - 1) - value
	for i in range(difference):
		inputs_outputs.pop_back().queue_free()
	inputs_outputs_count = value

func _get_activation_function() -> String:
	return %ActivationFunction.value

func _on_activation_function_item_selected(inputControl: InputControl):
	for input_output in inputs_outputs:
		input_output.activation_function = activation_function
