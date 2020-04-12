tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeFlowMapAddUV

func _get_name():
	return "FlowmapAddUV"

func _get_category():
	return "Common"

func _get_subcategory():
	return "Flowmap"

func _get_description():
	return "Combines a uv with animated flow layers"

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_VECTOR

func _get_input_port_count():
	return 4

func _get_input_port_name(port):
	match port:
		0:
			return "uv"
		1:
			return "uv_scale"
		2:
			return "layer1"
		3:
			return "layer2"

func _get_input_port_type(port):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_VECTOR
		1:
			return VisualShaderNode.PORT_TYPE_SCALAR
		2:
			return VisualShaderNode.PORT_TYPE_VECTOR
		3:
			return VisualShaderNode.PORT_TYPE_VECTOR

func _get_output_port_count():
	return 2

func _get_output_port_name(port):
	match port:
		0:
			return "uv1"
		1:
			return "uv2"

func _get_output_port_type(port):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_VECTOR
		1:
			return VisualShaderNode.PORT_TYPE_VECTOR

func _get_global_code(_mode):
	var code = preload("flowmap_add_uv.shader").code
	code = code.replace("shader_type spatial;", "")
	return code

func _get_code(input_vars, output_vars, _mode, _type):
	# Default values
	var uv = "vec3(0.0, 0.0, 0.0)"
	var uv_scale = "1.0"
	var layer1 = "vec3(0.0, 0.0, 0.0)"
	var layer2 = "vec3(0.0, 0.0, 0.0)"
	
	if input_vars[0]:
		uv = input_vars[0]
	if input_vars[1]:
		uv_scale = input_vars[1]
	if input_vars[2]:
		layer1 = input_vars[2]
	if input_vars[3]:
		layer2 = input_vars[3]
	
	var params = [uv, uv_scale, layer1, layer2, output_vars[0], output_vars[1]]
	return "flow_map_add_uv(%s, %s, %s, %s, %s, %s);" % params

func _init():
	# Default values for the editor
	# uv_scale
	if not get_input_port_default_value(1):
		set_input_port_default_value(1, 1.0)
