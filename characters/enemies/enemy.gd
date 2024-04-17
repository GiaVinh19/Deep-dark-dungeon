extends Spatial

###############
## VARIABLES ##
###############

# how much damage enemy can survive before reaching 0
var max_hp = 200
var hp = max_hp

# how much poise damage enemy can take before being staggered
var max_ap = 100
var ap = max_ap

# start at 0, build up to 100 as time passes, enemy hits player, and blocks hits
var max_mp = 100
var mp = 0

# how much time it take to reach enemy's turn (use prime number)
# 1 second is 60 delta
var max_sp = 307
var sp = max_sp
var sp_increment = 1
var is_in_turn = false

# change color when skeleton got hit
var tween

# for checking enemy's current state
var state_dict = {
	"idle" : true,
	"combat_first_turn": false,
	"combat_attack" : false,
	"combat_defend": false,
	"die": false
}

#####################
## STATE MODIFIER ##
#####################

func modify_state(input):
	for state in state_dict:
		if state == input:
			state_dict[state] = true
			print(self.name + " " + state)
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
	$HUD/EnemyData/Attributes/Hp.value = hp
	$HUD/EnemyData/Attributes/Ap.value = ap
	$HUD/EnemyData/Attributes/Mp.value = mp
	$HUD/EnemyData/Attributes/Sp.value = sp

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	hud_tracker()
	progress_speed_bar()
	sprite_restorer()
	attack_mode()
	hitbox_handler()

func progress_speed_bar():
	if state_dict.combat_first_turn or state_dict.combat_attack or state_dict.combat_defend:
		if sp == max_sp and is_in_turn == false:
			sp = 0
			is_in_turn = true
		sp += sp_increment
		if sp == max_sp and is_in_turn == true:
#			if (randi() % 2) == 1:
			modify_state("combat_attack")
#			else:
#				modify_state("combat_defend")
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
		if $Enemy/SpriteHandler/AnimatedSprite3D.flip_h == true:
			$Attacks/RightHitBox.disabled = false

func take_damage(damage):
	hp -= damage
	$Enemy/SpriteHandler/AnimatedSprite3D.modulate = Color(100, 100, 100)
	print(hp)
	if hp <= 0:
		dead()

func sprite_restorer():
	if tween is SceneTreeTween:
		if tween.is_running():
			return
	if $Enemy/SpriteHandler/AnimatedSprite3D.modulate == Color(100, 100, 100):
		tween = create_tween()
		tween.tween_property($Enemy/SpriteHandler/AnimatedSprite3D, "modulate", Color(1, 1, 1) , 0.2)

func dead():
	pass

func block():
	$Enemy/HurtBox.disabled = true
	$Enemy/BlockBox.disabled = false
	$Enemy/SpriteHandler/AnimatedSprite3D.play("block")

func die():
	$Enemy/SpriteHandler/AnimatedSprite3D.play("die")


func _on_AnimatedSprite3D_animation_finished():
	$Enemy/SpriteHandler/AnimatedSprite3D.play("idle")
	$Enemy/SpriteHandler/AnimatedSprite3D.flip_h = false

func _on_Attacks_body_entered(body):
	if "Player" in body.name:
		if (randi() % 2) == 1:
			$Audio/Attacks/Attack_00.play()
		else:
			$Audio/Attacks/Attack_01.play()
