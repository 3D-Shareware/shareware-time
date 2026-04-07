extends WeaponAbility
@onready var animation_player: AnimationPlayer = $firstanimation/AnimationPlayer

var ammo : int = 12
var damage = 10
var fire_speed = .1
@onready var bullet_ray_cast: RayCast3D = $BulletRayCast
@onready var tracer_effect: Node3D = $BulletRayCast/TracerEffect
@onready var fire_attack_speed: Timer = $FireAttackSpeed

func _ready() -> void:
	fire_attack_speed.wait_time
func _process(delta: float) -> void:
	print(is_multiplayer_authority(), " ", currently_active)
	if !is_multiplayer_authority(): pass
	if !currently_active: return
	
	
	global_transform = merc.camera.global_transform
	
	if animation_player.is_playing(): return
	if Input.is_action_just_pressed("left_click"):
		shoot()
	if Input.is_action_just_pressed("reload"):
		reload()

func reload():
	animation_player.play("reload")
	await animation_player.animation_finished
	ammo = 12
	
func shoot():
	if ammo != 0:
		ammo = clamp(ammo - 1, 0, 12)
		animation_player.play("fire")
		
		if bullet_ray_cast.is_colliding():
			var person_hit = bullet_ray_cast.get_collider()
			if person_hit != null and person_hit is Merc:
				rpc_id(person_hit.name, person_hit.take_damage(damage))
			tracer_effect._create_tracer_effect(bullet_ray_cast.global_position, bullet_ray_cast.get_collision_point())
func equip():
	animation_player.play("equip")
	
func dequip():
	animation_player.play("dequip")
