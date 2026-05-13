extends CharacterBody2D

var gravity = 980 # Yerçekimi gücü
var drag_start_pos = Vector2.ZERO
var dragging = false
var launch_multiplier = 5.0 # Fırlatma hızı çarpanı

func _physics_process(delta):
	# 1. Yerçekimi Uygula
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# 2. Fare Girişlerini Kontrol Et
	if Input.is_action_just_pressed("ui_click"): # Sol tık basıldı
		drag_start_pos = get_global_mouse_position()
		dragging = true
		
	if Input.is_action_just_released("ui_click") and dragging: # Sol tık bırakıldı
		var drag_end_pos = get_global_mouse_position()
		var drag_vector = drag_start_pos - drag_end_pos
		
		# Sadece aşağı çekildiğinde yukarı fırlatmak için kontrol
		if drag_vector.y < 0: 
			velocity = drag_vector * launch_multiplier
		
		dragging = false

	move_and_slide()
