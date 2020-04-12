tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeRotation3D

func _get_name():
	return "Rotation3D"

func _get_category():
	return "Common"
	
func _get_subcategory():
	return "Rotation"

func _get_description():
	return "Rotates the input around the pivot. Default pivot is zero."

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_VECTOR

func _get_input_port_count():
	return 5

func _get_input_port_name(port):
	match port:
		0:
			return "axis"
		1:
			return "angle"
		2:
			return "(pivot)"
		3:
			return "position"
		4:
			return "normal"

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
		4:
			return VisualShaderNode.PORT_TYPE_VECTOR

func _get_output_port_count():
	return 2

func _get_output_port_name(port):
	match port:
		0:
			return "position"
		1:
			return "normal"

func _get_output_port_type(port):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_VECTOR
		1:
			return VisualShaderNode.PORT_TYPE_VECTOR

func _get_global_code(mode):
	var code = preload("rotation_3d.shader").code
	code = code.replace("shader_type spatial;\n", "")
	return code

func _get_code(input_vars, output_vars, mode, type):
	# Default values
	var axis = "vec3(1.0, 0.0, 0.0)"
	var angle = "0.0"
	var pivot = "vec3(0.0, 0.0, 0.0)"
	var position = "vec3(0.0, 0.0, 0.0)"
	var normal = "vec3(0.0, 0.0, 0.0)"

	if input_vars[0]:
		axis = input_vars[0]
	if input_vars[1]:
		angle = input_vars[1]
	if input_vars[2]:
		pivot = input_vars[2]
	if input_vars[3]:
		position = input_vars[3]
		
	var params =  [axis, angle, pivot, position, output_vars[0]]
	var code = "rotation_3d(%s, %s, %s, %s, %s);" % params
	
	# Only add code for normal rotation if input port is set
	if input_vars[4]: 
		params =  [axis, angle, input_vars[4], output_vars[1]]
		code = code + "\nrotation_3d_normal(%s, %s, %s, %s);" % params
	else:
		code = code + output_vars[1] +" = " + normal + ";"
		
	return code
	
func _init():
	# Default values for the editor
	# angle
	if not get_input_port_default_value(1):
		set_input_port_default_value(1, 0.0)
