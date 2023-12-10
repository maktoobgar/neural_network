@tool
extends GraphNode

class_name InputOutputLayer

@export var layer_type: Global.LayerType = 0: get = _get_layer_type, set = _set_layer_type
@export var inputs_outputs_count: int = 0: get = _get_inputs_outputs_count, set = _set_inputs_outputs_count

var inputs_outputs: Array[InputOutput] = []

func _get_layer_type() -> Global.LayerType:
	return layer_type

func _set_layer_type(value: Global.LayerType) -> void:
	for i in range(self.get_child_count()):
		self.get_child(i).set_meta("layer_type", value)
		if value == Global.LayerType.NeuronsInput:
			self.set_slot(i, false, 0, Color("#2b9900"), true, 0, Color("#00a7ec"))
		elif value == Global.LayerType.NeuronsOutput:
			self.set_slot(i, true, 0, Color("#2b9900"), false, 0, Color("#00a7ec"))
	self.title = Global.get_input_output_layer_name(value)
	layer_type = value

func _get_inputs_outputs_count() -> int:
	return inputs_outputs_count

func _set_inputs_outputs_count(value: int) -> void:
	if !self.is_node_ready():
		await self.ready
	value = max(value, 0)
	var children_count = self.get_child_count() - 1
	for i in range(value):
		if children_count >= i:
			continue
		var input_output: InputOutput = SceneManager.create_scene_instance("input_output")
		inputs_outputs.append(input_output)
		input_output.set_meta("layer_type", layer_type)
		input_output.id = i
		if layer_type == Global.LayerType.NeuronsInput:
			self.set_slot(i, false, 0, Color("#2b9900"), true, 0, Color("#00a7ec"))
		elif layer_type == Global.LayerType.NeuronsOutput:
			self.set_slot(i, true, 0, Color("#2b9900"), false, 0, Color("#00a7ec"))
		self.add_child(input_output)

	var difference = self.get_child_count() - value
	for i in range(difference):
		inputs_outputs.pop_back().queue_free()
	inputs_outputs_count = value

func _ready():
	self.title = Global.get_input_output_layer_name(layer_type)
