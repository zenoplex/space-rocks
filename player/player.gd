class_name Player
extends RigidBody2D

## Emits lives_changed(lives: int)
signal lives_changed
signal dead
var reset_pos := false
var lives := 0: set = set_lives

@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.25
@export var engine_power: int = 500
@export var spin_power: int = 8000

enum Status { INIT, ALIVE, INVULNERABLE, DEAD }
var state :Status = Status.INIT
var thrust := Vector2.ZERO
var rotation_dir := 0.0
var screensize := Vector2.ZERO
var size := Vector2.ZERO
var can_shoot := true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$GunCooldownTimer.wait_time = fire_rate
	linear_damp = 1.0
	angular_damp = 5.0
	screensize = get_viewport_rect().size
	size = $CollisionShape2D.shape.get_rect().size
	# TODO: set to INIT after testing
	change_state(Status.ALIVE)

func change_state(new_state: Status) -> void:
	match new_state:
		Status.INIT:
			$CollisionShape2D.set_deferred("disabled", false)
		Status.ALIVE:
			$CollisionShape2D.set_deferred("disabled", false)
		Status.INVULNERABLE:
			$CollisionShape2D.set_deferred("disabled", true)
		Status.DEAD:
			$CollisionShape2D.set_deferred("disabled", true)
		_: 
			assert(false, "Invalid state passed to change_state: %s" % new_state)
	
	state = new_state

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	get_input()

func shoot() -> void:
	if state == Status.INVULNERABLE:
		return
	
	can_shoot = false
	$GunCooldownTimer.start()
	var node := bullet_scene.instantiate()
	node.start($Muzzle.global_transform)
	get_tree().root.add_child(node)

func get_input() -> void:
	thrust = Vector2.ZERO
	if state in [Status.DEAD, Status.INIT]:
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
	# TODO: half_size should be cached as instance variable
	var half_size := size / 2
	var transform2d := physics_state.transform
	transform2d.origin.x = wrap(transform2d.origin.x, -half_size.x , screensize.x + half_size.x)
	transform2d.origin.y = wrap(transform2d.origin.y, -half_size.y , screensize.y + half_size.y)
	physics_state.transform = transform2d
	
func _on_gun_cooldown_timer_timeout() -> void:
	can_shoot = true

func set_lives(value: int) -> void:
	lives = value
	lives_changed.emit(lives)
	if (lives < 1):
		change_state(Status.DEAD)
	else:
		change_state(Status.INVULNERABLE)
