extends Node3D
## Удочка: управление анимациями «idle», «cast» и «reel».
##
## Управление:
##   ЛКМ — заброс (анимация "cast")
##   ПКМ — подсечка (анимация "reel")
##   По умолчанию, когда ничего не происходит, играет зацикленная "idle".
##
## Скрипт вешается на корневой узел сцены FishingRod.tscn.
## Скрипт ничего не знает о внутреннем устройстве модели: он только дергает
## анимации у AnimationPlayer, поэтому удочку можно свободно переделывать.

# --- Константы ----------------------------------------------------------------

## Имена анимаций внутри AnimationPlayer.
const ANIM_IDLE: StringName = &"idle"
const ANIM_CAST: StringName = &"cast"
const ANIM_REEL: StringName = &"reel"

# --- Внутреннее состояние -----------------------------------------------------

## Идёт ли «важное» действие (заброс или подсечка).
## Пока true — новые нажатия игнорируются, чтобы анимации не рвали друг друга.
var _is_busy: bool = false

# --- Ссылки на узлы -----------------------------------------------------------

## Плеер анимаций — прямой потомок корневого узла сцены.
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# --- Жизненный цикл -----------------------------------------------------------

func _ready() -> void:
	# Как только заброс/подсечка доиграли — сами возвращаемся в покой.
	animation_player.animation_finished.connect(_on_animation_finished)
	_play_idle()

func _unhandled_input(event: InputEvent) -> void:
	# Реагируем только на нажатия кнопок мыши (не на отпускание и не на движение).
	if not (event is InputEventMouseButton):
		return

	var mouse_event: InputEventMouseButton = event as InputEventMouseButton
	if not mouse_event.pressed:
		return

	match mouse_event.button_index:
		MOUSE_BUTTON_LEFT:
			cast()
		MOUSE_BUTTON_RIGHT:
			reel()
		_:
			pass  # Остальные кнопки мыши удочку не интересуют.

# --- Публичный API ------------------------------------------------------------

## Заброс: замах удилищем назад и резкий хлёст вперёд.
## Можно вызывать и снаружи — из UI, бота-рыбака, триггера и т.п.
func cast() -> void:
	if _is_busy:
		return
	_play(ANIM_CAST, true)

## Подсечка: короткое резкое движение удилищем вверх.
func reel() -> void:
	if _is_busy:
		return
	_play(ANIM_REEL, true)

## Занята ли удочка действием (заброс/подсечка в процессе).
func is_busy() -> bool:
	return _is_busy

## Текущая проигрываемая анимация — удобно для отладки и UI.
func get_current_animation() -> StringName:
	return animation_player.current_animation

# --- Внутренняя логика --------------------------------------------------------

## Вернуть удочку в состояние покоя.
func _play_idle() -> void:
	_is_busy = false
	_play(ANIM_IDLE, false)

## Запустить анимацию по имени.
## anim_name — имя анимации в AnimationPlayer,
## busy — считать ли её «важным» действием (блокирует ввод до конца проигрывания).
func _play(anim_name: StringName, busy: bool) -> void:
	# Страхуемся от опечатки в имени или потерянной анимации в сцене.
	if not animation_player.has_animation(anim_name):
		push_warning("Удочка: в AnimationPlayer нет анимации «%s»." % anim_name)
		return

	_is_busy = busy
	animation_player.play(anim_name)

# --- Сигналы ------------------------------------------------------------------

## Заброс или подсечка закончились — плавно уходим в покой.
## Для зацикленной "idle" этот сигнал не приходит, поэтому лишний раз в неё не заходим.
func _on_animation_finished(_anim_name: StringName) -> void:
	_play_idle()
