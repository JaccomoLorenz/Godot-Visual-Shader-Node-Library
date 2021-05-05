tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeSDFPatternHexTiles

func _get_name():
	return "SDFPatternHexTiles"

func _get_category():
	return "SDF"

func _get_subcategory():
	return "Patterns"

func _get_description():
	return """Hexagonal tiles pattern.
For a pixel coordinates returs a signed distance to nearest hexagon edges by all 3 axes.
Also returns three numbers uniquely identifying a tile the pixel belongs to.
"""

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_VECTOR

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
	DISTANCES,
	DISTANCE_A,
	DISTANCE_B,
	DISTANCE_C,
	TILE_ID,

	O_COUNT
};

const OUTPUT_NAMES = ["distances", "distance a", "distance b", "distance c", "tile id"]
const OUTPUT_TYPES = [
	VisualShaderNode.PORT_TYPE_VECTOR,
	VisualShaderNode.PORT_TYPE_SCALAR,
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
	var code = preload("SDFHexagonPattern.shader").code
	code = code.replace("shader_type spatial;", "")
	return code

func _get_code(input_vars, output_vars, mode, type):
	var border_size = input_vars[1]
	
	if not border_size:
		border_size = "vec3(0.1, 0.1, 0.1)"

	return """
		hexagon_pattern({offset}.xy, {border_size}, {o_distances}, {o_id});
		{o_dst_a} = {o_distances}.x;
		{o_dst_b} = {o_distances}.y;
		{o_dst_c} = {o_distances}.z;
	""".format({
		"offset": input_vars[Inputs.UV],
		"border_size": border_size,
		"o_distances": output_vars[Outputs.DISTANCES],
		"o_id": output_vars[Outputs.TILE_ID],
		"o_dst_a": output_vars[Outputs.DISTANCE_A],
		"o_dst_b": output_vars[Outputs.DISTANCE_B],
		"o_dst_c": output_vars[Outputs.DISTANCE_C],
	})
