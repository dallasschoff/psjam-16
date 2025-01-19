extends TextureProgressBar
class_name HealthBar

func update(health):
	var difference = health - value
	value += difference
