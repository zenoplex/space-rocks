class_name Rock
extends RigidBody2D

signal exploded(size: int, radius: int, position: Vector2, linear_velocity: Vector2)

var screensize := Vector2.ZERO
var size := 0
var radius := 0
var scale_factor := 0.2

@onready var explosion: Explosion = get_node("Explosion")
@onready var sprite2D: Sprite2D = get_node("Sprite2D")
@onready var collision_shape2D: CollisionShape2D = get_node("CollisionShape2D")

func start(_position: Vector2, _velocity: Vector2, _size: int) -> void:
	position = _position
	size = _size
	mass = 1.5 * size
	explosion.hide()
	explosion.scale = Vector2.ONE * size

	var calc_scale := scale_factor * size
	sprite2D.scale = Vector2.ONE * calc_scale
	radius = int(sprite2D.texture.get_size().x * 0.5 * calc_scale)
	var shape := CircleShape2D.new()
	shape.set_radius(radius)
	collision_shape2D.shape = shape
	linear_velocity = _velocity
	angular_velocity = randf_range(-PI, PI)

func _integrate_forces(physics_state: PhysicsDirectBodyState2D) -> void:
	var transform2d := physics_state.transform
	transform2d.origin.x = wrap(transform2d.origin.x, -radius, screensize.x + radius)
	transform2d.origin.y = wrap(transform2d.origin.y, -radius, screensize.y + radius)
	physics_state.transform = transform2d

func explode() -> void:
	collision_shape2D.set_deferred("disabled", true)
	sprite2D.hide()
	
	exploded.emit(size, radius, position, linear_velocity)
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	
	await explosion.play()
	queue_free()
