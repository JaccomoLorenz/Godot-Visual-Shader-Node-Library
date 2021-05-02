tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeSDFMergeRound

func _get_name():
	return "SDFRoundMerge"

func _get_category():
	return "SDF"

func _get_subcategory():
	return "Operations"

func _get_description():
	return ""

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_input_port_count():
	return 3

func _get_input_port_name(port):
	match port:
		0: return "input1"
		1: return "input2"
		2: return "radius"

func _get_input_port_type(port):
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_output_port_count():
	return 1

func _get_output_port_name(port):
	return "result"

func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_global_code(mode):
	return ""

func _get_code(input_vars, output_vars, mode, type):
	return """
		float i1 = %s;
		float i2 = %s;
		float r = %s;
		vec2 is = min(vec2(0), vec2(i1 - r, i2 - r));
		%s = max(min(i1, i2), r) - length(is);
	""" % [input_vars[0], input_vars[1], input_vars[2], output_vars[0]]
