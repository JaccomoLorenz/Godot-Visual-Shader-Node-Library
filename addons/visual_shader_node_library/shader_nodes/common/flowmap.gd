tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeFlowMap

func _get_name():
	return "Flowmap"

func _get_category():
	return "Common"

func _get_subcategory():
	return "Flowmap"

func _get_description():
	return "Animates a uv with a flowmap"

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_VECTOR

func _get_input_port_count():
	return 6

func _get_input_port_name(port):
	match port:
		0:
			return "Flow Map"
		1:
			return "Blend Cycle"
		2:
			return "Speed"
		3:
			return "UV"
		4:
			return "Direction"
		5:
			return "Offset"

func _get_input_port_type(port):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_VECTOR
		1:
			return VisualShaderNode.PORT_TYPE_SCALAR
		2:
			return VisualShaderNode.PORT_TYPE_SCALAR
		3:
			return VisualShaderNode.PORT_TYPE_VECTOR
		4:
			return VisualShaderNode.PORT_TYPE_VECTOR
		5:
			return VisualShaderNode.PORT_TYPE_SCALAR

func _get_output_port_count():
	return 4

func _get_output_port_name(port):
	match port:
		0:
			return "Blend"
		1:
			return "Layer 1"
		2:
			return "Layer 2"
		3:
			return "Strength"

func _get_output_port_type(port):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_SCALAR
		1:
			return VisualShaderNode.PORT_TYPE_VECTOR
		2:
			return VisualShaderNode.PORT_TYPE_VECTOR
		3:
			return VisualShaderNode.PORT_TYPE_SCALAR

func _get_global_code(mode):
	var code = preload("flow_map.shader").code
	code = code.replace("shader_type spatial;\n", "")
	return code

func _get_code(input_vars, output_vars, mode, type):
	# Default values
	var flow_map = "vec3(0.5, 0.5, 0.5)"
	var blend_cycle = "5.0"
	var speed = "1.0"
	var uv = "vec3(0.0, 0.0, 0.0)"
	var direction = "vec3(1.0, 1.0, 0.0)"
	var offset = "0.0"
	
	if input_vars[0]:
		flow_map = input_vars[0]
	if input_vars[1]:
		blend_cycle = input_vars[1]
	if input_vars[2]:
		speed = input_vars[2]
	if input_vars[3]:
		uv = input_vars[3]
	if input_vars[4]:
		direction = input_vars[4]
	if input_vars[5]:
		offset = input_vars[5]
	
	var params = [flow_map, blend_cycle, speed, uv, direction, offset, output_vars[0], output_vars[1], output_vars[2], output_vars[3]]
	return "flow_map(%s, %s, %s, %s, %s, %s, TIME, %s, %s, %s, %s);" % params

func _init():
	# Default values for the editor
	# blend_cycle
	if not get_input_port_default_value(1):
		set_input_port_default_value(1, 5.0)
	# speed
	if not get_input_port_default_value(2):
		set_input_port_default_value(2, 1.0)
	# offset
	if not get_input_port_default_value(5):
		set_input_port_default_value(5, 0.0)
	
