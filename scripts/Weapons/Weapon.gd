extends 'res://scripts/Weapons/Weapon_base.gd'

var stagger_damage = 5

func _init():
	attack_anim_names['attack'] = 'attack'
	attack_anim_names['special-attack'] = 'special-attack'
	LightAttack_CD.wait_time = 0.4

func _ready():
	position = Vector2(50, 40)

func attack():
	play_animation(attack_anim_names['attack'])


func special_attack():
	play_animation(attack_anim_names['special-attack'])


func _on_Area2D_area_entered(area):
	if area.is_in_group("hitbox"):
		var owner = area.get_owner()
		if owner.is_in_group('mobs'):
			owner.take_damage(attack_damage + get_parent().stats['damage_modifier'],
			stagger_damage,
			Vector2(-1 if $AnimatedSprite.flip_h else 1, 0), 50)
