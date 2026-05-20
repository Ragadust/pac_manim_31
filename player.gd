extends CharacterBody2D

var gravity = 980
var drag_start_pos = Vector2.ZERO
var dragging = false

# --- YENİ DEĞİŞKENLER ---
var launch_multiplier = 5.0 
var max_drag_distance = 100.0 # Fareyi en fazla kaç piksel geri çekebileceğinin sınırı

func _physics_process(delta):
	# 1. YERÇEKİMİ: Sadece havadaysa VE şu an fareyle gerdirme yapmıyorsak yerçekimi uygula
	if not is_on_floor() and not dragging:
		velocity.y += gravity * delta
	
	# 2. FARE BASILDI (ŞART: Karakter yerde olacak ve tamamen durmuş olacak)
	if Input.is_action_just_pressed("ui_click") and is_on_floor() and velocity == Vector2.ZERO:
		drag_start_pos = get_global_mouse_position()
		dragging = true
		
	# 3. FARE BIRAKILDI
	if Input.is_action_just_released("ui_click") and dragging:
		var drag_end_pos = get_global_mouse_position()
		var drag_vector = drag_start_pos - drag_end_pos # Çektiğimiz yönün tersine fırlatma vektörü
		
		# Menzili Sınırla (Angry Birds kısıtlaması)
		# limit_length fonksiyonu vektörün boyu max_drag_distance'ı geçiyorsa onu sınırlar
		drag_vector = drag_vector.limit_length(max_drag_distance)
		
		# Sadece aşağı çekildiğinde yukarı fırlat (Zıplama kontrolü)
		if drag_vector.y < 0: 
			velocity = drag_vector * launch_multiplier
		else:
			# Eğer oyuncu yukarı doğru çektiyse fırlatma, iptal et
			velocity = Vector2.ZERO
			
		dragging = false

	# 4. SÜRTÜNME (Yerdeyken karakterin kayıp gitmesini engeller, tık diye durdurur)
	if is_on_floor() and not dragging:
		velocity.x = move_toward(velocity.x, 0, 500 * delta)

	move_and_slide()
