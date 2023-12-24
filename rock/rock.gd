extends RigidBody2D
# emits size, radius, position, linear_velocity)
signal exploded

var screensize := Vector2.ZERO
var size := 0
var radius := 0
var scale_factor := 0.2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func start(_position: Vector2, _velocity: Vector2, _size: int) -> void:
	position = _position
	size = _size
	mass = 1.5 * size
	$Explosion.hide()
	$Explosion.scale = Vector2.ONE * size

	var calc_scale := scale_factor * size
	$Sprite2D.scale = Vector2.ONE * calc_scale
	radius = int($Sprite2D.texture.get_size().x * 0.5 * calc_scale)
	var shape := CircleShape2D.new()
	shape.set_radius(radius)
	$CollisionShape2D.shape = shape
	linear_velocity = _velocity
	angular_velocity = randf_range(-PI, PI)

func _integrate_forces(physics_state: PhysicsDirectBodyState2D) -> void:
	var transform2d := physics_state.transform
	transform2d.origin.x = wrap(transform2d.origin.x, -radius, screensize.x + radius)
	transform2d.origin.y = wrap(transform2d.origin.y, -radius, screensize.y + radius)
	physics_state.transform = transform2d

func explode() -> void:
	$CollisionShape2D.set_deferred("disabled", true)
	$Sprite2D.hide()
	
	exploded.emit(size, radius, position, linear_velocity)
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	
	$Explosion/AnimationPlayer.play("explosion")
	$Explosion.show()
	await $Explosion/AnimationPlayer.animation_finished
	queue_free()
