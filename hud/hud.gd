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
