# CameraFollow.gd
# Player node'una veya ayrı bir Camera2D node'una ekleyin

extends Camera2D

@export var target: NodePath          # Takip edilecek oyuncu
@export var smoothing_speed: float = 5.0   # Yumuşatma hızı (1=yavaş, 20=hızlı)
@export var offset_x: float = 150.0        # Yatay önden bakış mesafesi
@export var offset_y: float = -50.0        # Dikey offset (negatif = yukarı)
@export var look_ahead: bool = true        # Hareket yönüne göre öne bak

var _target_node: Node2D
var _current_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	if target:
		_target_node = get_node(target)
	else:
		# Target atanmamışsa parent'ı kullan
		_target_node = get_parent()
	
	# Kamerayı hemen konumlandır (ilk karede zıplama olmasın)
	if _target_node:
		global_position = _target_node.global_position

func _physics_process(delta: float) -> void:
	if not _target_node:
		return
	
	var target_pos = _target_node.global_position
	
	# Hareket yönüne göre öne bakış
	if look_ahead:
		var velocity = Vector2.ZERO
		
		# CharacterBody2D veya velocity özelliği olan node'lar için
		if _target_node.has_method("get") and "velocity" in _target_node:
			velocity = _target_node.velocity
		
		if velocity.x > 10:
			_current_offset = _current_offset.lerp(Vector2(offset_x, offset_y), delta * 3.0)
		elif velocity.x < -10:
			_current_offset = _current_offset.lerp(Vector2(-offset_x, offset_y), delta * 3.0)
		else:
			_current_offset = _current_offset.lerp(Vector2(0, offset_y), delta * 2.0)
	else:
		_current_offset = Vector2(0, offset_y)
	
	# Yumuşak takip (Lerp)
	var desired_pos = target_pos + _current_offset
	global_position = global_position.lerp(desired_pos, delta * smoothing_speed)
