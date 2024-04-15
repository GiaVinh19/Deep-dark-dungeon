extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	offset_sprite()

func offset_sprite():
	# Define a dictionary mapping animations to translations
	var animation_y_translations = {
		"fist_idle": -0.5,
		"fist_attack_00": -0.5,
		"dagger_idle": -0.2,
		"dagger_attack_00": -0.2
	}

	# Loop through the dictionary and set translations based on the current animation
	for hand in [$RightHand, $LeftHand]:
		var animation_name = hand.animation
		if animation_name in animation_y_translations:
			hand.translation.y = animation_y_translations[animation_name]
