extends SceneTree
## 0.6.4: graphics settings persist across restarts; the credits screen opens
## from the title and the pause menu and closes again.

var failed := false

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		failed = true

func _run() -> void:
	create_timer(40).timeout.connect(func(): push_error("deadline exceeded"); quit(1))
	DirAccess.remove_absolute("user://settings.cfg")
	var game: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	await process_frame
	_check(not game.graphics_fullscreen and game.graphics_window == 0 and game.graphics_vsync, "graphics start at windowed 1280x720 with VSync")
	_check(game.menu_actions.has("credits"), "the title menu offers Credits")
	game.call("_settings_tab", 2)
	_check(game.settings_graphics_panel.visible and not game.settings_audio_panel.visible, "the Graphics tab shows its own panel")
	game.call("_graphics_choice", "window")
	game.call("_graphics_choice", "vsync")
	game.call("_graphics_choice", "fullscreen")
	_check(game.graphics_window == 1 and not game.graphics_vsync and game.graphics_fullscreen, "choices change the settings")
	_check(str(game.graphics_buttons["window"].text).begins_with("1600 x 900"), "the window button names the size")
	game.queue_free()
	await create_timer(.2).timeout

	var again: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(again)
	await process_frame
	await process_frame
	_check(again.graphics_window == 1 and not again.graphics_vsync and again.graphics_fullscreen, "graphics settings must persist across restarts")
	_check(again.graphics_buttons["vsync"].text == "Off", "loaded settings show on the buttons")
	print("PASS graphics settings persist")

	again.call("_menu_action", again.menu_actions.find("credits"))
	_check(again.credits_page.visible and not again.title_layer.visible, "Credits opens from the title")
	again.call("_close_credits")
	_check(not again.credits_page.visible and again.title_layer.visible, "Credits closes back to the title")
	again.menu_visible = false
	again.title_layer.hide()
	again.call("_pause_game")
	again.call("_pause_action", 2)
	_check(again.credits_page.visible and not again.pause_choices.visible, "Credits opens from the pause menu")
	again.call("_close_credits")
	_check(again.pause_choices.visible and not again.credits_page.visible, "Credits closes back to the pause menu")
	print("PASS credits screen")

	again.queue_free()
	DirAccess.remove_absolute("user://settings.cfg")
	await create_timer(.2).timeout
	if failed:
		quit(1)
	else:
		print("PASS settings 0.6.4")
		quit(0)
