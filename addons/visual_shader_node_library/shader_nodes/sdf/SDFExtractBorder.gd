tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeSDFExtractBorder

func _get_name():
	return "SDFExtractBorder"

func _get_category():
	return "SDF"

func _get_subcategory():
	return "Modifiers"

func _get_description():
	return """Returns a signed distance field of a border of a shape represented by a signed distance field"""

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_SCALAR

enum Inputs {
	DISTANCE,
	HALF_WIDTH,
	
	I_COUNT
};
const INPUT_NAMES = ["distance", "half-width"]
const INPUT_TYPES = [
	VisualShaderNode.PORT_TYPE_SCALAR,
	VisualShaderNode.PORT_TYPE_SCALAR
]

func _get_input_port_count():
	return Inputs.I_COUNT

func _get_input_port_name(port):
	return INPUT_NAMES[port]

func _get_input_port_type(port):
	return INPUT_TYPES[port]

enum Outputs {
	DISTANCE,
	
	O_COUNT
};

const OUTPUT_NAMES = ["distance"]
const OUTPUT_TYPES = [
	VisualShaderNode.PORT_TYPE_SCALAR
]

func _get_output_port_count():
	return Outputs.O_COUNT

func _get_output_port_name(port):
	return OUTPUT_NAMES[port]

func _get_output_port_type(port):
	return OUTPUT_TYPES[port]

func _get_global_code(mode):
	return ""

func _get_code(input_vars, output_vars, mode, type):
	return """
	{distance} = abs({input}) - {halfWidth};
	""".format({
		"input": input_vars[Inputs.DISTANCE],
		"halfWidth": input_vars[Inputs.HALF_WIDTH],
		"distance": output_vars[Outputs.DISTANCE]
	})

func _init():
	if not get_input_port_default_value(Inputs.HALF_WIDTH):
		set_input_port_default_value(Inputs.HALF_WIDTH, 0.05)
