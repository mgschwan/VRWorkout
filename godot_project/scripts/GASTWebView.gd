extends Spatial


# This is currently in development


#var gast_loader = load("res://godot/plugin/v1/gast/GastLoader.gdns")
#var gast = null
#var gast_webview_plugin = null
#var webview_id = null
#
#func _ready():
#	print ("Starting GAST module")
#	if gast_loader:
#		gast = gast_loader.new()
#		gast.initialize()
#
#		if Engine.has_singleton("gast-webview"):
#			print("Setting webview 1...")
#			gast_webview_plugin = Engine.get_singleton("gast-webview")
#			webview_id = gast_webview_plugin.initializeWebView("/root/WebView/WebViewContainer")
#			print("Initialized webview " + str(webview_id))
#			gast_webview_plugin.loadUrl(webview_id, "https://vrworkout.at/player/1234")
#			gast_webview_plugin.setWebViewSize(webview_id, 2, 2)
#		else:
#			print("Unable to load gast-webview singleton.")
#	else:
#		print ("Gast not loaded")
#
#func _process(delta_t):
#	if gast:
#		gast.on_process()
