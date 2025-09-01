extends CharacterBody2D


@export var SPEED = 100
@export var JUMP_HEIGHT = 

var facing_right = true


func _ready() -> void:
	$AnimatedSprite2D.play()


func _process(delta: float) -> void:
	if facing_right:
		$AnimatedSprite2D.flip_h = false
	else:
		$AnimatedSprite2D.flip_h = true
	
	if velocity.x == 0:
		$AnimatedSprite2D.animation = "idle"
	else:
		$AnimatedSprite2D.animation = "walking"


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
	#	velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if velocity.x > 0:
		facing_right = true
	elif velocity.x < 0:
		facing_right = false

	move_and_slide()
