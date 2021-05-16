tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeSDFIntersectChampfer

func _get_name():
	return "SDFChampferIntersect"

func _get_category():
	return "SDF"

func _get_subcategory():
	return "Operations"

func _get_description():
	return "Intersection of two SDF shapes, with champfered corners"

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_input_port_count():
	return 3

func _get_input_port_name(port):
	match port:
		0: return "input1"
		1: return "input2"
		2: return "champfer"

func _get_input_port_type(port):
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_output_port_count():
	return 1

func _get_output_port_name(port):
	return "result"

func _get_output_port_type(port):
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_code(input_vars, output_vars, mode, type):
	return """
		float cc = {c} + ({i1} + {i2}) * 0.70710678118;
		{res} = max(max({i1}, {i2}), cc);
	""".format({
		"i1": input_vars[0],
		"i2": input_vars[1],
		"c": input_vars[2],
		"res": output_vars[0]
	})

func _init():
	if not get_input_port_default_value(2):
		set_input_port_default_value(2, 0.05)
