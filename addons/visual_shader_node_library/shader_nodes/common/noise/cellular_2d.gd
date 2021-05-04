tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeCellularNoise2D

enum Inputs {
	OFFSET,
	SCALE,
	JITTER,

	I_COUNT
}

const INPUT_NAMES = ["offset", "scale", "jitter"];
const INPUT_TYPES = [
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
	return "Textureless 2D cellular noise (\"Worley noise\")"

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_input_port_count():
	return Inputs.I_COUNT

func _get_input_port_name(port):
	return INPUT_NAMES[port]

func _get_input_port_type(port):
	return INPUT_TYPES[port]

func _get_output_port_count():
	return Outputs.O_COUNT

func _get_output_port_name(port):
	return OUTPUT_NAMES[port]

func _get_output_port_type(port):
	return OUTPUT_TYPES[port]

func _get_global_code(mode):
	var code = preload("cellular_2d.shader").code
	code = code.replace("shader_type spatial;", "")
	code = code.replace("HELPER_", "HELPER_%s_" % [self._get_name()])
	return code

func _get_code(input_vars, output_vars, mode, type):
	var offset = input_vars[Inputs.OFFSET];
	
	if not offset:
		offset = "vec2(0.0, 0.0)"
	else:
		offset = "(%s).xy" % [offset]

	offset = "%s * (%s).xy" % [offset, input_vars[Inputs.SCALE]]

	var jitter = input_vars[Inputs.JITTER]

	var c_output = output_vars[Outputs.COMPOSITE];
		
	var f1_assign = "%s = %s.x;" % [output_vars[Outputs.F1], c_output]
	var f2_assign = "%s = %s.y;" % [output_vars[Outputs.F2], c_output]

	return """
	%s = vec3(cellular_noise_2d(%s, %s), 0.0);
	%s
	%s
	""" % [
		output_vars[0], offset, jitter,
		f1_assign, f2_assign
	]

func _init():
	if not get_input_port_default_value(Inputs.SCALE):
		set_input_port_default_value(Inputs.SCALE, Vector3(1.0, 1.0, 1.0))
	if not get_input_port_default_value(Inputs.JITTER):
		set_input_port_default_value(Inputs.JITTER, 0.5)
