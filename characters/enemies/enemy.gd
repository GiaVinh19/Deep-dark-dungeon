extends Spatial

###############
## VARIABLES ##
###############

# how much damage enemy can survive before reaching 0
var max_hp = 200
var hp = max_hp
var defense = 25
var enemy_damage = 10

# how much poise damage enemy can take before being staggered
var max_ap = 100
var ap = max_ap

# start at 0, build up to 100 as time passes, enemy hits player, and blocks hits
var max_mp = 100
var mp = 0
var mp_gain = 10
var rage = false
var tween_mp

# how much time it take to reach enemy's turn (use prime number)
# 1 second is 60 delta
var max_sp = 241
var sp = max_sp
var sp_increment = 1
var is_in_turn = false

# change color when skeleton got hit
var tween
var tween_rage

# for checking enemy's current state
var state_dict = {
	"idle" : true,
	"combat_first_turn": false,
	"combat_attack" : false,
	"combat_defend": false,
	"dead": false
}

#####################
## STATE MODIFIER ##
#####################

func modify_state(input):
	for state in state_dict:
		if state == input:
			state_dict[state] = true
#			print(self.name + " " + state)
		else:
			state_dict[state] = false

func _ready():
	attributes_setter()

########################
## UNIVERSAL FUNCTION ##
########################

func attributes_setter():
	$HUD/EnemyData/Attributes/Hp.max_value = max_hp
	$HUD/EnemyData/Attributes/Hp.value = max_hp
	
	$HUD/EnemyData/Attributes/Ap.max_value = max_ap
	$HUD/EnemyData/Attributes/Ap.value = max_ap
	
	$HUD/EnemyData/Attributes/Mp.max_value = max_mp
	$HUD/EnemyData/Attributes/Mp.value = mp
	
	$HUD/EnemyData/Attributes/Sp.max_value = max_sp
	$HUD/EnemyData/Attributes/Sp.value = max_sp

func hud_tracker():
	tween = create_tween()
	tween.tween_property($HUD/EnemyData/Attributes/Hp, "value", hp , 0.2)
	tween_mp = create_tween()
	tween_mp.tween_property($HUD/EnemyData/Attributes/Mp, "value", mp , 0.2)
	$HUD/EnemyData/Attributes/Ap.value = ap
	$HUD/EnemyData/Attributes/Sp.value = sp

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	hud_tracker()
	progress_speed_bar()
	sprite_restorer()
	attack_mode()
	hitbox_handler()
	offset_sprite()
	dead()
	combat_defend()

func progress_speed_bar():
	if state_dict.combat_first_turn or state_dict.combat_attack or state_dict.combat_defend:
		if sp == max_sp and is_in_turn == false:
			sp = 0
			is_in_turn = true
		sp += sp_increment
		if sp == max_sp and is_in_turn == true:
			if mp >= max_mp and rage == false:
				rage = true
				if $Audio/Rage.playing == false:
					$Audio/Rage.play()
				mp = 0
				tween_rage = create_tween()
				tween_rage.tween_property($Enemy/SpriteHandler/AnimatedSprite3D, "modulate", Color(1, 0.5, 0.5), 0.5)
			if ((randi() % 2) == 1) or rage == true :
				modify_state("combat_attack")
			else:
				modify_state("combat_defend")
			ap = max_ap
			is_in_turn = false

func attack_mode():
	if state_dict.combat_attack:
		if $Enemy/SpriteHandler/AnimatedSprite3D.animation != "attack_00":
			if (randi() % 2) == 1:
				$Enemy/SpriteHandler/AnimatedSprite3D.play("attack_00")
			else:
				$Enemy/SpriteHandler/AnimatedSprite3D.play("attack_00")
				$Enemy/SpriteHandler/AnimatedSprite3D.flip_h = true

func hitbox_handler():
	# Get current animation and frame
	var current_animation = $Enemy/SpriteHandler/AnimatedSprite3D.animation
	var current_frame = $Enemy/SpriteHandler/AnimatedSprite3D.frame

	# Disable collision shapes by default
	$Attacks/LeftHitBox.disabled = true
	$Attacks/RightHitBox.disabled = true

	# Enable collision shape for attack
	if current_animation == "attack_00" and current_frame == 4:
		if $Enemy/SpriteHandler/AnimatedSprite3D.flip_h == false:
			$Attacks/LeftHitBox.disabled = false
			if $Audio/Swings/Swing_00.playing == false:
				$Audio/Swings/Swing_00.play()
		if $Enemy/SpriteHandler/AnimatedSprite3D.flip_h == true:
			$Attacks/RightHitBox.disabled = false
			if $Audio/Swings/Swing_01.playing == false:
				$Audio/Swings/Swing_01.play()

func take_damage(damage):
	if state_dict.combat_defend == false:
		hp -= damage
		$Enemy/SpriteHandler/AnimatedSprite3D.modulate = Color(100, 100, 100)
	if state_dict.combat_defend:
		hp -= abs(damage-defense)
		mp += (mp_gain * 2)
		$Enemy/SpriteHandler/AnimatedSprite3D.modulate = Color(100, 100, 100)
	if hp <= 0:
		modify_state("dead")

func sprite_restorer():
#	if tween is SceneTreeTween:
#		if tween.is_running():
#			return
	if $Enemy/SpriteHandler/AnimatedSprite3D.modulate == Color(100, 100, 100) and rage == false:
		tween = create_tween()
		tween.tween_property($Enemy/SpriteHandler/AnimatedSprite3D, "modulate", Color(1, 1, 1) , 0.2)
	if $Enemy/SpriteHandler/AnimatedSprite3D.modulate == Color(100, 100, 100) and rage == true:
		tween = create_tween()
		tween.tween_property($Enemy/SpriteHandler/AnimatedSprite3D, "modulate", Color(1, 0.5, 0.5) , 0.2)

func dead():
	if state_dict.dead:
		$Enemy/SpriteHandler/AnimatedSprite3D.play("die")
		return true

func combat_defend():
	if state_dict.combat_defend:
		$Enemy/SpriteHandler/AnimatedSprite3D.play("block")

func _on_AnimatedSprite3D_animation_finished():
	if state_dict.dead == false and state_dict.combat_defend == false:
		$Enemy/SpriteHandler/AnimatedSprite3D.play("idle")
	if state_dict.dead:
		queue_free()

func _on_Attacks_body_entered(body):
	if "Player" in body.name:
		mp += mp_gain
		if (randi() % 2) == 1:
			$Audio/Attacks/Attack_00.play()
			if rage == false:
				body.take_damage(enemy_damage)
			if rage == true:
				$Audio/Attacks/Crit_00.play()
				body.take_damage(enemy_damage*2)
		else:
			$Audio/Attacks/Attack_01.play()
			if rage == false:
				body.take_damage(enemy_damage)
			if rage == true:
				$Audio/Attacks/Crit_01.play()
				body.take_damage(enemy_damage*2)

func offset_sprite():
	# Define a dictionary mapping animations to translations
	var animation_translations = {
		"idle": Vector3(0.05, -0.3, 0.8),
		"attack_00": Vector3(0, 0.1, 0.8),
		"block": Vector3(-0.35, -0.1, 0.8),
		"die": Vector3(0.2, -0.25, 0.8)
	}

	var animation_name = $Enemy/SpriteHandler/AnimatedSprite3D.animation
	if animation_name in animation_translations:
		if animation_name != "attack_00":
			$Enemy/SpriteHandler/AnimatedSprite3D.flip_h = false
		$Enemy/SpriteHandler/AnimatedSprite3D.translation = animation_translations[animation_name]
