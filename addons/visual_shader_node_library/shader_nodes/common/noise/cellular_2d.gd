tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeCellularNoise2D

enum Params {
	OFFSET,
	SCALE,
	JITTER,

	P_COUNT
}

const PARAM_NAMES = ["offset", "scale", "jitter"];
const PARAM_TYPES = [
	VisualShaderNode.PORT_TYPE_VECTOR,
	VisualShaderNode.PORT_TYPE_VECTOR,
	VisualShaderNode.PORT_TYPE_SCALAR
]

enum Outputs {
	COMPOSITE,
	F1,
	F2,

	O_COUNT
}

const OUTPUT_NAMES = ["composite", "f1", "f2"];
const OUTPUT_TYPES = [
	VisualShaderNode.PORT_TYPE_VECTOR,
	VisualShaderNode.PORT_TYPE_SCALAR,
	VisualShaderNode.PORT_TYPE_SCALAR
]

func _get_name():
	return "CellularNoise2D"

func _get_category():
	return "Common"

func _get_subcategory():
	return "Noise"

func _get_description():
	return "Cellular noise (\"Worley noise\")"

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_input_port_count():
	return Params.P_COUNT

func _get_input_port_name(port):
	return PARAM_NAMES[port]

func _get_input_port_type(port):
	return PARAM_TYPES[port]

func _get_output_port_count():
	return Outputs.O_COUNT

func _get_output_port_name(port):
	return OUTPUT_NAMES[port]

func _get_output_port_type(port):
	return OUTPUT_TYPES[port]

func _get_global_code(mode):
	var code = preload("cellular_2d.shader").code
	code = code.replace("shader_type spatial;", "")
	return code

func _get_code(input_vars, output_vars, mode, type):
	var offset = input_vars[Params.OFFSET];
	
	if not offset:
		offset = "vec2(0.0, 0.0)"
	else:
		offset = "(%s).xy" % [offset]

	if input_vars[Params.SCALE]:
		offset = "%s * (%s).xy" % [offset, input_vars[Params.SCALE]]

	var jitter = input_vars[Params.JITTER]
	
	if not jitter:
		jitter = "0.5"
		
	var c_output = output_vars[Outputs.COMPOSITE];
	var c_decl = "";
	
	if not c_output:
		c_output = "composite_value";
		c_decl = "vec3 %s;" % c_output;
		
	var f1_assign = ""

	if output_vars[Outputs.F1]:
		f1_assign = "%s = %s.x;" % [output_vars[Outputs.F1], c_output]
	
	var f2_assign = ""
	
	if output_vars[Outputs.F2]:
		f2_assign = "%s = %s.y;" % [output_vars[Outputs.F2], c_output]

	return """
	%s
	%s = vec3(cellular_noise_2d(%s, %s), 0.0);
	%s%s
	""" % [
		c_decl,
		output_vars[0], offset, jitter,
		f1_assign, f2_assign
	]
