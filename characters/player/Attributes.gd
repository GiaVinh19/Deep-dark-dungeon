extends VBoxContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	# Scale each child node of the VBoxContainer
	for child in get_children():
		if child.is_class("Control"):
			# If the child is a Control node (such as a Button or Label), adjust its minimum size
			child.scale *= 3  # Double the minimum size of each child node


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
