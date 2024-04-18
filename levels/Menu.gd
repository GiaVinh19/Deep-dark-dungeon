extends Node

func _ready():
	$Control/Select/NewGame.grab_focus()

func _physics_process(_delta):
	if Input.is_action_just_pressed("ui_up"):
		$Control/Select/NewGame.grab_focus()
		$Audio/Select.play()

	if Input.is_action_just_pressed("ui_down"):
		$Control/Select/QuitGame.grab_focus()
		$Audio/Select.play()

	if Input.is_action_just_pressed("ui_accept"):
		if $Control/Select/NewGame.is_hovered():
			_on_NewGame_pressed()
		elif $Control/Select/QuitGame.is_hovered():
			_on_QuitGame_pressed()

	if $Control/Select/NewGame.is_hovered() == true:
		$Control/Select/NewGame.grab_focus()

	if $Control/Select/QuitGame.is_hovered() == true:
		$Control/Select/QuitGame.grab_focus()

func _on_NewGame_pressed():
	$Audio/Confirm.play()
	yield(get_tree().create_timer(2), "timeout")
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://levels/Level.tscn")

func _on_QuitGame_pressed():
	$Audio/Confirm.play()
	yield(get_tree().create_timer(2), "timeout")
# warning-ignore:return_value_discarded
	get_tree().quit()
