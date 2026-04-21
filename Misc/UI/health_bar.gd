extends ProgressBar


var health = 100 : set = set_health

func set_health(new_health):
	health = new_health
	value = new_health
	$Label.text = str(new_health)
