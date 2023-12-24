extends Node
@export var rock_scene: PackedScene

# Type annotation is required for for loops
const offsets: Array[int] = [-1 ,1]
var screensize := Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screensize = get_viewport().get_visible_rect().size
	
	for i in 3:
		$RockPath/RockSpawn.progress = randi()
		var pos: Vector2 = $RockPath/RockSpawn.position
		var vel := Vector2.RIGHT.rotated(randf_range(0, TAU)) * randf_range(50, 125)
		print(vel)
		spawn_rock(pos, vel, i + 1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func spawn_rock(position: Vector2, velocity: Vector2, size: int) -> void:
	var node := rock_scene.instantiate()
	node.screensize = screensize
	node.start(position, velocity, size)
	call_deferred("add_child", node)
	node.exploded.connect(self._on_rock_exploded)
	
func _on_rock_exploded(size: int, radius: int, position: Vector2, linear_velocity: Vector2) -> void:
	if size < 2:
		return
	
	for offset in offsets:
		var direction: Vector2 = $Player.position.direction_to(position).orthogonal() * offset
		var new_position := position + direction * radius
		var new_velocity := direction * linear_velocity.length() * 1.1
		spawn_rock(new_position, new_velocity, size - 1)
