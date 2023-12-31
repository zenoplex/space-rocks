class_name Player
extends RigidBody2D

## Emits lives_changed(lives: int)
signal lives_changed
signal dead
## Emits shield_changed(shield_percent: float)
signal shield_changed

@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.25
@export var engine_power: int = 500
@export var spin_power: int = 8000
var max_shield := 100.0
var shield_regen := 5.0
var shield := 0.0: set = set_shield

@onready var explosion: Explosion = get_node("Explosion")
@onready var invulnerabilityTimer: Timer = get_node("InvulnerabilityTimer")
@onready var collisionShape2D: CollisionShape2D = get_node("CollisionShape2D")
@onready var gunCooldownTimer: Timer = get_node("GunCooldownTimer")
@onready var muzzle: Node2D = get_node("Muzzle")
@onready var sprite2D: Sprite2D = get_node("Sprite2D")

enum Status { INIT, ALIVE, INVULNERABLE, DEAD }
var state :Status = Status.INIT
var thrust := Vector2.ZERO
var rotation_dir := 0.0
var screensize := Vector2.ZERO
var size := Vector2.ZERO
var can_shoot := true
var reset_pos := false
var lives := 0: set = set_lives

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	explosion.hide()
	invulnerabilityTimer.one_shot = true
	invulnerabilityTimer.wait_time = 2.0
	contact_monitor = true
	max_contacts_reported = 1

	gunCooldownTimer.wait_time = fire_rate
	linear_damp = 1.0
	angular_damp = 5.0
	screensize = get_viewport_rect().size
	size = collisionShape2D.shape.get_rect().size

func change_state(new_state: Status) -> void:
	match new_state:
		Status.INIT:
			collisionShape2D.set_deferred("disabled", false)
			sprite2D.modulate.a = 0.5
		Status.ALIVE:
			collisionShape2D.set_deferred("disabled", false)
			sprite2D.modulate.a = 1.0
		Status.INVULNERABLE:
			collisionShape2D.set_deferred("disabled", true)
			sprite2D.modulate.a = 0.5
			invulnerabilityTimer.start()
		Status.DEAD:
			collisionShape2D.set_deferred("disabled", true)
			sprite2D.hide()
			linear_velocity = Vector2.ZERO
			angular_velocity = 0.0
			dead.emit()
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
	gunCooldownTimer.start()
	var node: Bullet = bullet_scene.instantiate() as Bullet
	node.start(muzzle.global_transform)
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

func reset() -> void:
	reset_pos = true
	lives = 3
	shield = max_shield
	sprite2D.show()
	change_state(Status.ALIVE)

func _physics_process(_delta: float) -> void:
	constant_force = thrust
	constant_torque = rotation_dir * spin_power

func _integrate_forces(physics_state: PhysicsDirectBodyState2D) -> void:
	if (reset_pos):
		reset_pos = false
		physics_state.transform.origin = screensize * 0.5
		physics_state.linear_velocity = Vector2.ZERO
		physics_state.angular_velocity = 0.0
	
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
	shield = max_shield
	if (lives < 1):
		change_state(Status.DEAD)
	else:
		change_state(Status.INVULNERABLE)

func _on_invulnerability_timer_timeout() -> void:
	change_state(Status.ALIVE)

func _explode() -> void:
	await explosion.play()

func _on_body_entered(body:Node) -> void:
	if body is Rock:
		var node := body as Rock
		node.explode()
		# TODO: All base damage should be set in game settings
		shield -= node.size * 25

func set_shield(value: float) -> void:
	var new_shield: Variant = min(value, max_shield)
	print_debug("set_shield: %s" % new_shield)
	if new_shield is float:
		shield = new_shield
		shield_changed.emit(new_shield / max_shield)
		if shield < 1:
			lives -= 1
			_explode()
	