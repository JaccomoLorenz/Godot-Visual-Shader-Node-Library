tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeDeepParallax

func _get_name():
	return "DeepParallax"

func _get_category():
	return "3D"

func _get_subcategory():
	return "Depth"

func _get_description():
	return "Deep Parallax"

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_SCALAR

func _get_input_port_count():
	return 10

func _get_input_port_name(port):
	match port:
		0:
			return "uv"
		1:
			return "texture"
		2:
			return "depth_scale"
		3:
			return "min_layers"
		4:
			return "max_layers"
		5:
			return "(vertex)"
		6:
			return "(normal)"
		7:
			return "(tangent)"
		8:
			return "(binormal)"
		9:
			return "(depth_flip)"

func _get_input_port_type(port):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_VECTOR
		1:
			return VisualShaderNode.PORT_TYPE_SAMPLER
		2:
			return VisualShaderNode.PORT_TYPE_SCALAR
		3:
			return VisualShaderNode.PORT_TYPE_SCALAR
		4:
			return VisualShaderNode.PORT_TYPE_SCALAR
		5:
			return VisualShaderNode.PORT_TYPE_VECTOR
		6:
			return VisualShaderNode.PORT_TYPE_VECTOR
		7:
			return VisualShaderNode.PORT_TYPE_VECTOR
		8:
			return VisualShaderNode.PORT_TYPE_VECTOR
		9:
			return VisualShaderNode.PORT_TYPE_VECTOR

func _get_output_port_count():
	return 1

func _get_output_port_name(port):
	match port:
		0:
			return "uv"

func _get_output_port_type(port):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_VECTOR

func _get_global_code(mode):
	if mode != Shader.MODE_SPATIAL:
		return ""
		
	var code = preload("deep_parallax.shader").code
	code = code.replace("shader_type spatial;\n", "")
	return code

func _get_code(input_vars, output_vars, mode, type):
	if mode != Shader.MODE_SPATIAL or type != VisualShader.TYPE_FRAGMENT:
		return ""
	
	# Default values
	var uv = "vec3(UV, 0.0)"
	var texture = "texture_parallax_default"
	var depth_scale = "0.05"
	var min_layers = "8"
	var max_layers = "32"
	var vertex = "VERTEX"
	var normal = "NORMAL"
	var tangent = "TANGENT"
	var binormal = "BINORMAL"
	var depth_flip = "vec3(1.0, 1.0, 0.0)"

	if input_vars[0]:
		uv = input_vars[0]
	if input_vars[1]:
		texture = input_vars[1]
	if input_vars[2]:
		depth_scale = input_vars[2]	
	if input_vars[3]:
		min_layers = input_vars[3]
	if input_vars[4]:
		max_layers = input_vars[4]	
	if input_vars[5]:
		vertex = input_vars[5]
	if input_vars[6]:
		normal = input_vars[6]
	if input_vars[7]:
		tangent = input_vars[7]
	if input_vars[8]:
		binormal = input_vars[8]
	if input_vars[9]:
		depth_flip = input_vars[9]

	var params =  [uv, texture, depth_scale, min_layers, max_layers, vertex, normal, tangent, binormal, depth_flip, output_vars[0]]
	return "deep_parallax(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s);" % params

func _init():
	# Default values for the editor
	# depth_scale
	if not get_input_port_default_value(2):
		set_input_port_default_value(2, 0.05)
	# min_layers
	if not get_input_port_default_value(3):
		set_input_port_default_value(3, 8)
	# max_layers
	if not get_input_port_default_value(4):
		set_input_port_default_value(4, 32)
	# depth_flip
	if not get_input_port_default_value(9):
		set_input_port_default_value(9, Vector2(1.0, 1.0))
