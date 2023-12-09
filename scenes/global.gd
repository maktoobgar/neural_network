@tool
extends Node

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
		return "Invalid number"
	if num > 20:
		return (layers.get((num/10)*10, "Invalid number") + " " + layers.get(num%10, "Invalid number") + " Layer").replace("  ", " ")
	return layers.get(num, "Invalid number") + " Layer"

func get_neuron_name(num) -> String:
	if num > 99:
		return "99+ Neuron"
	if num > 20:
		return (layers.get((num/10)*10, "Invalid number") + " " + layers.get(num%10, "Invalid number") + " Neuron").replace("  ", " ")
	return layers.get(num, "Invalid number") + " Neuron"
