extends Spatial

func _process(_delta):
	offset_sprite()

func offset_sprite():
	# Define a dictionary mapping animations to translations
	var animation_translations = {
		"idle": Vector3(0.05, -0.3, 0.8),
		"attack_00": Vector3(0, 0.1, 0.8),
		"block": Vector3(-0.35, -0.1, 0.8),
		"die": Vector3(0.2, -0.25, 0.8)
	}

	var animation_name = $AnimatedSprite3D.animation
	if animation_name in animation_translations:
		$AnimatedSprite3D.translation = animation_translations[animation_name]
