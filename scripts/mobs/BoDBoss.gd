extends "res://scripts/mobs/Mob_base.gd"

var bullet
var can_cast_attack = true
var can_jump_attack = true
var cast_attacking = false

	
func _ready():
	stats['default_speed'] = 100
	self.stats['health'] = 800
	self.stats['max_health'] = 800
	self.stats['stagger_default'] = 800
	self.stats['stagger_health'] = 800
	self.SPEED = stats['default_speed'] 
	can_jump = false
	$HealthLabel.text = str(self.stats['health'])
	$HealthBar.max_value = self.stats['health']
	$HealthBar.value = self.stats['health']


func _process(delta):
	pass


func solve_animation(velocity):
	if not key_has_value(animation_dict, "flip_h", (x_direction < 0)):
		animation_dict["flip_h"] = (x_direction < 0)
		new_animation_dict["flip_h"] = (x_direction < 0)
		animation_change = true
	if not key_has_value(animation_dict, "animation", "walk"):
		animation_dict["animation"] = 'walk'
		new_animation_dict["animation"] = 'walk'
		animation_change = true


func attack_player(player):
	player.take_damage(attack_damage, 0, Vector2(x_direction, 0), 10)  # TODO: ensure that player takes damage only once, and takes it everywhere


func _on_Hurtbox_area_entered(area):
	if area.is_in_group('hitbox'): #  and is_network_master()
		var owner = area.get_owner()
		if owner.is_in_group('players'):
			attack_player(owner)

func _on_AnimatedSprite_frame_changed():
	pass


func _on_CastAttackCooldown_timeout():
	can_cast_attack = true

func _on_AttackCooldown_timeout():
	can_jump_attack = true
