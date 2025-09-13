extends RichTextLabel

func _ready():
	pass 

func _process(_delta):
	var velocity = Input.get_vector("ldown", "lup", "lleft", "lright")
	text = "%.2f, %.2f" % [velocity.x, velocity.y]	
	pass
