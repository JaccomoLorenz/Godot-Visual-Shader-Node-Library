tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeSDFCircle

func _get_name():
	return "SDFFieldCircle"

func _get_category():
	return "SDF"

func _get_subcategory():
	return "Fields"

func _get_description():
	return """Signed distance field of a circle"""

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_SCALAR

enum Inputs {
	UV,
	RADIUS,
	CENTER,
	
	I_COUNT
};
const INPUT_NAMES = ["uv", "radius", "center"]
const INPUT_TYPES = [
	VisualShaderNode.PORT_TYPE_VECTOR,
	VisualShaderNode.PORT_TYPE_SCALAR,
	VisualShaderNode.PORT_TYPE_VECTOR
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
	{distance} = length({uv} - {center}) - {radius};
	""".format({
		"uv": input_vars[Inputs.UV],
		"radius": input_vars[Inputs.RADIUS],
		"center": input_vars[Inputs.CENTER],
		"distance": output_vars[Outputs.DISTANCE]
	})

func _init():
	if not get_input_port_default_value(Inputs.RADIUS):
		set_input_port_default_value(Inputs.RADIUS, 0.5)
	if not get_input_port_default_value(Inputs.CENTER):
		set_input_port_default_value(Inputs.CENTER, Vector3(0,0,0))
