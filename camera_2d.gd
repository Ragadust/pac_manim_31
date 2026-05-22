extends Camera2D

@export var target: CharacterBody2D  # Inspector'dan karakteri sürükle bırak

func _physics_process(delta):
	if target:
		# Sadece POZİSYONU takip et, rotation'ı yok say
		global_position = lerp(global_position, target.global_position, 10.0 * delta)
