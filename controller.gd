extends MeshInstance2D

var l = 0

func _process(_delta):
	if(!get_parent()):return
	l = get_parent().rect_size / 2
	position =  l * (Vector2(1,1) + Input.get_vector("lleft","lright","lup","ldown")) - Vector2(2.5,2.5)
	pass
