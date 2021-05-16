tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeSDFRectangle

func _get_name():
	return "SDFFieldRectangle"

func _get_category():
	return "SDF"

func _get_subcategory():
	return "Fields"

func _get_description():
	return """Signed distance field of a rectangle"""

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_SCALAR

enum Inputs {
	UV,
	SIZE,
	CENTER,
	CORNER_RADIUS,
	
	I_COUNT
};
const INPUT_NAMES = ["uv", "half-size", "center", "corner radius"]
const INPUT_TYPES = [
	VisualShaderNode.PORT_TYPE_VECTOR,
	VisualShaderNode.PORT_TYPE_VECTOR,
	VisualShaderNode.PORT_TYPE_VECTOR,
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
	vec2 cd = abs({uv}.xy - {center}.xy) - {hsize}.xy + {radius};
	float od = length(max(cd, vec2(0.0)));
	float id = min(0.0, max(cd.x, cd.y));
	
	{distance} = od + id - {radius};
	""".format({
		"uv": input_vars[Inputs.UV],
		"hsize": input_vars[Inputs.SIZE],
		"center": input_vars[Inputs.CENTER],
		"radius": input_vars[Inputs.CORNER_RADIUS],
		"distance": output_vars[Outputs.DISTANCE]
	})

func _init():
	if not get_input_port_default_value(Inputs.CORNER_RADIUS):
		set_input_port_default_value(Inputs.CORNER_RADIUS, 0.0)
	if not get_input_port_default_value(Inputs.SIZE):
		set_input_port_default_value(Inputs.SIZE, Vector3(0.5, 0.5, 0.0))
	if not get_input_port_default_value(Inputs.CENTER):
		set_input_port_default_value(Inputs.CENTER, Vector3(0.0, 0.0, 0.0))
