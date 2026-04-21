extends Merc

@onready var body_anim_player: AnimationPlayer = $BodyAnimPlayer

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): 
		# --- THE LERPING MAGIC ---
		# 15 is the "lerp speed". Higher = snappier, Lower = smoother but delayed.
		var lerp_speed = 15.0 * delta
		
		# Smoothly slide the position
		global_position = global_position.lerp(target_position, lerp_speed)
		
		# Smoothly rotate. We use lerp_angle instead of normal lerp!
		# Normal lerp will cause a crazy "spin of death" when going from 359 degrees back to 0.
		global_rotation.x = lerp_angle(global_rotation.x, target_rotation.x, lerp_speed)
		global_rotation.y = lerp_angle(global_rotation.y, target_rotation.y, lerp_speed)
		global_rotation.z = lerp_angle(global_rotation.z, target_rotation.z, lerp_speed)
		
		if health_bar: health_bar.hide()
		return # Skip all the local movement code below
	
	if dead: return
	if camera: camera.fov = camera_fov
	
	var input = Vector2.ZERO
	
	if ClientUI.chat_input.text == "":
		input.x = float(Input.is_physical_key_pressed(KEY_D)) - float(Input.is_physical_key_pressed(KEY_A))
		input.y = float(Input.is_physical_key_pressed(KEY_S)) - float(Input.is_physical_key_pressed(KEY_W))
	
	input = input.normalized()
	
	# Custom handling for player animations when moving or idle
	if input == Vector2.ZERO:
		body_anim_player.play("idle")
	else:
		body_anim_player.play("walk")
		
	var movement_dir = transform.basis * Vector3(input.x, 0, input.y) * speed
	
	if is_on_floor():
		var current_friction: Vector2 = Vector2(velocity.x, velocity.z).rotated(PI) * friction
		var friction_dir = transform.basis * Vector3(current_friction.x, 0, current_friction.y)
		velocity += Vector3(current_friction.x, 0, current_friction.y)
		velocity += Vector3(movement_dir.x, 0, movement_dir.z)
	
	else:
		if is_on_wall(): 
			velocity = velocity.lerp(Vector3.ZERO, delta * 5) 
		sv_airaccelerate(movement_dir, delta)

	velocity.y -= gravity * delta
	custom_process(delta)
	move_and_slide()
	if is_multiplayer_authority():
		receive_pos_from_server.rpc(global_position, global_rotation)
	
	if global_position.y < -1000:
		dead = true
		death_effects.rpc()
		die.rpc_id(1)
