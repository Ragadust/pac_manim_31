extends CharacterBody2D

var gravity = 980
var drag_start_pos = Vector2.ZERO
var dragging = false
var launch_multiplier = 5.0
var max_drag_distance = 100.0

var slope_slide_friction = 0.3
var min_slide_angle = 15.0

# --- DÖNÜŞ FİZİĞİ ---
var angular_velocity = 0.0      # Anlık dönüş hızı (radyan/saniye)
var angular_damping = 0.98      # Her frame çarpılır, 1'e yakın = uzun döner
var spin_from_velocity = 0.004  # Yatay hız → dönüş oranı

func _physics_process(delta):
	# 1. YERÇEKİMİ
	if not is_on_floor() and not dragging:
		velocity.y += gravity * delta

	# 2. EĞİM KAYMASI
	if is_on_floor() and not dragging:
		var floor_normal = get_floor_normal()
		var slope_angle = rad_to_deg(acos(floor_normal.dot(Vector2.UP)))

		if slope_angle > min_slide_angle:
			var slope_direction = Vector2(floor_normal.y, -floor_normal.x)
			if slope_direction.y > 0:
				slope_direction = -slope_direction

			var slide_force = gravity * sin(deg_to_rad(slope_angle)) * (1.0 - slope_slide_friction)
			velocity += slope_direction * slide_force * delta

	# 3. DÖNÜŞ HESABI
	if not is_on_floor():
		# Havadayken: yatay hıza göre angular_velocity kazan
		var target_spin = velocity.x * spin_from_velocity
		angular_velocity = lerp(angular_velocity, target_spin, 5.0 * delta)
	else:
		if not dragging:
			var floor_normal = get_floor_normal()
			var slope_angle = rad_to_deg(acos(floor_normal.dot(Vector2.UP)))

			if slope_angle > min_slide_angle:
				# Eğimdeyken: hıza göre dön
				var target_spin = velocity.x * spin_from_velocity
				angular_velocity = lerp(angular_velocity, target_spin, 4.0 * delta)
			else:
				# Düz zeminde: dönüşü yavaşça sıfırla
				angular_velocity = lerp(angular_velocity, 0.0, 8.0 * delta)

	# angular_velocity'yi her frame rotation'a ekle
	rotation += angular_velocity

	# Dönüş sönümlenmesi (havada biraz azalsın)
	if not is_on_floor():
		angular_velocity *= angular_damping

	# 4. FARE BASILDI
	if Input.is_action_just_pressed("ui_click") and is_on_floor() and velocity == Vector2.ZERO:
		drag_start_pos = get_global_mouse_position()
		dragging = true
		rotation = 0.0
		angular_velocity = 0.0

	# 5. FARE BIRAKILDI
	if Input.is_action_just_released("ui_click") and dragging:
		var drag_end_pos = get_global_mouse_position()
		var drag_vector = drag_start_pos - drag_end_pos
		drag_vector = drag_vector.limit_length(max_drag_distance)

		if drag_vector.y < 0:
			velocity = drag_vector * launch_multiplier
			# Fırlatma anında dönüş başlasın
			angular_velocity = velocity.x * spin_from_velocity
		else:
			velocity = Vector2.ZERO

		dragging = false

	# 6. SÜRTÜNME
	if is_on_floor() and not dragging:
		var floor_normal = get_floor_normal()
		var slope_angle = rad_to_deg(acos(floor_normal.dot(Vector2.UP)))

		if slope_angle <= min_slide_angle:
			velocity.x = move_toward(velocity.x, 0, 500 * delta)

	move_and_slide()
