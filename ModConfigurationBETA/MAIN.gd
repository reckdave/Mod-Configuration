extends Node

onready var MENU_SCENE = preload("res://ModConfigurationBETA/Scenes/Config_Menu.tscn")
onready var CONFIG_SETTING = preload("res://ModConfigurationBETA/Scenes/Config_Setting.tscn")
onready var CONFIG_NODE = preload("res://ModConfigurationBETA/Scenes/Config_Node.tscn")
onready var animation = $ANIMATION
var config_folder_path = "user://config"
var file_ext = ".json"

var values = {}

func print_mod(string):
	print("[CONFIG] ", string)

var PC_SCENE = false
var APP_OPEN = false
var in_pc = false
func _process(delta):
	if APP_OPEN:
		var applic = get_parent().get_parent().get_node("0").get_child(0)
		var app_loc = applic.get_node("Menu_CONFIG")
		if app_loc.get_child(0).get_node("XButton").pressed == true:
			APP_OPEN = false
			app_loc.get_node("ANIMATIONS").play("0")
			for mod_index in range(values.size()):
				var list_box = app_loc.get_child(0).get_node("Config_Container/List")
				var modname = values.keys()[mod_index]
				#var config_name = list_box.get_node(str(mod_index)).get_node("Config_Title").text
				#var config_value = list_box.get_node(str(mod_index)).get_node("Config_Value").text
				#values[config_name] = config_value
				for config_values in range(values[modname].size()):
					var mod_name = str(modname) + "_" + str(config_values)
					var config_title = list_box.get_node(mod_name).config_title
					var config_value = list_box.get_node(mod_name).config_value
					values[modname][config_title] = config_value
					print_mod(config_value)
					print_mod(config_title)
					pass
			yield(get_tree().create_timer(0.15,false),"timeout")
			app_loc.queue_free()
	if !PC_SCENE:
		if "PC" in get_parent().get_parent().get_node("0").get_child(0).name:
			PC_SCENE = true
			var applic = get_parent().get_parent().get_node("0").get_child(0)
			var desktopObj = load("res://-Scenes/Application000/Sub/Desktop_Object.tscn").instance()
			desktopObj.name = "Config_App"
			desktopObj.Name = "MOD CONFIG"
			desktopObj.ButtonNumber = 6068
			desktopObj.DskTexture = load("res://-Asset/App000/PC/Icons/Settings.png")
			applic.get_node("Aspect").add_child(desktopObj)
	if PC_SCENE and !('PC' in get_parent().get_parent().get_node("0").get_child(0).name):
		PC_SCENE = false
	
func _input(event):
	if event is InputEventMouseButton:
		if event.doubleclick and event.button_index == BUTTON_LEFT:
			if (Tab.buttonValue==6068) and !APP_OPEN:
				var applic = get_parent().get_parent().get_node("0").get_child(0)
				var menu = MENU_SCENE.instance()
				for mod_index in range(values.size()):
					print_mod('modname')
					var modname = values.keys()[mod_index]
					var list_box = menu.get_child(0).get_node("Config_Container/List")
					var config_section_header = CONFIG_SETTING.instance()
					config_section_header.editable = false
					config_section_header.config_title = modname
					list_box.add_child(config_section_header)
					for config_values in range(values[modname].size()):
						var setting = CONFIG_SETTING.instance()
						var config_title = values[modname].keys()[config_values]
						setting.name = str(modname) + "_" + str(config_values)
						setting.config_title = config_title
						setting.config_value = values[modname][config_title]
						list_box.add_child(setting)
				applic.add_child(menu)
				menu.position = Vector2(500,500)
				menu.get_node("ANIMATIONS").play("1")
				APP_OPEN = true

func _ready():
	var dir = Directory.new()
	dir.open("user://")
	if (dir.file_exists("config") == false):
		dir.make_dir("config")
	
	# ANIMATION SEQUENCE
	MakeConfig('example',{'eg':true})
	animation.play("LOAD")
	yield(get_tree().create_timer(2,false),"timeout")
	animation.play("INVISIBLE")

func MakeConfig(config_name : String,info : Dictionary):
	values[config_name] = {}
	var dir = Directory.new()
	dir.open(config_folder_path)
	var config_file = File.new()
	var cfg_node = CONFIG_NODE.instance()
	cfg_node.Config_Name = config_name
	if !dir.file_exists(config_name+file_ext):
		print_mod(config_name + " NOT FOUND")
		save(config_name,info)
		for stored_value in range(info.size()):
			var value_key = info.keys()[stored_value]
			values[config_name][value_key] = info[value_key]
	else:
		print_mod(config_name + " FOUND")
		config_file.open((config_folder_path + "/" + config_name + file_ext), File.READ_WRITE)
		for stored_value in range(info.size()):
			var value_key = info.keys()[stored_value]
			var config_text : String = config_file.get_as_text()
			var parsejson : JSONParseResult = JSON.parse(config_text)
			var config_dic : Dictionary = parsejson.get_result()
			var value_dic = config_dic.keys()[stored_value]
			print_mod(config_dic)
			cfg_node.Config_Values[value_dic] = config_dic[value_dic]
			values[config_name][value_key] = config_dic[value_dic]
		config_file.close()
	print_mod(cfg_node.Config_Values)
	print_mod(values)
	return cfg_node

func returnval(val):
	var finalvar
	if val == "True" or val == "False":
		finalvar = val.to_lower()
	return str2var(finalvar)

func save(filename,filedata):
	var file = File.new()
	file.open(config_folder_path + "/" + filename + file_ext, File.WRITE)
	file.store_string(to_json(filedata))
	file.close()
