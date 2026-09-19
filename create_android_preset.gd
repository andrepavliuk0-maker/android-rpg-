@tool
extends EditorScript

func _run() -> void:
	var export_manager := EditorExport.get_singleton()

	var android_index := export_manager.get_export_platform_index_by_name("Android")

	if android_index < 0:
		push_error("Android export platform was not found.")
		return

	var android_platform := export_manager.get_export_platform(android_index)

	var preset := android_platform.create_preset()

	if preset == null:
		push_error("Failed to create Android export preset.")
		return

	preset.set_name("Android")
	preset.set_runnable(false)
	preset.set_dedicated_server(false)
	preset.set_export_filter(EditorExportPreset.EXPORT_ALL_RESOURCES)
	preset.set_include_filter("")
	preset.set_exclude_filter("")
	preset.set_export_path("build/MageRPG.apk")
	preset.set_script_export_mode(
		EditorExportPreset.MODE_SCRIPT_BINARY_TOKENS_COMPRESSED
	)

	# Android architecture.
	preset.set("architectures/arm64-v8a", true)
	preset.set("architectures/armeabi-v7a", false)
	preset.set("architectures/x86", false)
	preset.set("architectures/x86_64", false)

	# Application.
	preset.set("package/unique_name", "com.magerpg.game")
	preset.set("package/name", "Mage RPG")

	# Version.
	preset.set("version/code", 1)
	preset.set("version/name", "1.0")

	# Android permissions.
	preset.set("permissions/internet", true)

	# Immersive fullscreen.
	preset.set("screen/immersive_mode", true)

	# Use the normal pre-built APK template.
	preset.set("gradle_build/use_gradle_build", false)

	# Export directly.
	DirAccess.make_dir_recursive_absolute(
		ProjectSettings.globalize_path("build")
	)

	var error := android_platform.export_project(
		preset,
		true,
		ProjectSettings.globalize_path("build/MageRPG.apk")
	)

	if error != OK:
		push_error(
			"Android export failed. Error code: %s"
			% error
		)
		return

	print("========================================")
	print("Mage RPG APK successfully created!")
	print(ProjectSettings.globalize_path("build/MageRPG.apk"))
	print("========================================")
