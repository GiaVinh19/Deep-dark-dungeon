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

# how long the hitbox last (1/60 = 0.33) 
const HITBOX_DURATION = 0.33

# the exact frame where the HitBox spawn (4/6 = 0.66)
const HITBOX_FRAME = 0.66

# for checking player's current state
var state_dict = {"idle" : true, 
				  "attack" : false,
				  "block": false,
				  "die": false}

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
func _process(delta):
	hud_tracker()

func take_damage(damage):
	hp -= damage
	print(hp)
	if hp <= 0:
		dead()

func dead():
	pass

func idle():
	$Enemy/SpriteHandler/AnimatedSprite3D.play("idle")

func block():
	$Enemy/HurtBox.disabled = true
	$Enemy/BlockBox.disabled = false
	$Enemy/SpriteHandler/AnimatedSprite3D.play("block")

func attack_left():
	$Enemy/SpriteHandler/AnimatedSprite3D.flip_h = true
	$Enemy/SpriteHandler/AnimatedSprite3D.play("attack_00")

func attack_right():
	$Enemy/SpriteHandler/AnimatedSprite3D.play("attack_00")

func die():
	$Enemy/SpriteHandler/AnimatedSprite3D.play("die")
