extends KinematicBody2D

var spawner = null

export var SPEED = 40
export var JUMPSPEED = 320
onready var GRAVITY = $'../GlobalSettings'.GRAVITY
onready var player = $'../PlayableCharacter'
onready var attack_timer = $'AttackCooldown'
onready var jump_timer = $'JumpCooldown'
export var health = 20
var is_dead = false

var velocity = Vector2()
export var follow = true
var direction = 1
var in_jump = false
var can_jump = false
var can_attack = true
var jump_intensity = 0
var start_time = -100
var attack_damage = 10
var attack_cooldown = 1.5	
var jump_cooldown = 5

const bullet = preload("res://scenes/WeaponProjectile_bullet.tscn")


func _ready():
	attack_timer.wait_time = attack_cooldown	
	jump_timer.wait_time = jump_cooldown
	jump_timer.start()

	
func jump(time):
	var speed = -JUMPSPEED/20
	if is_on_floor():
		in_jump = true
		jump_intensity = 20
		start_time = OS.get_ticks_msec()
	var current_time = OS.get_ticks_msec()
	if current_time-start_time>50:
		jump_intensity = 0
	else:
		start_time=current_time
		
	jump_intensity*=0.80
	speed*=jump_intensity
	return speed

func follow_player():
	if abs(position.x - player.position.x) > 150: #make 150 a variable
		if position.x < player.position.x:
			direction = 1
		else:
			direction = -1
	else:
		direction = 0
	
	if position.x < player.position.x:
		$AnimatedSprite.flip_h = false
	else:
		$AnimatedSprite.flip_h = true
	
	if not follow:
		direction = 0

func attack_player():
	if can_attack:
		var bullet_inst = bullet.instance()
		bullet_inst.group_to_detect = 'players'
		bullet_inst.direction = -1 if int($AnimatedSprite.flip_h) else 1
		add_child(bullet_inst)
		can_attack = false
		attack_timer.start()

func solve_animation(velocity,delta):
	if velocity.x != 0:
		$AnimatedSprite.flip_h = velocity.x < 0
		$AnimatedSprite.animation = 'walk'
	
	if velocity.x == 0:
		$AnimatedSprite.animation = 'idle'

func out_of_bounds():
	# we can add invisible objects, boundaries, and 
	# _on_Area2D_body_entered => direction *= -1
	# to ensure that the enemy patrols only one zone
	get_node("../EnemySpawner").spawn() #remove this
	queue_free()
	
func _physics_process(delta):
	follow_player()
	attack_player()
	velocity.y += delta * GRAVITY
	velocity.x = SPEED * direction
	if is_on_floor():
		velocity.y = 0
		jump_intensity = 0
		in_jump=false
	if is_on_ceiling():
		velocity.y=max(0,velocity.y)
		
	if can_jump and follow:
		velocity.y += jump(delta)
		can_jump = false
	
	solve_animation(velocity, delta)
	
	#solve_animation(velocity,delta)
	#move_and_collide(velocity)
	
	move_and_slide(velocity, Vector2(0, -1))
	
		
	var previous = get_slide_count()
	for i in get_slide_count():
		if get_slide_count() > i:
			var collision = get_slide_collision(i)
			if collision and collision.collider.name == 'PlayableCharacter' and follow:
				pass
			

func on_take_damage():
	if not is_dead:
		if health > 0:
			$HealthLabel.text = String(health)
		else:
			is_dead = true
			queue_free()
			if spawner != null:
				spawner.decrease_spawned()
	follow = false
	
	attack_timer.start()

func take_damage(value):
	health -= value
	on_take_damage()

func _on_DetectArea_body_entered(body):
	if body == player:
		follow = true

func _on_DetectArea_body_exited(body):
	if body == player:
		follow = false

func _on_AttackCooldown_timeout():
	can_attack = true
	follow = true
	

func _on_JumpCooldown_timeout():
	can_jump = true