extends RigidBody2D
enum { INIT, ALIVE, INVULNERABLE, DEAD }
var state: int = INIT

# Called when the node enters the scene tree for the first time.
func _ready():
	change_state(INIT)

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
	
	state = DEAD		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
