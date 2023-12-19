extends RigidBody2D

@export var engine_power: int = 500
@export var spin_power: int = 8000

enum { INIT, ALIVE, INVULNERABLE, DEAD }
var state: int = INIT
var thrust: Vector2 = Vector2.ZERO
var rotation_dir: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	linear_damp = 1.0
	angular_damp = 5.0
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
func _process(_delta):
	get_input()

func get_input() -> void:
	thrust = Vector2.ZERO
	if state in [DEAD, INIT]:
		return

	if Input.is_action_pressed("thrust"):
		thrust = transform.x * engine_power
		rotation_dir = Input.get_axis("rotate_left", "rotate_right")

func _physics_process(_delta: float) -> void:
	constant_force = thrust
	constant_torque = rotation_dir * spin_power
