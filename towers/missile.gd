extends Area2D

### Variables ###

export var speed = 2.0 # Speed in tiles/second

var exploded = false

# Set by the tower class by calling setup()
var direction = Vector2()
var damage_funcref
var distance_left = 1.0

# Nodes
var global

### Callbacks ###

func _ready():
	global = get_node("/root/global")
	
	get_node("animation_player").connect("finished", self, "_on_animation_player_finished")
	
	set_fixed_process(true)

func _fixed_process(delta):
	if not exploded:
		# Check if we have to explode
		var enemies = get_overlapping_areas()
		for enemy in enemies:
			if enemy.get("hp"):
				distance_left = min(distance_left, 0.2)
				break
		
		# Explode when no distance is left
		distance_left -= (direction*speed*delta).length()
		if distance_left <= 0:
			explode(enemies)
		
		# Handle movement
		var motion = direction*speed*global.TILE_SIZE*delta
		set_pos(get_pos() + motion)

### Functions ###

func setup(_direction, _damage_funcref, _distance_left):
	"""Static init function as PackedScenes can't be passed arguments for _init"""
	direction = _direction
	damage_funcref = _damage_funcref
	distance_left = _distance_left

func explode(enemies):
	exploded = true # Mark the missile as exploded, so it won't explode again
	
	# Decrease health
	for enemy in enemies:
		if enemy.get("hp"):
			damage_funcref.call_func(enemy)
	
	# Play animation
	get_node("animation_player").play("explode")

### Signals ###

func _on_animation_player_finished():
	if get_node("animation_player").get_current_animation() == "explode":
		# We just finished playing the explode animation, so free the object
		queue_free()
	