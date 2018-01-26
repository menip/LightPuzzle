extends Sprite

var color
var modifier
var flipped = 1

func _ready():	
	update_self()

func update_self():
	modulate = Global.which_color(color)
	texture = Global.which_modifier_texture(modifier)
	rotation_degrees = 90 if flipped == -1 else 0