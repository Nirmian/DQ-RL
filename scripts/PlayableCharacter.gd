extends KinematicBody2D

export var SPEED = 50
const GRAVITY = 200.0
var screen_size # Size of the game window

func _ready():
	screen_size = get_viewport_rect().size

func walk(velocity_x):
	if velocity_x != 0:
		$AnimatedSprite.flip_h = velocity_x < 0

var start_time = -100
var jump_intensity
var in_jump = false

func jump(time):
	var speed = -SPEED/20
	
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

var did_move = false
var landing = false
func solve_animation(velocity,delta):
	if in_jump or velocity.y>delta*GRAVITY+0.1: #in jump/falling
		$AnimatedSprite.animation='jump'
		landing=false
	elif $AnimatedSprite.animation=='land':
		if($AnimatedSprite.frame!=0):
			landing=false
		if not landing and $AnimatedSprite.frame==0:
			$AnimatedSprite.animation='walk'
			
	elif is_on_floor():
		if $AnimatedSprite.animation=='jump':
			$AnimatedSprite.animation='land'
			$AnimatedSprite.frame=0
			landing = true
			did_move = true
		else:
			$AnimatedSprite.animation='walk'
	if velocity.length()!=0:
		if $AnimatedSprite.animation=='jump' and $AnimatedSprite.frame==2:
			$AnimatedSprite.stop()
		else:
			$AnimatedSprite.play()
		did_move = true
	else:
		if($AnimatedSprite.frame!=0):
			did_move=false
		if($AnimatedSprite.frame==0 and not did_move):
			$AnimatedSprite.stop()
		else:
			$AnimatedSprite.play()

var velocity = Vector2()

func _physics_process(delta):
	velocity.y += delta * GRAVITY

	if is_on_floor():
		velocity.y=0
		jump_intensity = 0
		in_jump=false
	
	if is_on_ceiling():
		velocity.y=max(0,velocity.y)
		
	if Input.is_action_pressed("ui_left"):
		velocity.x = -SPEED
	elif Input.is_action_pressed("ui_right"):
		velocity.x =  SPEED
	else:
		velocity.x=0
	if Input.is_action_pressed("ui_up"):
		velocity.y += jump(delta)
		
	#if is_on_floor():
	
	walk(velocity.x)
	solve_animation(velocity,delta)
	# move_and_collide(velocity)
	move_and_slide(velocity,Vector2(0, -1))
