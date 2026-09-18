extends CanvasLayer

@onready var heart_label = $Score
@onready var player = get_node("../Player")
@onready var game_over_screen = $GameOverScreen
@onready var message_label = $GameOverScreen/MessageLabel
@onready var background = $GameOverScreen/ColorRect

func _ready() -> void:
	player.hearts_changed.connect(_on_hearts_changed)
	player.player_won.connect(_on_player_won)
	player.player_died.connect(_on_player_died)
	game_over_screen.visible = false

func _on_hearts_changed(count: int, total: int) -> void:
	heart_label.text = "%d / %d" % [count, total]

func _on_player_won() -> void:
	message_label.text = "You Win!"
	background.color = Color(0, 0.6, 0, 0.7)  # yeşil
	game_over_screen.visible = true
	_start_replay_timer()

func _on_player_died() -> void:
	message_label.text = "You Lose"
	background.color = Color(0.6, 0, 0, 0.7)  # kırmızı
	game_over_screen.visible = true
	_start_replay_timer()

func _start_replay_timer() -> void:
	await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()
