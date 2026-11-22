# WORKING EXAMPLE from the trailer for "Keep an Eye". To reuse it for your game, rename:
#   - the node/field names it reads from your main scene (game.title_layer, game.hud_layer, ...),
#   - the _shot_<name> functions (keep the helpers; write your own shots),
#   - res:// asset paths. Keep an Eye specific shots start with v_ (hand, eye, goats, shadow).
# Run with your own Godot executable, for example:
#   "$GODOT_PATH" --path . --write-movie OUT.avi --fixed-fps 30 --script res://tools/trailer/trailer_shot.gd -- --shot NAME --seconds S
extends SceneTree
## In-engine trailer director. Records one shot per run with Godot's movie writer:
##   engine --path . --write-movie out.avi --fixed-fps 30 \
##          --script res://tools/trailer/trailer_shot.gd -- --shot eye --seconds 4
## Shots use the real game: its models, lighting, shaders, animals and sound.
## Music is muted per shot; the edit lays your score underneath.

var game: Node
var shot := "island"
var seconds := 4.0
var caption_text := ""
var caption: Label
var frame := 0
const FPS := 30.0

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	for i in range(args.size() - 1):
		if args[i] == "--shot": shot = args[i + 1]
		if args[i] == "--seconds": seconds = float(args[i + 1])
		if args[i] == "--caption": caption_text = args[i + 1]
	call_deferred("_run")

func _run() -> void:
	game = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	await process_frame
	game.menu_visible = false
	game.title_layer.hide()
	game.hud_layer.hide()
	game.cross_layer.hide()
	game.set_physics_process(false)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), true)
	_make_caption()
	await call("_shot_" + shot)
	quit()

# --- helpers -----------------------------------------------------------------

func _make_caption() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 50
	root.add_child(layer)
	caption = Label.new()
	caption.text = caption_text
	caption.add_theme_font_override("font", game.narrative_font)
	caption.add_theme_font_size_override("font_size", 22)
	caption.add_theme_color_override("font_color", Color("#d8c8b4"))
	caption.add_theme_color_override("font_shadow_color", Color(0, 0, 0, .85))
	caption.add_theme_constant_override("shadow_offset_x", 2)
	caption.add_theme_constant_override("shadow_offset_y", 2)
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.position = Vector2(0, 286)
	caption.size = Vector2(640, 40)
	caption.modulate.a = 0.0
	layer.add_child(caption)

func _aim(at: Vector3, target: Vector3, fov: float = 62.0) -> void:
	game.player.global_position = at
	var d: Vector3 = target - game.camera.global_position
	game.player.rotation.y = atan2(-d.x, -d.z)
	game.camera.rotation.x = atan2(d.y, Vector2(d.x, d.z).length())
	game.camera.rotation.z = 0.0
	game.camera.fov = fov

func _tick(t: float) -> void:
	# Keep the cameraman alive and the caption breathing.
	game.health = 100.0
	if caption_text != "":
		caption.modulate.a = smoothstep(0.25, 0.9, t) * (1.0 - smoothstep(seconds - 0.7, seconds - 0.1, t))
	frame += 1

## Move from (pos_a looking at look_a) to (pos_b looking at look_b), eased.
func _move(pos_a: Vector3, look_a: Vector3, pos_b: Vector3, look_b: Vector3, fov_a := 62.0, fov_b := 62.0, events := {}, offset := Vector2.ZERO) -> void:
	var total := int(seconds * FPS)
	for i in range(total):
		var t := float(i) / FPS
		var k := smoothstep(0.0, 1.0, float(i) / maxf(1.0, total - 1))
		_aim(pos_a.lerp(pos_b, k), look_a.lerp(look_b, k), lerpf(fov_a, fov_b, k))
		game.player.rotation.y += offset.x
		game.camera.rotation.x += offset.y
		for at in events.keys():
			if is_equal_approx(snappedf(t, 1.0 / FPS), snappedf(float(at), 1.0 / FPS)):
				events[at].call()
		_tick(t)
		await process_frame

func _setup_day(day: int, fraction: float, shadow: float) -> void:
	game.day = day
	game.day_time = game.call("_day_length") * fraction
	game.shadow_progress = shadow
	game.call("_update_daily_note")
	game.call("_update_lighting")
	game.call("_update_shadow")
	game.audio_director.music("day%d_loop" % day, .1)

func _life() -> Node:
	return game.hand_root.find_child("LivingWatcher", true, false)

# --- shots -------------------------------------------------------------------

func _shot_island() -> void:
	_setup_day(1, .55, .16)
	await _move(Vector3(-15, 3.4, 13), Vector3(0, 9, -40), Vector3(-7.5, 1.6, 9.5), Vector3(0, 7, -40), 58.0, 50.0)

func _shot_eye() -> void:
	_setup_day(2, .6, .45)
	game.call("_update_shadow")
	var life := _life()
	var eye: Vector3 = life.eyeball.global_position
	life.look_mode = "wander"
	life.mode_timer = 99.0
	var lock := func(): life.look_mode = "watch"; life.mode_timer = 99.0; game.call("_play_sfx", "pupil_dilate", -2.0)
	await _move(Vector3(2, .15, 4), eye, Vector3(2, .15, 4), eye, 16.0, 10.0, {1.9: lock}, Vector2(-.12, .02))

func _shot_chop() -> void:
	_setup_day(1, .62, .14)
	game.has_axe = true
	game.call("_restore_axe_visual")
	for i in range(2):
		game.animals[i].position = Vector3(-4.6 + i * 1.2, 0, 12.2 - i)
	_aim(Vector3(-7, .16, 11.4), Vector3(-7, 1.5, 9))
	await process_frame
	game.interact_held = true
	game.call("_interact")
	await _move(Vector3(-7, .16, 11.4), Vector3(-7, 1.4, 9), Vector3(-6.8, .16, 11.6), Vector3(-7.1, 1.7, 9), 62.0, 58.0)

func _shot_shadow() -> void:
	_setup_day(3, .7, .26)
	var total := int(seconds * FPS)
	for i in range(total):
		var k := float(i) / maxf(1.0, total - 1)
		game.shadow_progress = lerpf(.26, .5, smoothstep(0, 1, k))
		game.call("_update_shadow")
		_aim(Vector3(4, 1.8, 6).lerp(Vector3(3, 1.4, 4.5), k), Vector3(-7, 0, -4), 60.0)
		_tick(float(i) / FPS)
		await process_frame

func _shot_offering() -> void:
	_setup_day(2, .66, .3)
	game.carrying_hen = true
	_aim(Vector3(0, .15, -.6), Vector3(0, .7, -3))
	await process_frame
	await process_frame
	var place := func(): game.call("_place_hen")
	var feed := func(): game.interact_held = true; game.call("_update_offering", 5.1); game.interact_held = false
	var eye: Vector3 = _life().eyeball.global_position
	await _move(Vector3(1.2, .15, .4), Vector3(0, .6, -3), Vector3(.5, .15, -.2), Vector3(0, .7, -3), 50.0, 38.0, {0.4: place, 2.0: feed})

func _shot_note() -> void:
	_setup_day(2, .7, .2)
	var spot: Vector2 = game.NOTE_SPOTS[1]
	var target := Vector3(spot.x, .4, spot.y)
	var read := func(): game.call("_show_note", 1)
	await _move(Vector3(10.5, .15, 4.0), target + Vector3(0, .8, 0), Vector3(13.0, .15, 2.2), target, 62.0, 55.0, {1.6: read})

func _shot_door() -> void:
	_setup_day(5, .95, .5)
	game.hut_door.set_meta("open", false)
	game.hut_door.rotation.y = 0.0
	var hut: Vector3 = game.HUT_POSITION
	await _move(hut + Vector3(.6, .15, -.6), hut + Vector3(.2, 1.3, 2.2), hut + Vector3(.45, .15, .9), hut + Vector3(.45, 1.25, 2.2), 64.0, 52.0)

func _shot_daycard() -> void:
	_setup_day(4, .1, .4)
	game.call("_present_day_card")
	var total := int(seconds * FPS)
	for i in range(total):
		_tick(float(i) / FPS)
		await process_frame

func _shot_hands() -> void:
	_setup_day(4, .6, .55)
	game.call("_update_shadow")
	var spots := [Vector3(-2.6, -.3, 3.0), Vector3(-3.1, -.3, .2), Vector3(-2.2, -.3, -1.9)]
	for at in spots:
		var creeper: Node3D = game.call("_spawn_small_hand", at, .032, 0.0, true)
		creeper.set_meta("creeper", true)
		game.creepers.append(creeper)
	game.creeper_spawn_timer = 99.0
	# Look away (they crawl), then whip back (they freeze).
	var total := int(seconds * FPS)
	for i in range(total):
		var t := float(i) / FPS
		var away := Vector3(12, 1.2, 4)
		var toward := Vector3(-2.6, .3, .6)
		var k := smoothstep(2.0, 2.45, t)
		_aim(Vector3(1.5, .15, 1.0), away.lerp(toward, k), lerpf(62.0, 44.0, smoothstep(2.4, seconds, t)))
		_tick(t)
		await process_frame

func _shot_well() -> void:
	_setup_day(2, .6, .2)
	game.well_eye_seen = false
	var show := func(): game.call("_show_well_eye")
	await _move(Vector3(10.8, .15, -2.2), Vector3(11.0, .45, -4.0), Vector3(10.8, .15, -2.5), Vector3(11.0, .5, -4.0), 32.0, 20.0, {0.2: show})

func _shot_shore() -> void:
	_setup_day(5, .53, .62)
	for i in range(3): await process_frame
	for small in game.small_hands:
		if small.get_meta("shore_scout", false): small.set_meta("born_day", game.day_time - 3.5)
	await _move(Vector3(12.5, .15, 1.5), Vector3(18.6, .4, -3.0), Vector3(13.2, .15, .4), Vector3(18.6, .3, -3.0), 60.0, 44.0)


func _shot_trail() -> void:
	# Day two: small wet footprints lead from the hut door down to the shore.
	_setup_day(2, .66, .2)
	var door: Vector3 = game.HUT_POSITION + Vector3(0, 0, 3.2)
	var shore := Vector3(game.NOTE_SPOTS[1].x, 0, game.NOTE_SPOTS[1].y)
	await _move(door + Vector3(-.6, .15, -1.4), door + Vector3(1.5, -.4, 1.2), door + Vector3(.9, .15, .2), shore, 64.0, 56.0)

func _shot_dying() -> void:
	# The shadow edge slides over a grazing goat and the crops; they are finished.
	_setup_day(3, .7, .30)
	var goat: Node3D = game.animals[1]
	var edge: float = game.call("_shadow_edge_x")
	goat.position = Vector3(edge + .9, 0, -.5)
	goat.set_meta("wander_wait", 99.0)
	goat.set_meta("wander_target", goat.position)
	var total := int(seconds * FPS)
	for i in range(total):
		var k := float(i) / maxf(1.0, total - 1)
		game.shadow_progress = lerpf(.30, .37, smoothstep(.15, .85, k))
		game.call("_update_shadow")
		_aim(Vector3(edge + 4.5, 1.25, 3.2).lerp(Vector3(edge + 3.8, 1.0, 2.4), k), Vector3(edge, .3, -1.2), 60.0)
		_tick(float(i) / FPS)
		await process_frame

func _shot_scream() -> void:
	# Late in the day, unfed: the eye screams and the island goes silent.
	_setup_day(3, .67, .5)
	game.offerings_today = 0
	game.eye_screamed = false
	var life := _life()
	var eye: Vector3 = life.eyeball.global_position
	life.look_mode = "watch"
	life.mode_timer = 99.0
	var total := int(seconds * FPS)
	for i in range(total):
		var t := float(i) / FPS
		var shake := smoothstep(1.0, 1.15, t) * (1.0 - smoothstep(1.2, 3.4, t))
		_aim(Vector3(2, .15, 4), eye, lerpf(22.0, 9.0, smoothstep(0.0, seconds, t)))
		game.player.rotation.y += -.12 + sin(t * 37.0) * .012 * shake
		game.camera.rotation.x += .02 + sin(t * 29.0) * .008 * shake
		if i == int(1.0 * FPS):
			game.day_time = game.call("_day_length") * .69
		_tick(t)
		await process_frame


# --- Teaser-style shots (0.6.3): one locked wide frame toward the sun ----------
# Dead ground left, living ground and hut right, the hand above the sun; time
# moves inside the frame. Driven by hand so the hand, light and shadow are exact.

const WIDE_AT := Vector3(.6, 4.6, 27.0)
const WIDE_LOOK := Vector3(.6, 4.6, -40.0)

func _wide_frame(fov: float) -> void:
	# Centre on the hand: horizon a little above the middle, ground filling the bottom.
	var look := WIDE_LOOK
	_aim(WIDE_AT, look, fov)
	# The visible palm sits about 8.5 m to +X of the eyeball node; aim at it.
	var palm: Vector3 = _life().eyeball.global_position + Vector3(8.5, 0, 0)
	var to_hand: Vector3 = palm - game.camera.global_position
	game.player.rotation.y = atan2(-to_hand.x, -to_hand.z) - .13
	game.camera.rotation.x += .045

func _drive(day: int, fraction: float, shadow: float, hand_drop: float = 0.0, hand_back: float = 0.0) -> void:
	game.day = day
	game.day_time = game.call("_day_length") * fraction
	game.shadow_progress = shadow
	game.call("_update_lighting")
	game.call("_update_shadow")
	# Trailer framing only: sit the hand further back so it hangs whole above the sun.
	game.hand_root.position.z -= hand_back
	game.hand_root.position.y += hand_drop + (12.0 if hand_back > 0.0 else 0.0)
	game.call("_animate_island", 1.0 / FPS)
	game.health = 100.0
	# The shadow finishes any animal it reaches, as in play.
	for animal in game.animals.duplicate():
		if is_instance_valid(animal) and game.call("_position_is_shadowed", animal.global_position):
			game.call("_create_carcass", animal.position, str(animal.get_meta("species", "goat")))
			animal.queue_free()
			game.animals.erase(animal)

func _wide_goats() -> void:
	# A few goats grazing on the living side, in the path of the shadow.
	var spots := [Vector3(2.2, 0, 7.5), Vector3(3.6, 0, 5.2), Vector3(5.0, 0, 8.6), Vector3(1.0, 0, 4.0), Vector3(6.4, 0, 6.0)]
	var index := 0
	for animal in game.animals:
		if str(animal.get_meta("species", "goat")) == "goat" and index < spots.size():
			animal.position = spots[index]
			animal.position.y = game.call("_terrain_height", spots[index].x, spots[index].z)
			animal.rotation.y = randf_range(-PI, PI)
			animal.set_meta("wander_wait", 99.0)
			animal.set_meta("wander_target", animal.position)
			index += 1

func _shot_t_dawn() -> void:
	# The island wakes; the hand lowers into the sky over the sun.
	game.set_process(false)
	_wide_goats()
	var total := int(seconds * FPS)
	for i in range(total):
		var t := float(i) / FPS
		var drop := lerpf(62.0, 0.0, smoothstep(1.8, seconds - .6, t))
		_drive(1, lerpf(.05, .45, t / seconds), .12, drop, 105.0)
		_wide_frame(40.0)
		await process_frame

func _shot_t_eye() -> void:
	game.set_process(false)
	_drive(2, .55, .45)
	var life := _life()
	life.look_mode = "watch"
	life.mode_timer = 99.0
	var eye: Vector3 = life.eyeball.global_position
	var total := int(seconds * FPS)
	for i in range(total):
		var t := float(i) / FPS
		_drive(2, .55, .45)
		# Centred on the visible eye, slowly pushing in (teaser close-up).
		_aim(Vector3(2, .15, 4), eye, lerpf(19.0, 15.5, t / seconds))
		game.player.rotation.y += -.19
		game.camera.rotation.x += .03
		await process_frame

func _shot_t_shadow() -> void:
	# Same frame later on: the shadow sweeps right and finishes the goats.
	game.set_process(false)
	_wide_goats()
	var total := int(seconds * FPS)
	for i in range(total):
		var t := float(i) / FPS
		_drive(3, lerpf(.50, .66, t / seconds), lerpf(.28, .60, smoothstep(.4, seconds - .4, t)), 0.0, lerpf(112.0, 88.0, t / seconds))
		_wide_frame(40.0)
		await process_frame

func _shot_t_dusk() -> void:
	# The last light: the hand at its closest, the island nearly finished.
	game.set_process(false)
	var total := int(seconds * FPS)
	for i in range(total):
		var t := float(i) / FPS
		_drive(4, lerpf(.70, .76, t / seconds), .66, 0.0, 74.0)
		_wide_frame(lerpf(40.0, 37.0, t / seconds))
		await process_frame


# --- Trailer v2 (0.6.5): the hand rises out of the sea; things die on camera ---
# Every v_ shot keeps the hand at its true in-game height, so its wrist stands
# in the water. Nothing from either ending is shown.

var rings: Array = []

func _hand_base_y() -> float:
	game.call("_update_shadow")
	return game.hand_root.position.y

## Look along yaw/pitch (radians) from a camera position (not the player's feet).
func _aim_angles(cam: Vector3, yaw: float, pitch: float, fov: float) -> void:
	game.player.global_position = cam - Vector3(0, game.camera.position.y, 0)
	game.player.rotation.y = yaw
	game.camera.rotation.x = pitch
	game.camera.rotation.z = 0.0
	game.camera.fov = fov

func _angles_to(cam: Vector3, target: Vector3) -> Vector2:
	var d := target - cam
	return Vector2(atan2(-d.x, -d.z), atan2(d.y, Vector2(d.x, d.z).length()))

func _eye_pos() -> Vector3:
	return _life().eyeball.global_position

## Pale ripples spreading where the wrist breaks the sea.
func _spawn_rings(at: Vector3) -> void:
	for i in range(4):
		var mat := StandardMaterial3D.new()
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_color = Color(.95, .5, .38, .85)
		var ring := MeshInstance3D.new()
		var torus := TorusMesh.new()
		torus.inner_radius = .86
		torus.outer_radius = 1.0
		torus.rings = 48
		ring.mesh = torus
		ring.material_override = mat
		ring.position = Vector3(at.x, -0.66, at.z)
		ring.scale = Vector3(1, .02, 1)
		ring.visible = false
		ring.set_meta("delay", i * .55)
		ring.set_meta("age", 0.0)
		game.add_child(ring)
		rings.append(ring)

func _tick_rings(dt: float, base_radius: float) -> void:
	for ring in rings:
		var age: float = ring.get_meta("age") + dt
		ring.set_meta("age", age)
		var k := clampf((age - float(ring.get_meta("delay"))) / 3.2, 0.0, 1.0)
		var r := base_radius * (1.0 + k * 1.6)
		ring.scale = Vector3(r, .02, r)
		ring.visible = k > 0.0 and k < 1.0
		(ring.material_override as StandardMaterial3D).albedo_color.a = .85 * (1.0 - k)

func _sweep(day: int, fraction: float, s0: float, s1: float, t0: float, t1: float, t: float) -> void:
	game.day = day
	game.day_time = game.call("_day_length") * fraction
	game.shadow_progress = lerpf(s0, s1, smoothstep(t0, t1, t))
	game.call("_update_lighting")
	game.call("_update_shadow")
	game.call("_animate_island", 1.0 / FPS)
	game.health = 100.0

## Shadow progress whose edge sits at world x.
func _shadow_for_x(x: float) -> float:
	var lo := 0.0
	var hi := 1.0
	for _i in range(24):
		var mid := (lo + hi) * .5
		game.shadow_progress = mid
		if float(game.call("_shadow_edge_x")) < x: lo = mid
		else: hi = mid
	return (lo + hi) * .5

## 1. Open on the grass, tilt and rise to the sea as the hand comes up out of it.
func _shot_v_open() -> void:
	game.set_process(false)
	_setup_day(1, .16, .12)
	var base := _hand_base_y()
	var hand_xz: Vector3 = game.hand_root.position
	for animal in game.animals: animal.hide()
	var cam_a := Vector3(-5.2, .3, 9.4)
	var cam_b := Vector3(-5.6, 1.67, 8.7)
	var a := _angles_to(cam_a, Vector3(-5.0, 0, 8.0))
	var b := _angles_to(cam_b, _eye_pos())
	game.hand_root.position.y = base - 82.0
	_spawn_rings(Vector3(hand_xz.x, 0, hand_xz.z - 6.0))
	var total := int(seconds * FPS)
	var rose := false
	for i in range(total):
		var t := float(i) / FPS
		var k := smoothstep(.6, seconds - 1.6, t)
		var up := smoothstep(2.2, seconds - .5, t)
		game.hand_root.position.y = base - 82.0 * (1.0 - up)
		if up > 0.0 and not rose:
			rose = true
			game.call("_play_sfx", "small_hand_rise_water", 4.0)
			game.call("_play_sfx", "hand_groan", 2.0)
		if rose: _tick_rings(1.0 / FPS, 14.0)
		game.call("_animate_island", 1.0 / FPS)
		_aim_angles(cam_a.lerp(cam_b, k), lerp_angle(a.x, b.x, k), lerpf(a.y, b.y, k), lerpf(70.0, 46.0, k))
		_tick(t)
		await process_frame

## 2. The eye drifts, then finds you.
func _shot_v_eye() -> void:
	game.set_process(false)
	_drive(2, .55, .45)
	var life := _life()
	life.look_mode = "wander"
	life.mode_timer = 99.0
	var total := int(seconds * FPS)
	for i in range(total):
		var t := float(i) / FPS
		if i == int(1.1 * FPS):
			life.look_mode = "watch"
			life.mode_timer = 99.0
			game.call("_play_sfx", "pupil_dilate", 2.0)
		_drive(2, .55, .45)
		_aim(Vector3(2, .15, 4), _eye_pos(), lerpf(19.0, 13.0, smoothstep(1.0, seconds, t)))
		game.player.rotation.y += -.19
		game.camera.rotation.x += .03
		await process_frame

## 3. Goats graze under the hand.
func _shot_v_goats() -> void:
	_setup_day(1, .45, .14)
	game.set_physics_process(false)
	_wide_goats()
	var cam_a := Vector3(7.6, .8, 11.4)
	var cam_b := Vector3(7.0, .85, 10.6)
	var total := int(seconds * FPS)
	for i in range(total):
		var t := float(i) / FPS
		var c := cam_a.lerp(cam_b, t / seconds)
		var ang := _angles_to(c, Vector3(3.2, 1.0, 5.6).lerp(_eye_pos(), .06))
		_aim_angles(c, ang.x, ang.y, 54.0)
		_tick(t)
		await process_frame

## 4. The ground dies: low over grass and crops as the shadow edge rolls in.
func _shot_v_ground() -> void:
	game.set_process(false)
	_setup_day(3, .6, .3)
	var plots: Array = game.farm_plots
	var center := Vector3.ZERO
	for p in plots: center += p.global_position
	center /= maxf(1.0, plots.size())
	# Side-on, so the dead edge rolls across the frame from left to right.
	var s0 := _shadow_for_x(center.x - 3.6)
	var s1 := _shadow_for_x(center.x + 3.4)
	var cam := center + Vector3(0, 1.5, 4.6)
	var total := int(seconds * FPS)
	for i in range(total):
		var t := float(i) / FPS
		_sweep(3, .6, s0, s1, .2, seconds - .2, t)
		var c := cam + Vector3(.6, -.25, -.6) * (t / seconds)
		var ang := _angles_to(c, center + Vector3(.3, -.1, 0))
		_aim_angles(c, ang.x, ang.y, 60.0)
		_tick(t)
		await process_frame

## 5. A goat in the shadow's path: it reaches her and she drops.
func _shot_v_goat_dies() -> void:
	game.set_process(false)
	_setup_day(3, .62, .3)
	var goat: Node3D = null
	for animal in game.animals:
		if str(animal.get_meta("species", "goat")) == "goat":
			goat = animal
			break
	var at := Vector3(3.0, 0, 3.5)
	at.y = game.call("_terrain_height", at.x, at.z)
	goat.position = at
	goat.rotation.y = -PI * .5
	goat.set_meta("wander_wait", 99.0)
	goat.set_meta("wander_target", at)
	for animal in game.animals:
		if animal != goat: animal.hide()
	var s0 := _shadow_for_x(at.x - 2.8)
	var s1 := _shadow_for_x(at.x + 1.8)
	var cam := at + Vector3(.25, .5, 2.1)
	var body: Node3D = null
	var fall_t := -1.0
	var total := int(seconds * FPS)
	for i in range(total):
		var t := float(i) / FPS
		_sweep(3, .62, s0, s1, .2, seconds - .6, t)
		if goat:
			goat.position = at
			goat.rotation.y = 0.0
		if goat and game.call("_position_is_shadowed", goat.global_position):
			var yaw := goat.rotation.y
			game.animals.erase(goat)
			goat.queue_free()
			goat = null
			game.call("_create_carcass", at, "goat")
			var remains: Node3D = game.dead_animals[-1]
			remains.rotation.y = yaw
			body = remains.get_child(0) as Node3D
			fall_t = t
			game.call("_play_at", "animal_die", at, 6.0)
		if body:
			var k := clampf((t - fall_t) / .42, 0.0, 1.0)
			k = k * k
			body.rotation.x = PI * .5 * k
			body.position.y = .24 * k
		var c := cam + Vector3(0, -.1, -.35) * smoothstep(0, seconds, t)
		var ang := _angles_to(c, at + Vector3(0, .3, 0))
		_aim_angles(c, ang.x, ang.y, 50.0)
		_tick(t)
		await process_frame

## 6. A living tree: the shadow reaches it, its leaves fall and the crown dies.
func _shot_v_tree() -> void:
	game.set_process(false)
	_setup_day(3, .64, .3)
	var edge: float = game.call("_shadow_edge_x")
	var tree: Node3D = null
	var best := 1e9
	for candidate in game.tree_nodes:
		if candidate.get_meta("withered", false): continue
		var gap: float = candidate.position.x - edge
		if gap > 1.5 and gap < best and absf(candidate.position.z) < 12.0:
			best = gap
			tree = candidate
	tree.set_meta("withered", true)
	var canopy: Node3D = tree.get_node("Canopy")
	var top := tree.global_position + Vector3(0, 3.2, 0)
	var s0 := _shadow_for_x(tree.position.x - 2.0)
	var s1 := _shadow_for_x(tree.position.x + 1.2)
	var cam := tree.global_position + Vector3(4.2, .9, 3.6)
	var died := -1.0
	var leaves := CPUParticles3D.new()
	leaves.emitting = false
	leaves.one_shot = true
	leaves.amount = 260
	leaves.lifetime = 3.0
	leaves.explosiveness = .55
	leaves.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	leaves.emission_sphere_radius = 2.0
	leaves.gravity = Vector3(.4, -2.2, 0)
	leaves.initial_velocity_min = .2
	leaves.initial_velocity_max = 1.0
	leaves.angular_velocity_min = -180
	leaves.angular_velocity_max = 180
	var quad := QuadMesh.new()
	quad.size = Vector2(.16, .16)
	var lm := StandardMaterial3D.new()
	lm.albedo_texture = load("res://art/terrain/leaves.png")
	lm.albedo_color = Color(.55, .45, .3)
	lm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	lm.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	lm.cull_mode = BaseMaterial3D.CULL_DISABLED
	quad.material = lm
	leaves.mesh = quad
	leaves.position = top
	game.add_child(leaves)
	var start_scale := canopy.scale
	var start_y := canopy.position.y
	var total := int(seconds * FPS)
	for i in range(total):
		var t := float(i) / FPS
		_sweep(3, .64, s0, s1, .2, seconds - .8, t)
		if died < 0.0 and game.call("_position_is_shadowed", tree.position):
			died = t
			leaves.emitting = true
			game.call("_play_at", "tree_die", tree.global_position, 6.0)
		if died >= 0.0:
			var k := clampf((t - died) / 1.4, 0.0, 1.0)
			canopy.scale = start_scale * (1.0 - .85 * k)
			canopy.position.y = start_y - 1.2 * k
			if k >= 1.0: canopy.hide()
		var c := cam + Vector3(-.3, 0, -.4) * (t / seconds)
		var ang := _angles_to(c, top + Vector3(0, -.4, 0))
		_aim_angles(c, ang.x, ang.y, 56.0)
		_tick(t)
		await process_frame

## 7. On the dead ground, watchers rise and turn their eyes to you.
func _shot_v_watchers() -> void:
	_setup_day(3, .6, .6)
	game.set_physics_process(false)
	game.watcher_timer = 999.0
	var cam := Vector3(-3.0, 1.4, 6.0)
	var look := Vector3(-8.0, .4, -1.5)
	var spots := [Vector3(-5.6, 0, 2.4), Vector3(-4.1, 0, 1.4), Vector3(-7.0, 0, 3.4)]
	var rise := func(n: int):
		var at: Vector3 = spots[n]
		at.y = game.call("_terrain_height", at.x, at.z) - .6
		var w: Node3D = game.call("_spawn_small_hand", at, .026, 0.0, false)
		w.name = "Watcher"
		w.set_meta("life", 99.0)
		game.watchers.append(w)
		game.call("_play_at", "small_hand_rise_soil", at, 6.0)
	var total := int(seconds * FPS)
	for i in range(total):
		var t := float(i) / FPS
		if i == 2: rise.call(0)
		if i == int(.7 * FPS): rise.call(1)
		if i == int(1.3 * FPS): rise.call(2)
		var c := cam + Vector3(0, -.25, 0) * smoothstep(0, seconds, t)
		var ang := _angles_to(c, Vector3(-5.4, .25, 2.2))
		_aim_angles(c, ang.x, ang.y, lerpf(54.0, 40.0, smoothstep(.5, seconds, t)))
		_tick(t)
		await process_frame

## 8. The last light: the hand at its closest, standing in the sea.
func _shot_v_final() -> void:
	game.set_process(false)
	_setup_day(4, .74, .66)
	var base := _hand_base_y()
	var hand_xz: Vector3 = game.hand_root.position
	_spawn_rings(Vector3(hand_xz.x, 0, hand_xz.z - 6.0))
	for ring in rings: ring.set_meta("delay", float(ring.get_meta("delay")) * 1.6)
	var cam_a := Vector3(.4, 1.0, -4.0)
	var cam_b := Vector3(.5, 1.6, -6.5)
	var total := int(seconds * FPS)
	for i in range(total):
		var t := float(i) / FPS
		game.day_time = game.call("_day_length") * lerpf(.74, .77, t / seconds)
		game.call("_update_lighting")
		game.hand_root.position.y = base - 6.0 * (1.0 - smoothstep(0, seconds, t))
		game.call("_animate_island", 1.0 / FPS)
		_tick_rings(1.0 / FPS, 16.0)
		var c := cam_a.lerp(cam_b, smoothstep(0, seconds, t))
		var ang := _angles_to(c, _eye_pos() + Vector3(0, -9.0, 0))
		_aim_angles(c, ang.x, ang.y, 82.0)
		_tick(t)
		await process_frame
