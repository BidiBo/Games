extends Node2D
@onready var node_2d: Node2D = $"."
@onready var jugador: Jugador = $Jugador
@onready var timer_spawn_enemy: Timer = $timer_SpawnEnemy
const ENEMIGO = preload("res://Scenes/enemigo.tscn")
var timer_second_spawn_enemy := 2

func _ready() -> void:
	timer_spawn_enemy.timeout.connect(spawn_enemy)
	timer_spawn_enemy.wait_time = timer_second_spawn_enemy
	timer_spawn_enemy.start()
	
func spawn_enemy():
	var enemy = ENEMIGO.instantiate()
	
	var random_angle: float = randf() * PI * 2
	
	var spawn_distance: float = randf_range(270, 300)
	
	var spawn_offset: Vector2 = Vector2(cos(random_angle), sin(random_angle)) * spawn_distance
	
	enemy.position = spawn_offset + jugador.position
	
	add_child(enemy)
