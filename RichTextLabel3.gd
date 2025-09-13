extends RichTextLabel


func _ready():
	text = """h to show/hide this tooltip\n
i to import .glb from %s/imports/\n
up/down controller arrow to adjust cam angle\n
right action button controller to respawn\n
p/m to ajust fov""" % [OS.get_user_data_dir()]
	pass

func _process(delta):
	if Input.is_action_just_pressed("help"):
		visible = !visible
	pass
