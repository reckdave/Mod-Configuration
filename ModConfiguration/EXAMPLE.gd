extends Node

var config_name = 'Example'
var config_author = 'Nothing'
var config_mod_ver_min = '1.1'
var config_info = {'test':'string'}
var config_loaded = false
var config_node

func ConfigHandler():
	var dir = Directory.new()
	dir.open('user://Mods')
	if dir.file_exists('ModConfiguration.zip'):
		while !config_loaded:
			if get_parent().has_node('Config_Scene'):
				var node = get_parent().get_node('Config_Scene')
				config_loaded = true
				if node.VERSION == null or (node.VERSION > config_mod_ver_min):
					OS.alert("OUTDATED ModConfiguration, See the logs for more ","ERROR")
					print('DOWNLOAD THE LATEST ModConfiguration VERSION: \nhttps://github.com/reckdave/Mod-Configuration/releases/tag/release1.1')
				config_node = node.MakeConfig(config_name,config_author,config_info) 
				config_info = config_node.ConfigValues
			yield(get_tree(),"idle_frame")
	else:
		OS.alert("MISSING MODCONFIG, RESULTING TO DEFAULT VALUES", "ERROR")
		config_loaded = true

func _ready():
	ConfigHandler()
	while !config_loaded:
		yield(get_tree(),"idle_frame")
	print(config_info['test'])
