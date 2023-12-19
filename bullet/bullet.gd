extends Area2D
@export var speed: int = 1000

var velocity: Vector2 = Vector2.ZERO

func _ready():
	start(transform)

func start(_transform: Transform2D) -> void:
	transform = _transform
	velocity = transform.x * speed

func _process(delta: float) -> void:
	position += velocity * delta
