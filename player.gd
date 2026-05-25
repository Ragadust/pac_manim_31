extends CharacterBody2D

@export_group("⚡ Fırlatma")
@export var launch_multiplier: float = 8.0
@export var max_drag_distance: float = 150.0

@export_group("🌍 Fizik")
@export var gravity: float = 600.0
@export var min_slide_angle: float = 15.0
@export var ground_brake_force: float = 350.0
@export var slope_slide_speed: float = 900.0
@export var slope_stop_force: float = 500.0
@export var max_slope_speed: float = 700.0

@export_group("🔄 Dönüş")
@export var angular_damping_air: float = 0.97
@export var angular_damping_ground: float = 0.90
@export var spin_from_velocity: float = 0.0007

var drag_start_pos = Vector2.ZERO
var dragging = false
var angular_velocity = 0.0
var current_rotation = 0.0

func _ready():
	floor_snap_length = 10.0
	floor_max_angle = deg_to_rad(75.0)
	current_rotation = rotation

func _physics_process(delta):

	if not is_on_floor() and not dragging:
		velocity.y += gravity * delta

	if is_on_floor() and not dragging:
		var floor_normal = get_floor_normal()
		var slope_angle = rad_to_deg(acos(floor_normal.dot(Vector2.UP)))

		if slope_angle > min_slide_angle:
			velocity.x = move_toward(velocity.x, 0.0, slope_stop_force * delta)

			var slope_direction = Vector2(floor_normal.y, -floor_normal.x)

			if slope_direction.dot(Vector2.DOWN) < 0:
				slope_direction = -slope_direction

			velocity += slope_direction * slope_slide_speed * delta

			if velocity.length() > max_slope_speed:
				velocity = velocity.normalized() * max_slope_speed

	if not is_on_floor():
		var target_spin = velocity.x * spin_from_velocity
		angular_velocity = lerp(angular_velocity, target_spin, 3.0 * delta)
		angular_velocity *= angular_damping_air
	else:
		angular_velocity *= angular_damping_ground

	current_rotation += angular_velocity
	rotation = current_rotation

	if Input.is_action_just_pressed("ui_click") and is_on_floor() and velocity.length() < 10.0:
		drag_start_pos = get_global_mouse_position()
		dragging = true
		angular_velocity = 0.0

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

	if is_on_floor() and not dragging:
		var floor_normal = get_floor_normal()
		var slope_angle = rad_to_deg(acos(floor_normal.dot(Vector2.UP)))

		if slope_angle <= min_slide_angle:
			velocity.x = move_toward(velocity.x, 0, ground_brake_force * delta)

	move_and_slide()
