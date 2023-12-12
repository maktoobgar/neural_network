@tool
extends GraphNode

class_name Layer

@export var layer_id: int = 1: get = _get_layer_id, set = _set_layer_id
@export var neurons_count: int: get = _get_neurons_count, set = _set_neurons_count

var activation_function: String: set = _set_activation_function, get = _get_activation_function
var all_neurons: Array[Neuron] = []
var final_layer: bool = false
var manager: Manager = null

func _set_activation_function(value: String) -> void:
	%ActivationFunction.value = value

func _get_activation_function() -> String:
	return %ActivationFunction.value

func _get_layer_id() -> int:
	return layer_id

func _set_layer_id(value: int) -> void:
	if !self.is_node_ready():
		await self.ready
	self.title = Global.get_layer_name(value)
	layer_id = value

func _get_neurons_count() -> int:
	return neurons_count

func _set_neurons_count(value: int) -> void:
	if !self.is_node_ready():
		await self.ready
	value = max(value, 0)
	var children_count = max(self.get_child_count() - 2, -1)
	for i in range(value):
		if children_count >= i:
			continue
		var neuron: Neuron = SceneManager.create_scene_instance("neuron")
		all_neurons.append(neuron)
		neuron.set_meta("layer_id", layer_id)
		neuron.set_meta("layer_type", Global.LayerType.Neurons)
		neuron.id = i
		neuron.activation_function = activation_function
		neuron.layer_node = self
		self.set_slot(i + 1, true, 0, Color("#2b9900"), true, 0, Color("#00a7ec"))
		self.add_child(neuron)

	var difference = (self.get_child_count() - 1) - value
	for i in range(difference):
		all_neurons.pop_back().free()
	neurons_count = value
	self.size.y = 0

func _ready():
	self.title = Global.get_layer_name(layer_id)

func _on_activation_function_item_selected(inputControl: InputControl):
	for i in range(self.get_child_count()):
		if i == 0:
			continue
		var neuron: Neuron = self.get_child(i)
		neuron.activation_function = inputControl.value

func feed_forward_all_nodes() -> void:
	for neuron in all_neurons:
		neuron.feed_forward()

func calculate_delta_all_nodes() -> void:
	for neuron in all_neurons:
		neuron.calculate_delta()

func feed_backward_all_nodes() -> void:
	for neuron in all_neurons:
		neuron.feed_backward()
