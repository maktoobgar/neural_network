extends Node

var inputs_count: int = 0
var learning_rate: float = 0
var layers_count: int = 0
var epoch: int = 0
var activation_function: String = ""

var nc_of_each_layer: Array[int] = []

func get_inputs() -> void:
	inputs_count = int(%InputCount.value)
	learning_rate = min(float(%LearningRate.value), 1.0)
	layers_count = int(%LayersCount.value)
	epoch = max(int(%Epoch.value), 0)
	activation_function = %ActivationFunction.value
	%InputCount.value = str(inputs_count)
	%LearningRate.value = str(learning_rate)
	%LayersCount.value = str(layers_count)
	%Epoch.value = str(epoch)

func are_inputs_valid() -> bool:
	if inputs_count > 0 && learning_rate > 0 && layers_count > 0 && epoch > 0 && activation_function != "None":
		var all_valid = true
		for i in range(%LayersContainer.get_child_count()):
			var node = %LayersContainer.get_child(i)
			nc_of_each_layer[i] = int(node.value)
			if nc_of_each_layer[i] <= 0:
				all_valid = false
		if all_valid:
			return true
	%Popup.title = "Validation Error"
	%Popup.dialog_text = "Not all input fields are valid"
	%Popup.popup_centered()
	return false

func _on_apply_changes_button_up():
	get_inputs()
	if are_inputs_valid():
		print('valid')

func _on_layers_count_text_changed(inputControl: InputControl):
	var count = int(%LayersCount.value)
	for i in range(count):
		if %LayersContainer.get_child_count() - 1 >= i:
			continue
		var input: InputControl = SceneManager.create_scene_instance("input")
		input.text = "NC Layer " + str(i + 1) + ":"
		input.set_meta("layer", i + 1)
		input.force_int = true
		input.text_changed.connect(_layer_text_changed)
		nc_of_each_layer.append(0)
		input.initial_value = "0"
		%LayersContainer.add_child(input)

	var difference = %LayersContainer.get_child_count() - count
	for i in range(difference):
		nc_of_each_layer.pop_back()
		%LayersContainer.remove_child(%LayersContainer.get_child(%LayersContainer.get_child_count() - 1))

func _layer_text_changed(inputControl: InputControl) -> void:
	var value = int(inputControl.value)
	var layer = inputControl.get_meta("layer")
	nc_of_each_layer[layer-1] = value

func _on_neurons_connection_request(from_node, from_port, to_node, to_port):
	%Neurons.connect_node(from_node, from_port, to_node, to_port)
