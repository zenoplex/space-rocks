extends Node
@export var rock_scene: PackedScene

var screensize: Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screensize = get_viewport().get_visible_rect().size
	
	for i in 3:
		$RockPath/RockSpawn.progress = randi()
		var pos: Vector2 = $RockPath/RockSpawn.position
		var vel: Vector2 = Vector2.RIGHT.rotated(randf_range(0, TAU)) * randf_range(50, 125)
		print(vel)
		spawn_rock(pos, vel, i + 1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func spawn_rock(position: Vector2, velocity: Vector2, size: int) -> void:
	var node: Node = rock_scene.instantiate()
	node.screensize = screensize
	node.start(position, velocity, size)
	# TODO: maybe replace with call_deferred("add_child", node)
	add_child(node)
	
