extends Node2D

export var maximum_clouds = 50
export var timer_cooldown = 30

var wind_direction = Vector2(1, 1).normalized()
var wind_speed = 5

onready var timer = $SpawnCloudTimer

var clouds = []

onready var cloud_textures = {
	"1": preload("res://assets/graphics/clouds/clouds1.png"),
	"2": preload("res://assets/graphics/clouds/clouds2.png"),
	"3": preload("res://assets/graphics/clouds/clouds3.png"),
	"4": preload("res://assets/graphics/clouds/clouds4.png"),
}

var boundaries = {
	"min": {
		"x": -200,
		"y": -200,
	},
	"max": {
		"x": 200,
		"y": 200,
	}
}

func _ready():
	timer.connect("timeout", self, "_on_timer_timeout")
	start_timer()
	add_cloud()


func start_timer():
	timer.wait_time = timer_cooldown + ((randf() - 0.5) * timer_cooldown * 0.2)
	print(timer.wait_time)
	timer.start()

# this isn't the cleanest algorithm, but
# it takes an axis of possible cloud spawn positions perpendicular to the wind direction
# and then chooses a point on this axis
# after this the point gets dragged back to the side of the box where the wind originates from, and bounded to the box
func random_spawn_point() -> Vector2:
	var center = Vector2(boundaries.min.x, boundaries.min.y) + Vector2(boundaries.max.x, boundaries.max.y)
	var perpendicular_to_wind = wind_direction.rotated(PI / 2)
	var distance_measure = sqrt(perpendicular_to_wind.x * perpendicular_to_wind.x + perpendicular_to_wind.y * perpendicular_to_wind.y)
	var total_distance = distance_measure * (boundaries.max.x - boundaries.min.x)
	var location = center + (randf() - 0.5) * total_distance * perpendicular_to_wind
	location -= wind_direction * total_distance * 0.75 + randf() * 0.25 * wind_direction * total_distance
	location.x = min(boundaries.max.x, max(location.x, boundaries.min.x))
	location.y = min(boundaries.max.y, max(location.y, boundaries.min.y))
	print(location)
	return location
	
func add_cloud():
	if clouds.size() >= maximum_clouds:
		return
	var cloud = Sprite.new()
	add_child(cloud)
	
	var spawn_point = random_spawn_point()
	cloud.position = spawn_point
	var texture = cloud_textures.values()[randi() % cloud_textures.size()]
	cloud.texture = texture
#	cloud.scale = Vector2(2, 2)
	cloud.modulate = Color(0.1, 0.1, 0.1, 0.4)
	clouds.append(cloud)
	
func _physics_process(delta):
	var clouds_to_delete = []
	for cloud in clouds:
		cloud.position += wind_direction * wind_speed * delta
		
		if cloud.position.x < boundaries.min.x - 50 and cloud.position.y < boundaries.min.y - 50:
			 clouds_to_delete.append(cloud)
		if cloud.position.x > boundaries.max.x + 50 and cloud.position.y > boundaries.max.y + 50:
			 clouds_to_delete.append(cloud)
			
	for cloud in clouds_to_delete:
		clouds.erase(cloud)
		remove_child(cloud)
		cloud.queue_free()
		
func _on_timer_timeout():
	add_cloud()
	start_timer()
