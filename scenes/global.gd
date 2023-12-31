@tool
extends Node

var learning_point: Array = []

enum LayerType {NeuronsInput, NeuronsOutput, Neurons}
var layers = {
	0: "",
	1: "First",
	2: "Second",
	3: "Third",
	4: "Fourth",
	5: "Fifth",
	6: "Sixth",
	7: "Seventh",
	8: "Eighth",
	9: "Ninth",
	10: "Tenth",
	11: "Eleventh",
	12: "Twelfth",
	13: "Thirteenth",
	14: "Fourteenth",
	15: "Fifteenth",
	16: "Sixteenth",
	17: "Seventeenth",
	18: "Eighteenth",
	19: "Nineteenth",
	20: "Twenty",
	30: "Thirthy",
	40: "Forty",
	50: "Fifty",
	60: "Sixty",
	70: "Seventy",
	80: "Eighty",
	90: "Ninety"
}

func get_layer_name(num) -> String:
	if num > 99:
		return "Invalid Number"
	if num > 20:
		return (layers.get((num/10)*10, "Invalid Number") + " " + layers.get(num%10, "Invalid Number") + " Layer").replace("  ", " ")
	return layers.get(num, "Invalid Number") + " Layer"

func get_input_output_layer_name(type: LayerType) -> String:
	return LayerType.keys()[type].replace("Neurons", "") + " Layer"

func get_input_output_name(num: int) -> String:
	if num > 99:
		return "99+"
	if num > 20:
		return (layers.get((num/10)*10, "Invalid Number") + " " + layers.get(num%10, "Invalid Number")).replace("  ", " ")
	return layers.get(num, "Invalid Number")

func get_neuron_name(num: int) -> String:
	if num > 99:
		return "99+ Neuron"
	if num > 20:
		return (layers.get((num/10)*10, "Invalid Number") + " " + layers.get(num%10, "Invalid Number") + " Neuron").replace("  ", " ")
	return layers.get(num, "Invalid Number") + " Neuron"

func none(input: float) -> float:
	return input

func sigmoid(input: float) -> float:
	return 1.0/(1.0+exp(-input))

func sigmoid_derivative(input: float) -> float:
	var y = sigmoid(input)
	return (1 - y) * y

func tanh_derivative(input: float) -> float:
	var y = tanh(input)
	return 1 - (y * y)

func gaussian(input: float, variance: float) -> float:
	return exp(-(input * input)/(2 * variance))

func gaussian_derivative(input: float, variance: float) -> float:
	return gaussian(input, variance) * (-input/variance)

func linear(input: float) -> float:
	return input

func calculate_neuron_output(value: float, function_name: String, variance: float = 0.0) -> float:
	if function_name == "Sigmoid":
		return sigmoid(value)
	elif function_name == "Tanh":
		return tanh(value)
	elif function_name == "Gaussian":
		return gaussian(value, variance)
	elif function_name == "Linear":
		return linear(value)
	return none(value)

func calculate_derivative_neuron_output(value: float, function_name: String, variance: float = 0.0) -> float:
	if function_name == "Sigmoid":
		return sigmoid_derivative(value)
	elif function_name == "Tanh":
		return tanh_derivative(value)
	elif function_name == "Gaussian":
		return gaussian_derivative(value, variance)
	elif function_name == "Linear":
		return 1
	return none(value)
