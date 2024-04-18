extends Spatial

###############
## VARIABLES ##
###############

# player's movement and rotation speed
const SPEED := 0.5
const DODGE_DISTANCE := 0.4
# this will be doubled since it will repeat twice
const DODGE_DURATION := 0.2

# check for collision at the front
onready var front_ray := $FrontRay

# for movement and rotation
var tween
var tween_hp
var tween_ap
var tween_dead
var tween_battle_music

# get inital position when enter combat
var initial_position = Vector3()

# get enemy
var enemy

# for checking player's current state
var state_dict = {   
	"explore": true, 
	"dialogue": false,
	"combat_first_turn": false,
	"combat_dialogue": false,
	"combat_attack": false,
	"combat_defend": false,
	"dead": false,
	"victory": false
}

# ATTRIBUTES

# how much damage you can survive before reaching 0
var max_hp = 100
var hp = max_hp

# how many actions you can do in 1 turn
var max_ap = 100
var ap = max_ap
var ap_increment = 5

# how many spells or special attacks you can do before reaching 0
var max_mp = 100
var mp = max_mp

# how much time it take to reach your turn (use prime number)
# 1 second is 60 delta
var max_sp = 151
var sp = max_sp
var sp_increment = 1
var is_in_turn = false

func _ready():
	attributes_setter()
	set_process_input(true)

#####################
## RUN EVERY FRAME ##
#####################

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	move(SPEED)
	confirm()
#	change_equipment()
	progress_speed_bar()
	combat_dialogue()
	hud_tracker()
	attack_mode()
	defense_mode()
	hurtbox_frame_handler()
	dodge_hurtbox_handler()
	dead()
	victory()
	stop_music()
#####################
## STATE MODIFIER ##
#####################
func stop_music():
	if $Audio/Battle.volume_db == -80:
		$Audio/Battle.stop()

func modify_state(input):
	for state in state_dict:
		if state == input:
			state_dict[state] = true
		else:
			state_dict[state] = false

########################
## UNIVERSAL FUNCTION ##
########################

func confirm():
	if state_dict.dialogue:
		if Input.is_action_just_pressed("ui_accept"):
			$HUD/DialogueContainer.visible = false
			$HUD/DialogueContainer/Label.text = ""
			modify_state("combat_first_turn")
			enemy.modify_state("combat_first_turn")
	if state_dict.victory:
		if Input.is_action_just_pressed("ui_accept"):
			$HUD/DialogueContainer/CombatLabel.visible = false
			$HUD/DialogueContainer.visible = false
			$HUD/DialogueContainer/Label.text = ""
			modify_state("explore")

func victory():
	if state_dict.victory:
		
		sp = max_sp
		ap = max_ap
		enemy = null
		initial_position = Vector3()
		is_in_turn = false
		$HUD/DialogueContainer/CombatLabel.visible = false
		$HUD/DialogueContainer/Label.text = "Victory Achieved"
		$HUD/DialogueContainer.visible = true
	

func attributes_setter():
	$HUD/PlayerData/Attributes/Hp.max_value = max_hp
	$HUD/PlayerData/Attributes/Hp.value = max_hp
	
	$HUD/PlayerData/Attributes/Ap.max_value = max_ap
	$HUD/PlayerData/Attributes/Ap.value = max_ap
	
	$HUD/PlayerData/Attributes/Mp.max_value = max_mp
	$HUD/PlayerData/Attributes/Mp.value = max_mp
	
	$HUD/PlayerData/Attributes/Sp.max_value = max_sp
	$HUD/PlayerData/Attributes/Sp.value = max_sp

func hud_tracker():
	tween_hp = create_tween()
	tween_hp.tween_property($HUD/PlayerData/Attributes/Hp, "value", hp , 0.2)
	tween_ap = create_tween()
	tween_ap.tween_property($HUD/PlayerData/Attributes/Ap, "value", ap , 0.2)
	$HUD/PlayerData/Attributes/Mp.value = mp
	$HUD/PlayerData/Attributes/Sp.value = sp

#func _input(event):
#	if state_dict.combat_dialogue:
#		if event.is_action_pressed("ui_q"):
#			get_tree().paused = false
#			$HUD/DialogueContainer.visible = false
#			modify_state("combat_attack")
#		elif event.is_action_pressed("ui_e"):
#			get_tree().paused = false
#			$HUD/DialogueContainer.visible = false
#			modify_state("combat_defend")

#func change_equipment():
#	if state_dict.explore:
#		if Input.is_action_just_pressed("ui_4"):
#			if $FirstPerson/Hands/RightHand.animation == "fist_idle":
#				$FirstPerson/Hands/RightHand.animation = "dagger_idle"
#			elif $FirstPerson/Hands/RightHand.animation == "dagger_idle":
#				$FirstPerson/Hands/RightHand.animation = "fist_idle"
#		if Input.is_action_just_pressed("ui_2"):
#			if $FirstPerson/Hands/LeftHand.animation == "fist_idle":
#				$FirstPerson/Hands/LeftHand.animation = "dagger_idle"
#			elif $FirstPerson/Hands/LeftHand.animation == "dagger_idle":
#				$FirstPerson/Hands/LeftHand.animation = "fist_idle"

##################
## EXPLORE MODE ##
##################

func move(speed):
	if state_dict.explore:

		if tween is SceneTreeTween:
			# disable player input while tween is playing
			if tween.is_running():
				$EnemyDetector/CollisionShape.disabled = true
				return
			# re-activate enemy-checker box
			else:
				$EnemyDetector/CollisionShape.disabled = false

		if Input.is_action_just_pressed("ui_up"):
			if not front_ray.is_colliding():
				if $Audio/Walk.playing == false:
					$Audio/Walk.play()
				tween = create_tween()
				tween.tween_property(self, "transform", transform.translated(Vector3.FORWARD * 2), speed*0.8)

		if Input.is_action_just_pressed("ui_left"):
			if $Audio/Walk.playing == false:
				$Audio/Walk.play()
			tween = create_tween()
			tween.tween_property(self, "transform:basis", transform.basis.rotated(Vector3.UP, PI / 2), speed) 

		if Input.is_action_just_pressed("ui_down"):
			if $Audio/Walk.playing == false:
				$Audio/Walk.play()
			tween = create_tween()
			tween.tween_property(self, "transform:basis", transform.basis.rotated(Vector3.UP, PI), speed*1.4)

		if Input.is_action_just_pressed("ui_right"):
			if $Audio/Walk.playing == false:
				$Audio/Walk.play()
			tween = create_tween()
			tween.tween_property(self, "transform:basis", transform.basis.rotated(Vector3.UP, -PI / 2), speed)


#################
## COMBAT MODE ##
#################

# detecting enemy and initialize combat mode
func _on_EnemyDetector_body_entered(body):
	enemy = body.get_parent()
	if "Enemy" in body.name:
		$Audio/Battle.play()
		modify_state("dialogue")
		initial_position = $FirstPerson.global_translation
		$HUD/DialogueContainer/Label.text = "A wild " + enemy.name + " appears!"
		$HUD/DialogueContainer.visible = true
		enemy.get_node("HUD").visible = true

func combat_dialogue():
	if state_dict.combat_dialogue:
		$HUD/DialogueContainer.visible = true
		$HUD/DialogueContainer/CombatLabel.visible = true
		
		if get_tree().paused == false:
			get_tree().paused = true

		if Input.is_action_just_pressed("ui_q"):
			get_tree().paused = false
			$HUD/DialogueContainer.visible = false
			modify_state("combat_attack")
		if Input.is_action_just_pressed("ui_e"):
			get_tree().paused = false
			$HUD/DialogueContainer.visible = false
			modify_state("combat_defend")

func progress_speed_bar():
	if state_dict.combat_first_turn or state_dict.combat_attack or state_dict.combat_defend:
		if sp == max_sp and is_in_turn == false and enemy.dead() == null:
			sp = 0
			is_in_turn = true
		sp += sp_increment
		if sp == max_sp and is_in_turn == true and enemy.dead() == null:
			modify_state("combat_dialogue")
			ap = max_ap
			is_in_turn = false
		if enemy.dead():
			ap = max_ap
			sp = max_sp
			is_in_turn = false

# ATTACK MODE
func attack_mode():
	if state_dict.combat_attack and enemy.dead() == null:
		if Input.is_action_just_pressed("ui_up"):
			pass
		elif Input.is_action_just_pressed("ui_left"):
			fist_punch()
		elif Input.is_action_just_pressed("ui_down"):
			pass
		elif Input.is_action_just_pressed("ui_right"):
			dagger_stab()

func _on_Dagger_body_entered(body):
	enemy = body.get_parent()
	if "Enemy" in body.name:
		enemy.take_damage(25)

func _on_Fist_body_entered(body):
	enemy = body.get_parent()
	if "Enemy" in body.name:
		enemy.take_damage(10)

# DEFENSE MODE
func defense_mode():
	if state_dict.combat_defend and ap > 0 and $FirstPerson.global_translation == initial_position and enemy.dead() == null:
		if Input.is_action_just_pressed("ui_up"):
			ap -= 25
			$Audio/Dodge.play()
			tween = create_tween()
			tween.tween_property($FirstPerson, "global_translation", initial_position + Vector3(0, DODGE_DISTANCE, 0), DODGE_DURATION)
		if Input.is_action_just_pressed("ui_left"):
			ap -= 25
			$Audio/Dodge.play()
			tween = create_tween()
			tween.tween_property($FirstPerson, "global_translation", initial_position + Vector3(-DODGE_DISTANCE, 0, 0), DODGE_DURATION)
		if Input.is_action_just_pressed("ui_down"):
			ap -= 25
			$Audio/Dodge.play()
			tween = create_tween()
			tween.tween_property($FirstPerson, "global_translation", initial_position + Vector3(0, -DODGE_DISTANCE, 0), DODGE_DURATION)
		if Input.is_action_just_pressed("ui_right"):
			ap -= 25
			$Audio/Dodge.play()
			tween = create_tween()
			tween.tween_property($FirstPerson, "global_translation", initial_position + Vector3(DODGE_DISTANCE, 0, 0), DODGE_DURATION)

func dodge_hurtbox_handler():
	if state_dict.combat_defend or state_dict.combat_dialogue:
		
		if ($FirstPerson.global_translation.is_equal_approx(initial_position + Vector3(0, DODGE_DISTANCE, 0)) ) or ($FirstPerson.global_translation.is_equal_approx(initial_position + Vector3(-DODGE_DISTANCE, 0, 0)) ) or ($FirstPerson.global_translation.is_equal_approx(initial_position + Vector3(0, -DODGE_DISTANCE, 0)) ) or ($FirstPerson.global_translation.is_equal_approx(initial_position + Vector3(DODGE_DISTANCE, 0, 0)) ):
			tween = create_tween()
			tween.tween_property($FirstPerson, "global_translation", initial_position, DODGE_DURATION)

		if $FirstPerson.global_translation != initial_position:
			$HurtBox.disabled = true

		# Top
		if $FirstPerson.global_translation.y > initial_position.y:
			$TopHurtBox.disabled = false

		# Left
		if $FirstPerson.global_translation.x < initial_position.x:
			$LeftHurtBox.disabled = false

		#Bottom
		if $FirstPerson.global_translation.y < initial_position.y:
			$BottomHurtBox.disabled = false

		# Right
		if $FirstPerson.global_translation.x > initial_position.x:
			$RightHurtBox.disabled = false

		if $FirstPerson.global_translation.is_equal_approx(initial_position):
			$HurtBox.disabled = false
			$TopHurtBox.disabled = true
			$LeftHurtBox.disabled = true
			$BottomHurtBox.disabled = true
			$RightHurtBox.disabled = true

func fist_punch():
	if ap > 0 and $FirstPerson/Hands/LeftHand.animation != "fist_attack_00":
		$FirstPerson/Hands/LeftHand.play("fist_attack_00")
		ap -= 20

func dagger_stab():
	if ap > 0 and $FirstPerson/Hands/RightHand.animation != "dagger_attack_00":
		$FirstPerson/Hands/RightHand.play("dagger_attack_00")
		ap -= 30

func take_damage(damage):
	hp -= damage
	if hp <= 0:
		modify_state("dead")

func dead():
	if state_dict.dead:
		tween_battle_music = create_tween()
		tween_battle_music.tween_property($Audio/Battle, "volume_db", -80, 3)
		$HurtBox.disabled = true
		tween_dead = create_tween()
		tween_dead.tween_property($HUD/Defeated, "modulate", Color(1, 1, 1, 1), 1)
		if $Audio/Defeated.playing == false:
			$Audio/Defeated.play()
		if $DeadTimer.is_stopped():
			$DeadTimer.start()

#func frame_freeze(time_scale, duration):
#	Engine.time_scale = time_scale
#	yield(get_tree().create_timer(time_scale *duration), "timeout")
#	Engine.time_scale = 1

#######################
## ANIMATION HANDLER ##
#######################

func hurtbox_frame_handler():
	# Get current animation and frame for the right hand
	var current_right_animation = $FirstPerson/Hands/RightHand.animation
	var current_right_frame = $FirstPerson/Hands/RightHand.frame

	# Get current animation and frame for the left hand
	var current_left_animation = $FirstPerson/Hands/LeftHand.animation
	var current_left_frame = $FirstPerson/Hands/LeftHand.frame

	# Disable collision shapes by default
	$Attacks/Dagger/CollisionShape.disabled = true
	$Attacks/Fist/CollisionShape.disabled = true

	# Enable collision shape for dagger attack
	if current_right_animation == "dagger_attack_00" and current_right_frame == 3:
		$Attacks/Dagger/CollisionShape.disabled = false
		if $Audio/Dagger/Dagger00.playing == false:
			$Audio/Dagger/Dagger00.play()

	# Enable collision shape for fist attack
	if current_left_animation == "fist_attack_00" and current_left_frame == 3:
		$Attacks/Fist/CollisionShape.disabled = false
		if $Audio/Fist/Fist00.playing == false:
			$Audio/Fist/Fist00.play()

func _on_RightHand_animation_finished():
#	right_hand_animation = false
	$FirstPerson/Hands/RightHand.play("dagger_idle")

func _on_LeftHand_animation_finished():
#	left_hand_animation = false
	$FirstPerson/Hands/LeftHand.play("fist_idle")


func _on_DeadTimer_timeout():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://levels/Menu.tscn")

func _on_EnemyDetector_body_exited(body):
	enemy = body.get_parent()
	if "Enemy" in body.name:
		tween_battle_music = create_tween()
		tween_battle_music.tween_property($Audio/Battle, "volume_db", -80, 3)
		$Audio/Victory.play()
		modify_state("victory")
