@tool
extends GraphNode

@export var layer_number: int: get = _get_layer_number, set = _set_layer_number
@export var neurons_count: int: get = _get_neurons_count, set = _set_neurons_count

var neurons: Array[Neuron] = []

func _get_layer_number() -> int:
	return layer_number

func _set_layer_number(value: int) -> void:
	self.title = Global.get_layer_name(value)
	layer_number = value

func _get_neurons_count() -> int:
	return neurons_count

func _set_neurons_count(value: int) -> void:
	value = max(value, 0)
	for i in range(value):
		if self.get_child_count() - 1 >= i:
			continue
		var neuron: Neuron = SceneManager.create_scene_instance("neuron")
		neurons.append(neuron)
		neuron.set_meta("layer", layer_number)
		neuron.id = i
		self.set_slot(i, true, 0, Color("#2b9900"), true, 0, Color("#00a7ec"))
		self.add_child(neuron)

	var difference = self.get_child_count() - value
	for i in range(difference):
		neurons.pop_back().queue_free()
	neurons_count = value

func _ready():
	self.title = Global.get_layer_name(layer_number)
