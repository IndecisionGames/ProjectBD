extends Control

onready var progress = find_node("progress")
onready var tween = find_node("Tween")

func set_progress(n, tween_duration=0.5):
	var target = n * 100
	tween.interpolate_property(progress, "value", progress.value, target, tween_duration, Tween.TRANS_SINE, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_completed")

func reset():
	progress.value = 0
