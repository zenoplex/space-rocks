extends RigidBody2D

@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.25
@export var engine_power: int = 500
@export var spin_power: int = 8000

enum { INIT, ALIVE, INVULNERABLE, DEAD }
var state: int = INIT
var thrust: Vector2 = Vector2.ZERO
var rotation_dir: float = 0.0
var screensize: Vector2 = Vector2.ZERO
var size: Vector2 = Vector2.ZERO
var can_shoot: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$GunCooldownTimer.wait_time = fire_rate
	linear_damp = 1.0
	angular_damp = 5.0
	screensize = get_viewport_rect().size
	size = $CollisionShape2D.shape.get_rect().size
	# TODO: set to INIT after testing
	change_state(ALIVE)

func change_state(new_state: int) -> void:
	match new_state:
		INIT:
			$CollisionShape2D.set_deferred("disabled", false)
		ALIVE:
			$CollisionShape2D.set_deferred("disabled", false)
		INVULNERABLE:
			$CollisionShape2D.set_deferred("disabled", true)
		DEAD:
			$CollisionShape2D.set_deferred("disabled", true)
		_: 
			assert(false, "Invalid state passed to change_state: %s" % new_state)
	
	state = new_state		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	get_input()

func shoot() -> void:
	if state == INVULNERABLE:
		return
	
	can_shoot = false
	$GunCooldownTimer.start()
	var node: Node = bullet_scene.instantiate()
	node.start($Muzzle.global_transform)
	get_tree().root.add_child(node)

func get_input() -> void:
	thrust = Vector2.ZERO
	if state in [DEAD, INIT]:
		return

	if Input.is_action_pressed("thrust"):
		thrust = transform.x * engine_power
		rotation_dir = Input.get_axis("rotate_left", "rotate_right")
	
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()

func _physics_process(_delta: float) -> void:
	constant_force = thrust
	constant_torque = rotation_dir * spin_power

func _integrate_forces(physics_state: PhysicsDirectBodyState2D) -> void:
	var half_size: Vector2 = size / 2
	var transform2d: Transform2D = physics_state.transform
	transform2d.origin.x = wrap(transform2d.origin.x, -half_size.x , screensize.x + half_size.x)
	transform2d.origin.y = wrap(transform2d.origin.y, -half_size.y , screensize.y + half_size.y)
	physics_state.transform = transform2d
	
