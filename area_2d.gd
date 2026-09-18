extends Area2D

@onready var collect_sound = $CollectSound
var collected := false

func _ready() -> void:
	add_to_group("hearts")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if collected:
		return
	if body.has_method("collect_heart"):
		collected = true
		body.collect_heart()
		_play_and_remove()

func _play_and_remove() -> void:
	collect_sound.play()
	$CollisionShape2D.set_deferred("disabled", true)
	visible = false
	await collect_sound.finished
	queue_free()
