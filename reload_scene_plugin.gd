@tool
extends EditorPlugin

var reload_button: Button
var editor_interface: EditorInterface
var shortcut: Shortcut

func _enter_tree():
	editor_interface = get_editor_interface()
	
	# Create shortcut (Ctrl+ENTER or Cmd+ENTER on macOS)
	shortcut = Shortcut.new()
	var input_key = InputEventKey.new()
	input_key.keycode = KEY_ENTER
	input_key.ctrl_pressed = true
	# input_key.alt_pressed = true # uncomment for 3-keys shortcut
	# On macOS, Ctrl becomes Command automatically in editor shortcuts
	shortcut.events = [input_key]
	
	# Create the toolbar button
	reload_button = Button.new()
	reload_button.text = "Save & Reload Scene"
	reload_button.tooltip_text = "Save the current scene then reload it from disk (Ctrl+ENTER)" # (Ctrl+Alt+ENTER)
	reload_button.icon = editor_interface.get_base_control().get_theme_icon("Reload", "EditorIcons")
	reload_button.flat = true
	reload_button.shortcut = shortcut  # Assign shortcut to button
	reload_button.shortcut_in_tooltip = true
	
	# Connect button press (and shortcut will trigger the same)
	reload_button.pressed.connect(_save_and_reload)
	
	# Add to top toolbar
	add_control_to_container(CONTAINER_TOOLBAR, reload_button)

func _save_and_reload():
	var edited_scene = editor_interface.get_edited_scene_root()
	if not edited_scene:
		push_warning("No scene open to save/reload.")
		return
	
	var path = edited_scene.scene_file_path
	if path == "":
		push_warning("Cannot save/reload unsaved new scene. Save it to a file first.")
		return
	
	# Save the scene first (uses editor's save, prompts if needed)
	editor_interface.save_scene()
	
	# Then reload from disk
	editor_interface.reload_scene_from_path(path)

func _exit_tree():
	if reload_button:
		remove_control_from_container(CONTAINER_TOOLBAR, reload_button)
		reload_button.queue_free()
