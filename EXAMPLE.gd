extends Node

var config_name = 'Example'
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
				config_node = node.MakeConfig(config_name,config_info) 
			yield(get_tree(),"idle_frame")
	else:
		OS.alert("MISSING MODCONFIG, PLEASE DOWNLOAD OR THE MOD WILL NOT WORK", "ERROR")

func _ready():
	ConfigHandler()
	while !config_loaded:
		yield(get_tree(),"idle_frame")
	print(config_node.Config_Values['test'])
