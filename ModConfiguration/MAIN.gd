extends Node

onready var CONFIG_MENU = preload("res://ModConfiguration/Scenes/Config_Menu.tscn")
onready var CONFIG_SETTINGS = preload("res://ModConfiguration/Scenes/Config_Setting.tscn")
onready var CONFIG_NODE = preload("res://ModConfiguration/Scenes/Config_Node.tscn")
onready var CONFIG_LIST = $CONFIG_NODES

var File_EXT = '.json'
var Config_Path = 'user://config'
# MISC
func pr(string):
	print('[CONFIG] ', string)
func CheckVar(string : String):
	match typeof(str2var(string)):
		TYPE_INT:
			pr('int')
			return int(string)
		TYPE_STRING:
			pr('str')
			if string.to_lower() == 'true' or string.to_lower() == 'false':
				return str2var(string.to_lower())
			return string
		TYPE_BOOL:
			pr('bool')
			return str2var(string)

func _ready():
	var dir = Directory.new()
	dir.open('user://')
	if !dir.dir_exists('config'):
		pr('CONFIG FOLDER DOESNT EXIST.. CREATING')
		dir.make_dir('config')
	pr('STARTED')

func MakeConfig(Config_Name : String,Info : Dictionary):
	if Info == null or Info.empty():
		pr(Config_Name + ' DICTIONARY DOESNT EXIST / IS EMPTY.. CANCELLED')
		return
	var Config_File = File.new()
	var Config_Final = CONFIG_NODE.instance()
	Config_Final.name = Config_Name
	Config_Final.Config_Values = Info
	
	var FullDir = Config_Path + '/' + Config_Name + File_EXT
	var Dir = Directory.new()
	Dir.open(Config_Path)
	if !Dir.file_exists(FullDir):
		pr('CREATING ' + Config_Name)
		Config_File.open(FullDir,File.WRITE)
		Config_File.store_string(JSON.print(Info,'\t'))
	else:
		pr(Config_Name + ' FOUND')
		Config_File.open(FullDir,File.READ)
		var JSON_Content = Config_File.get_as_text()
		var Validated_JSON = validate_json(JSON_Content)
		if !Validated_JSON:
			pr('VALID JSON: ' + Config_Name + File_EXT)
		else:
			pr('INVALID JSON: ' + Config_Name + File_EXT)
			return
		var Contents = str2var(JSON_Content)
		pr(Contents)
		Config_Final.Config_Values = Contents
	CONFIG_LIST.add_child(Config_Final)
	Config_File.close()
	return Config_Final


# APP HANDLER
var PC_SCENE = false
var APP_OPEN = false
func _process(delta):
	if APP_OPEN:
		var applic = get_parent().get_parent().get_node("0").get_child(0)
		var menu = applic.get_node('Menu_CONFIG')
		var LIST_BOX = menu.get_node("Active/Config_Container/List")
		var x_button = menu.get_node('Active/XButton')
		if x_button.pressed == true:
			APP_OPEN = false
			for config_nodes in range(CONFIG_LIST.get_child_count()):
				var node = CONFIG_LIST.get_child(config_nodes)
				var Config_name = node.name
				var Config_Info = {}
				var FullDir = Config_Path + '/' + Config_name + File_EXT
				for config_values in range(node.Config_Values.size()):
					var Config_Title = node.Config_Values.keys()[config_values]
					var Config_Setting = LIST_BOX.get_node(Config_name + '_' + Config_Title)
					var Config_Value = CheckVar(Config_Setting.config_value)
					node.Config_Values[Config_Title] = Config_Value
					pr(Config_Value)
				var file = File.new()
				file.open(FullDir,File.WRITE)
				file.store_string(JSON.print(node.Config_Values,'\t'))
				file.close()
			menu.queue_free()
	if !PC_SCENE:
		if 'PC' in get_parent().get_parent().get_node('0').get_child(0).name:
			PC_SCENE = true
			var applic = get_parent().get_parent().get_node("0").get_child(0)
			var dskObject = load("res://-Scenes/Application000/Sub/Desktop_Object.tscn").instance()
			dskObject.name = 'ConfigAPP'
			dskObject.Name = 'Mod Config'
			dskObject.ButtonNumber = 6068
			dskObject.DskTexture = load("res://-Asset/App000/PC/Icons/Settings.png")
			applic.get_node('Aspect').add_child(dskObject)
	if !('PC' in get_parent().get_parent().get_node('0').get_child(0).name):
		PC_SCENE = false
func _input(event):
	if event is InputEventMouseButton:
		if event.doubleclick and event.button_index == BUTTON_LEFT:
			if (Tab.buttonValue == 6068) and !APP_OPEN:
				var applic = get_parent().get_parent().get_node("0").get_child(0)
				var MENU = CONFIG_MENU.instance()
				var LIST_BOX = MENU.get_node("Active/Config_Container/List")
				for config_nodes in range(CONFIG_LIST.get_child_count()):
					var node = CONFIG_LIST.get_child(config_nodes)
					var Config_Header = CONFIG_SETTINGS.instance()
					var Config_name = node.name
					Config_Header.editable = false
					Config_Header.config_title = Config_name
					LIST_BOX.add_child(Config_Header)
					for config_values in range(node.Config_Values.size()):
						var Config_Setting = CONFIG_SETTINGS.instance()
						var Config_Title = node.Config_Values.keys()[config_values]
						var Config_Value = node.Config_Values[Config_Title]
						Config_Setting.config_title = Config_Title
						Config_Setting.config_value = Config_Value
						Config_Setting.name = Config_name + '_' + Config_Title
						LIST_BOX.add_child(Config_Setting)
				applic.add_child(MENU)
				MENU.position = Vector2(40,40)
				APP_OPEN = true
