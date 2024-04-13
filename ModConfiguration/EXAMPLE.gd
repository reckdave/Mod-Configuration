extends Node

var config_name = 'Example'
var config_info = {'test':'yea'}
var config_found = false
var config_node
func ConfigHandler():
	var dir = Directory.new()
	dir.open('user://Mods')
	if dir.file_exists('ModConfiguration.zip'):
		while !config_found:
			if get_parent().has_node('Config_Scene'):
				var node = get_parent().get_node('Config_Scene')
				config_found = true
				config_node = node.MakeConfig(config_name,config_info) 
			yield(get_tree(),"idle_frame")
	else:
		OS.alert("MISSING MODCONFIG, PLEASE DOWNLOAD OR THE MOD WILL NOT WORK", "ERROR")

func _ready():
	ConfigHandler()
	print(config_node.Config_Values['test'])
