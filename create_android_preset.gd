extends EditorScript

func _run() -> void:
	var export := EditorExport.get_singleton()

	var android_index := export.get_export_platform_index_by_name("Android")

	if android_index < 0:
		print("ERROR: Android export platform not found")
		return

	var platform := export.get_export_platform(android_index)
	var preset := platform.create_preset()

	preset.set_name("Android")
	preset.set_runnable(false)
	preset.set_export_filter(EditorExportPreset.EXPORT_ALL_RESOURCES)
	preset.set_export_path("build/MageRPG.apk")

	preset.set("gradle_build/use_gradle_build", false)

	preset.set("architectures/arm64-v8a", true)
	preset.set("architectures/armeabi-v7a", false)
	preset.set("architectures/x86", false)
	preset.set("architectures/x86_64", false)

	preset.set("version/code", 1)
	preset.set("version/name", "1.0")

	preset.set("package/unique_name", "com.magerpg.game")
	preset.set("package/name", "Mage RPG")

	preset.set("screen/immersive_mode", true)

	preset.set("permissions/internet", true)

	export.add_export_preset(preset)

	print("Android preset created successfully.")

	export.save_presets()

	print("Android preset saved.")
