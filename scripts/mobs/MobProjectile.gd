extends 'res://scripts/mobs/Mob_base.gd'

const bullet = preload("res://scenes/WeaponProjectile_bullet.tscn")

func _init():
	self.SPEED = 20

func follow_player():
	if len(in_area) > 0:
		player = in_area[0]
		if abs(position.x - player.position.x) > 150: #make 150 a variable
			if position.x < player.position.x:
				direction = 1
			else:
				direction = -1
		if position.x < player.position.x:
			$AnimatedSprite.flip_h = false
		else:
			$AnimatedSprite.flip_h = true
	else:
		direction = 0

	if not follow:
		direction = 0

func attack_player(player): #player will be null here
	if can_attack:
		var bullet_inst = bullet.instance()
		bullet_inst.group_to_detect = 'players'
		bullet_inst.direction = -1 if int($AnimatedSprite.flip_h) else 1
		get_tree().get_root().add_child(bullet_inst)
		bullet_inst.global_position = self.global_position
		can_attack = false
		attack_timer.start()
	
func _process(delta):
	attack_player(null)
	

	
