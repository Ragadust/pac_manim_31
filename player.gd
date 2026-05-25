extends CharacterBody2D

# ═══════════════════════════════════════════
#              🎮 OYUNCU AYARLARI
# ═══════════════════════════════════════════

@export_group("⚡ Fırlatma")
@export var launch_multiplier: float = 8.0        # Fırlatma gücü
@export var max_drag_distance: float = 150.0       # Maks çekiş mesafesi

@export_group("🌍 Fizik")
@export var gravity: float = 600.0                 # Yerçekimi
@export var slope_slide_friction: float = 0.3      # Rampa sürtünmesi (0=buz, 1=yapışkan)
@export var min_slide_angle: float = 15.0          # Kaymaya başlama açısı
@export var ground_brake_force: float = 500.0      # Yerde durma gücü

@export_group("🔄 Dönüş")
@export var angular_damping: float = 0.68          # Dönüş sönümü (0=hemen dur, 1=sonsuz döner)
@export var spin_from_velocity: float = 0.0004     # Hız → dönüş oranı

# ═══════════════════════════════════════════
#              İÇ DEĞİŞKENLER
# ═══════════════════════════════════════════
var drag_start_pos = Vector2.ZERO
var dragging = false
var angular_velocity = 0.0

func _ready():
	floor_snap_length = 10.0
	floor_max_angle = deg_to_rad(75.0)

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
		var target_spin = velocity.x * spin_from_velocity
		angular_velocity = lerp(angular_velocity, target_spin, 5.0 * delta)
	else:
		if not dragging:
			var floor_normal = get_floor_normal()
			var slope_angle = rad_to_deg(acos(floor_normal.dot(Vector2.UP)))
			if slope_angle > min_slide_angle:
				var target_spin = velocity.x * spin_from_velocity
				angular_velocity = lerp(angular_velocity, target_spin, 4.0 * delta)
			else:
				angular_velocity = lerp(angular_velocity, 0.0, 8.0 * delta)

	rotation += angular_velocity
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
			angular_velocity = velocity.x * spin_from_velocity
		else:
			velocity = Vector2.ZERO
		dragging = false

	# 6. SÜRTÜNME
	if is_on_floor() and not dragging:
		var floor_normal = get_floor_normal()
		var slope_angle = rad_to_deg(acos(floor_normal.dot(Vector2.UP)))
		if slope_angle <= min_slide_angle:
			velocity.x = move_toward(velocity.x, 0, ground_brake_force * delta)

	move_and_slide()
