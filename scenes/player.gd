extends CharacterBody2D

@export var speed : float = 150.0

var direction := Vector2.RIGHT  # başlangıç yönü
var next_direction := Vector2.RIGHT

@onready var anim : AnimatedSprite2D = $AnimatedSprite2D

# ════════════════════════════════════════
func _physics_process(delta: float) -> void:
	_handle_input()
	_try_turn()
	velocity = direction * speed
	move_and_slide()
	_update_animation()

# ───────── INPUT ─────────
func _handle_input() -> void:
	if Input.is_action_pressed("right"):
		next_direction = Vector2.RIGHT
	elif Input.is_action_pressed("left"):
		next_direction = Vector2.LEFT
	elif Input.is_action_pressed("up"):
		next_direction = Vector2.UP
	elif Input.is_action_pressed("down"):
		next_direction = Vector2.DOWN

# ───────── TURN ─────────
# Dönüş isteğini sakla, uygun anda uygula
func _try_turn() -> void:
	# Hemen dön (duvar yoksa move_and_slide halleder)
	direction = next_direction

# ───────── ANIMATION ─────────
func _update_animation() -> void:
	if direction == Vector2.RIGHT:
		anim.play("right")
		anim.flip_h = false
	elif direction == Vector2.LEFT:
		anim.play("right")   # right animasyonunu ters çevir
		anim.flip_h = true
	elif direction == Vector2.UP:
		anim.play("up")
	elif direction == Vector2.DOWN:
		anim.play("down")
