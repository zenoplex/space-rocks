extends RigidBody2D
var screensize: Vector2 = Vector2.ZERO
var size: int = 0
var radius: int = 0
var scale_factor: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func start(_position: Vector2, _velocity: Vector2, _size: int) -> void:
	position = _position
	size = _size
	mass = 1.5 * size

	var calc_scale: float = scale_factor * size
	$Sprite2D.scale = Vector2.ONE * calc_scale
	radius = int($Sprite2D.texture.get_size().x * 0.5 * calc_scale)
	var shape: CircleShape2D = CircleShape2D.new()
	shape.set_radius(radius)
	$CollisionShape2D.shape = shape
	linear_velocity = _velocity
	angular_velocity = randf_range(-PI, PI)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
