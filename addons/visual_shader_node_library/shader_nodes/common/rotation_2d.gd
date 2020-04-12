tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeRotation2D

func _get_name():
	return "Rotation2D"

func _get_category():
	return "Common"
	
func _get_subcategory():
	return "Rotation"

func _get_description():
	return "Rotates the input around a pivot. Default pivot is zero."

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_VECTOR

func _get_input_port_count():
	return 3

func _get_input_port_name(port):
	match port:
		0:
			return "angle"
		1:
			return "(pivot)"
		2:
			return "position"

func _get_input_port_type(port):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_SCALAR
		1:
			return VisualShaderNode.PORT_TYPE_VECTOR
		2:
			return VisualShaderNode.PORT_TYPE_VECTOR

func _get_output_port_count():
	return 1

func _get_output_port_name(port):
	match port:
		0:
			return "position"

func _get_output_port_type(port):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_VECTOR

func _get_global_code(mode):
	var code = preload("rotation_2d.shader").code
	code = code.replace("shader_type spatial;\n", "")
	return code

func _get_code(input_vars, output_vars, mode, type):
	# Default values
	var angle = "0.0"
	var pivot = "vec3(0.0, 0.0, 0.0)"
	var position = "vec3(0.0, 0.0, 0.0)"

	if input_vars[0]:
		angle = input_vars[0]
	if input_vars[1]:
		pivot = input_vars[1]
	if input_vars[2]:
		position = input_vars[2]
		
	var params =  [angle, pivot, position, output_vars[0]]
	return "rotation_2d(%s, %s, %s, %s);" % params
