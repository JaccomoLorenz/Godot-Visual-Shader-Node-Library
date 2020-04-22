tool
extends VisualShaderNodeCustom
class_name VisualShaderNodeScreenSpaceRefraction

func _get_name():
	return "ScreenSpaceRefraction"
	
func _get_category():
	return "3D"

func _get_subcategory():
	return "Refraction"

func _get_description():
	return "Ray traces the screen depth for more accurate refractions (GLES 3 Only)"

func _get_return_icon_type():
	return VisualShaderNode.PORT_TYPE_VECTOR

func _get_input_port_count():
	return 7

func _get_input_port_name(port):
	match port:
		0:
			return "ior"
		1:
			return "thickness"
		2:
			return "roughness"
		3:
			return "albedo"
		4:
			return "alpha"
		5:
			return "emission"
		6:
			return "normal"

func _get_input_port_type(port):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_SCALAR
		1:
			return VisualShaderNode.PORT_TYPE_SCALAR
		2:
			return VisualShaderNode.PORT_TYPE_SCALAR
		3:
			return VisualShaderNode.PORT_TYPE_VECTOR
		4:
			return VisualShaderNode.PORT_TYPE_SCALAR
		5:
			return VisualShaderNode.PORT_TYPE_VECTOR
		6:
			return VisualShaderNode.PORT_TYPE_VECTOR

func _get_output_port_count():
	return 2

func _get_output_port_name(port):
	match port:
		0:
			return "albedo"
		1:
			return "emission"

func _get_output_port_type(port):
	match port:
		0:
			return VisualShaderNode.PORT_TYPE_VECTOR
		1:
			return VisualShaderNode.PORT_TYPE_VECTOR

func _get_global_code(mode):
	if OS.get_current_video_driver() == OS.VIDEO_DRIVER_GLES2:
		push_warning("Screenspace refraction is not supported in GLES 2!")
		return ""
	
	if mode != Shader.MODE_SPATIAL:
		return ""
	
	var code = preload("screenspace_refraction.shader").code
	code = code.replace("shader_type spatial;\n", "")
	return code

func _get_code(input_vars, output_vars, mode, type):
	if mode != Shader.MODE_SPATIAL or type != VisualShader.TYPE_FRAGMENT or OS.get_current_video_driver() == OS.VIDEO_DRIVER_GLES2:
		return ""
	
	# Default values
	var ior = "1.333"
	var thickness = "0.0"
	var roughness = "0.0"
	var albedo = "vec3(1.0)"
	var alpha = "0.0"
	var emission = "vec3(0.0)"
	var normal = "NORMAL"
	
	if input_vars[0]:
		ior = input_vars[0]
	if input_vars[1]:
		thickness = input_vars[1]
	if input_vars[2]:
		roughness = input_vars[2]
	if input_vars[3]:
		albedo = input_vars[3]
	if input_vars[4]:
		alpha = input_vars[4]
	if input_vars[5]:
		emission = input_vars[5]
	if input_vars[6]:
		normal = input_vars[6]
	
	var params =  [ior, roughness, thickness, albedo, alpha, emission, normal, output_vars[0], output_vars[1]]
	
	return "screenspace_refraction(%s, %s, %s, %s, %s, %s, SCREEN_UV, SCREEN_TEXTURE, DEPTH_TEXTURE, VIEW, %s, VERTEX, INV_CAMERA_MATRIX, CAMERA_MATRIX, PROJECTION_MATRIX, %s, %s);" % params

func _init():
	# Default values for Editor
	# scale
	if not get_input_port_default_value(1):
		set_input_port_default_value(1, 0.05)
	# roughness
	if not get_input_port_default_value(2):
		set_input_port_default_value(2, 0.0)
	# alpha
	if not get_input_port_default_value(4):
		set_input_port_default_value(4, 1.0)
