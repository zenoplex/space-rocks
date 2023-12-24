extends CanvasLayer

signal start_game

@onready var lives_counter: HBoxContainer = $MarginContainer/HBoxContainer/LivesCounter
@onready var score_label: Label = $MarginContainer/HBoxContainer/ScoreLabel
@onready var message_label: Label = $VBoxContainer/MessageLabel
@onready var start_button: TextureButton = $VBoxContainer/StartButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_start_button_pressed() -> void:
	start_button.hide()
	start_game.emit()

func _on_timer_timeout() -> void:
	message_label.hide()
	message_label.text = ""

func show_message(text: String) -> void:
	message_label.text = text
	message_label.show()
	$Timer.start()

func update_score(score: int) -> void:
	score_label.text = str(score)

func update_lives(lives: int) -> void:
	var children: Array[Node] = lives_counter.get_children()
	for index in len(children):
		children[index].visible = index > lives
