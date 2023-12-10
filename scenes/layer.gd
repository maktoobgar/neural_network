@tool
extends GraphNode

@export var layer_number: int = 1: get = _get_layer_number, set = _set_layer_number
@export var neurons_count: int: get = _get_neurons_count, set = _set_neurons_count

var neurons: Array[Neuron] = []

func _get_layer_number() -> int:
	return layer_number

func _set_layer_number(value: int) -> void:
	if !self.is_node_ready():
		await self.ready
	self.title = Global.get_layer_name(value)
	layer_number = value

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
		neurons.append(neuron)
		neuron.set_meta("layer_number", layer_number)
		neuron.set_meta("layer_type", Global.LayerType.Neurons)
		neuron.id = i
		neuron.activation_function = %ActivationFunction.value
		self.set_slot(i + 1, true, 0, Color("#2b9900"), true, 0, Color("#00a7ec"))
		self.add_child(neuron)

	var difference = (self.get_child_count() - 1) - value
	for i in range(difference):
		neurons.pop_back().queue_free()
	neurons_count = value

func _ready():
	self.title = Global.get_layer_name(layer_number)

func _on_activation_function_item_selected(inputControl: InputControl):
	for i in range(self.get_child_count()):
		if i == 0:
			continue
		var neuron: Neuron = self.get_child(i)
		neuron.activation_function = inputControl.value
