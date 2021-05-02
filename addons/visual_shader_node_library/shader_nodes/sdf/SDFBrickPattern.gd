tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeSDFPatternBrick

func _get_name():
	return "SDFPatternBrick"

func _get_category():
	return "SDF"

func _get_subcategory():
	return "Patterns"

func _get_description():
	return """Regular brick wall pattern function.
For a pixel coordinates returs a signed distance to nearest brick edge by X and Y axes.
Also returns two numbers uniquely identifying a brick the pixel belongs to.
"""

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_SCALAR

enum Inputs {
	UV,
	BORDER_SIZE,
	
	I_COUNT
};
const INPUT_NAMES = ["uv", "border size"]
const INPUT_TYPES = [
	VisualShaderNode.PORT_TYPE_VECTOR,
	VisualShaderNode.PORT_TYPE_VECTOR
]

func _get_input_port_count():
	return Inputs.I_COUNT

func _get_input_port_name(port):
	return INPUT_NAMES[port]

func _get_input_port_type(port):
	return INPUT_TYPES[port]

enum Outputs {
	DISTANCE_XY,
	DISTANCE_X,
	DISTANCE_Y,
	BRICK_ID,
	
	O_COUNT
};

const OUTPUT_NAMES = ["distance xy", "distance x", "distance y", "brick id"]
const OUTPUT_TYPES = [
	VisualShaderNode.PORT_TYPE_VECTOR,
	VisualShaderNode.PORT_TYPE_SCALAR,
	VisualShaderNode.PORT_TYPE_SCALAR,
	VisualShaderNode.PORT_TYPE_VECTOR
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
	var border_size = input_vars[1]
	
	if not border_size:
		border_size = "vec2(0.1, 0.1)"
	else:
		border_size = "%s.xy" % [border_size]

	return """
		vec2 uv = %s.xy * vec2(1.0, 2.0);
		vec2 size = %s;
		vec2 bid;
		
		bid.y = floor(uv.y);
		uv.x += bid.y * 0.5;
		
		bid.x = floor(uv.x);
		
		uv = fract(uv);
		vec2 res = size - min(uv, vec2(1.0) - uv) * vec2(1.0, 0.5);
		%s = vec3(res, 0.0);
		%s = res.x;
		%s = res.y;
		%s = vec3(bid, 0.0);
	""" % [
		input_vars[Inputs.UV], border_size,
		output_vars[Outputs.DISTANCE_XY],
		output_vars[Outputs.DISTANCE_X],
		output_vars[Outputs.DISTANCE_Y],
		output_vars[Outputs.BRICK_ID]
	]
