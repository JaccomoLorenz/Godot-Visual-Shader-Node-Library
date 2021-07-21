tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeToPolar2D

func _get_name():
	return "ToPolar2D"

func _get_category():
	return "Common"

func _get_subcategory():
	return "Misc"

func _get_description():
	return "Converts 2D cartesian coordinates to polar coordinates"

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_VECTOR

enum Inputs {
	XY,
	ORIGIN,

	I_COUNT
};
const INPUT_NAMES = ["xy", "origin"];
const INPUT_TYPES = [
	VisualShaderNode.PORT_TYPE_VECTOR,
	VisualShaderNode.PORT_TYPE_VECTOR
];

func _get_input_port_count():
	return Inputs.I_COUNT

func _get_input_port_name(port):
	return INPUT_NAMES[port]

func _get_input_port_type(port):
	return INPUT_TYPES[port]

enum Outputs {
	POLAR,
	A,
	D,
	
	O_COUNT
}

const OUTPUT_NAMES = ["polar", "a", "d"];
const OUTPUT_TYPES = [
	VisualShaderNode.PORT_TYPE_VECTOR,
	VisualShaderNode.PORT_TYPE_SCALAR,
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
	var origin = input_vars[Inputs.ORIGIN]
	
	if origin:
		origin = " - %s.xy" % [origin]
	else:
		origin = ""

	return """
		vec2 xy = %s.xy%s;
		float a = atan(xy.x, xy.y);
		float d = length(xy);
		%s = vec3(a, d, 0.0);
		%s = a;
		%s = d;
	""" % [input_vars[Inputs.XY], origin, output_vars[Outputs.POLAR], output_vars[Outputs.A], output_vars[Outputs.D]]
