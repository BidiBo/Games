class_name enemigo extends CharacterBody2D

@onready var jugador: Jugador = $"../Jugador"
@onready var sprite_animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var area_attack: Area2D = $AreaAttack # Área de ataque del enemigo
@onready var health_componentes: Health_Componentes = $Componentes/Health_Componentes


var move_speed := 40
var attack_damage := 10
var is_attack := false
var detection_radius := 140 
var flip_threshold := 0.1
var min_distance := 30 # Distancia mínima para evitar que el enemigo se acerque demasiado al jugador
var in_attack_player_range := false

func _ready() -> void:
	health_componentes.death.connect(on_death)
	if jugador:
		jugador.attack_finish.connect(verificar_daño_recibido)

func _physics_process(delta: float) -> void:
	if jugador:
		var distance_to_player = position.distance_to(jugador.position)
		
		if distance_to_player <= detection_radius and distance_to_player > min_distance:
			# Enemigo se mueve hacia el jugador
			if not is_attack:
				sprite_animation.play("run")
			
			var move_direction = (jugador.position - position).normalized()
			velocity = move_direction * move_speed
			
			# Solo voltear el sprite si el movimiento en X supera el umbral
			if abs(move_direction.x) > flip_threshold:
				sprite_animation.flip_h = move_direction.x < 0
			area_attack.scale.x = -1 if move_direction.x < 0 else 1
			move_and_slide()
		elif distance_to_player <= min_distance:
			# Detener movimiento pero permitir ataque
			velocity = Vector2.ZERO
			if not is_attack:
				sprite_animation.play("idle")
		else:
			# Comportamiento cuando el jugador está fuera del rango
			sprite_animation.play("idle")
			is_attack = false


func attack():
	if not is_attack:
		sprite_animation.play("ataque")
		is_attack = true

func verificar_daño_recibido():
	if in_attack_player_range:
		health_componentes.receive_damage(jugador.attack_damage)
	
func on_death():
	queue_free()


func _on_area_attack_body_entered(body: Node2D) -> void:
	if body is Jugador and not is_attack:
		attack()

func _on_area_attack_body_exited(body: Node2D) -> void:
	if body is Jugador:
		is_attack = false

	

func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite_animation.animation == "ataque" and is_attack:
		# Aplicar daño al jugador solo cuando termine la animación de ataque
		jugador.health_componentes.receive_damage(attack_damage)
		is_attack = false
		attack()
