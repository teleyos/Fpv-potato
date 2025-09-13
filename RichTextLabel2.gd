extends RichTextLabel

func _ready():
	pass 

func _process(_delta):
	var velocity = Input.get_vector("rdown", "rup", "rleft", "rright")
	text = "%.2f, %.2f" % [velocity.x, velocity.y]	
	pass
