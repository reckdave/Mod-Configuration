extends Node

onready var CONFIG_MENU = preload("res://ModConfiguration/Scenes/Config_Menu.tscn")
onready var CONFIG_SETTINGS = preload("res://ModConfiguration/Scenes/Config_Setting.tscn")
onready var CONFIG_NODE = preload("res://ModConfiguration/Scenes/Config_Node.tscn")
onready var CONFIG_LIST = $CONFIG_NODES
onready var HTTP = $HTTPRequest

signal X_PRESSED

var VERSION = '1.1.3'
var URL = "https://raw.githubusercontent.com/reckdave/Mod-Configuration/main/ModConfiguration/VERSION.json"

var File_EXT = '.json' # The file extention of the file name
var Config_Path = 'user://config' # File path of the config folder

var ModConfig_Info : Dictionary = {'SHOW_APP':true}
var ModConfig_Author : String = 'reckdave' # me!!!
var ModConfig_Name : String = 'ModConfig'

var Load_Time : float = 0.1

# MISC
func pr(string):
	print('[CONFIG] ', string)
func CheckVar(string):
	return string
	# UNUSED BECAUSE IT WAS NOT NEEDED
	#match typeof(str2var(string)):
		#TYPE_INT:
			#pr('int')
			#return int(string)
		#TYPE_STRING:
			#pr('str')
			#if string.to_lower() == 'true' or string.to_lower() == 'false':
				#return str2var(string.to_lower())
			#return string
		#TYPE_BOOL:
			#pr('bool')
			#return str2var(string)

func _ready():
	var dir = Directory.new()
	dir.open('user://') # Opens directory
	if !dir.dir_exists('config'): # Sees if the a folder called 'config' exists
		pr('CONFIG FOLDER DOESNT EXIST.. CREATING')
		dir.make_dir('config') # Creates the folder
	pr('STARTED, VER: ' + VERSION) # Easier to help people because I can just ask their version number
	var ModConfig_Node = MakeConfig(ModConfig_Name,ModConfig_Author,ModConfig_Info)
	ModConfig_Info = ModConfig_Node.ConfigValues
	HTTP.request(URL)

func MakeConfig(Config_Name : String = "NULL",Author : String = "NULL",Info : Dictionary = {}): # The real stuff happens here
	if Info == null or Info.empty(): # Checks if the dictionary is empty or null
		pr(Config_Name + ' DICTIONARY DOESNT EXIST / IS EMPTY.. CANCELLED')
		return
	var Config_File = File.new() # The actual file
	var Config_Final = CONFIG_NODE.instance() # Clones the node
	Config_Final.name = Config_Name
	Config_Final.ConfigValues = Info # Store the values
	Config_Final.ModAuthor = Author
	var FullDir = Config_Path + '/' + Config_Name + File_EXT # Full thing example: 'user:config/Example.json'
	var Dir = Directory.new()
	Dir.open(Config_Path)
	if !Dir.file_exists(FullDir): # Checks if the file exists
		pr('CREATING ' + Config_Name)
		Config_File.open(FullDir,File.WRITE)
		Config_File.store_string(JSON.print(Info,'\t')) # Stores the data
	else: # Load the config file if it does
		pr(Config_Name + ' FOUND')
		Config_File.open(FullDir,File.READ_WRITE)
		var JSON_Content = Config_File.get_as_text() # Reads the file
		var Validated_JSON = validate_json(JSON_Content) # Checks if the file is o'okay
		if !Validated_JSON:
			pr('VALID JSON: ' + Config_Name + File_EXT)
		else:
			pr('INVALID JSON: ' + Config_Name + File_EXT)
			return
		var Contents : Dictionary = str2var(JSON_Content)
		for key in range(Info.size()):
			if Contents.keys()[key] == null: # CHECKS IF THE KEY DOESNT EXIST
				pr('FOUND MISSING KEY, ADDING KEY..')
				var title_key = Info.keys()[key]
				Contents[title_key] = Info[title_key] # ADDS IT INTO THE LIST
		Config_File.store_string(JSON.print(Contents,'\t'))
		Config_Final.ConfigValues = Contents # Actually store the values
		pr(Contents)
	CONFIG_LIST.add_child(Config_Final) # Add the node to the `CONFIG_NODES`
	Config_File.close() # Close the file since we dont need it anymore
	return Config_Final # Give the node to the modder


# APP HANDLER
var CAN_OPEN = true
var FINISHED_LOADING = false

func _save_config():
	var applic = get_parent().get_parent().get_node("0").get_child(0)
	var menu = applic.get_node('Menu_CONFIG')
	var LIST_BOX = menu.get_node("Active/Config_Container/List")
	var x_button = menu.get_node('Active/XButton')
	for config_nodes in range(CONFIG_LIST.get_child_count()):
				var node = CONFIG_LIST.get_child(config_nodes)
				var Config_Name = node.name
				#var Config_Info = {}
				var FullDir = Config_Path + '/' + Config_Name + File_EXT
				for config_values in range(node.ConfigValues.size()):
					var Config_Title = node.ConfigValues.keys()[config_values]
					var Config_Setting = LIST_BOX.get_node(Config_Name + '_' + Config_Title)
					var Config_Value = CheckVar(Config_Setting.config_value)
					node.ConfigValues[Config_Title] = Config_Value
					pr(Config_Value)
				var file = File.new()
				file.open(FullDir,File.WRITE)
				file.store_string(JSON.print(node.ConfigValues,'\t'))
				file.close()

func _process(delta):
	if FINISHED_LOADING and !CAN_OPEN:
		var applic = get_parent().get_parent().get_node("0").get_child(0)
		var menu = applic.get_node('Menu_CONFIG')
		var x_button = menu.get_node('Active/XButton')
		if x_button.pressed == true:
			CAN_OPEN = true
			_save_config()
			menu.get_node('ANIMATIONS').play('0')
			yield(get_tree().create_timer(0.2,false),"timeout")
			menu.queue_free()
	if ModConfig_Info['SHOW_APP']:
		if !get_parent().get_parent().has_node('0'): return # SAFETY CHECK
		if get_parent().get_parent().get_node('0').has_node('PC'):
			#PC_SCENE = true
			var applic = get_parent().get_parent().get_node("0").get_child(0)
			if applic.get_node('Aspect').has_node('ConfigAPP'): return # STOPS FROM OVER FLOWING THE PC
			var dskObject = load("res://-Scenes/Application000/Sub/Desktop_Object.tscn").instance()
			dskObject.name = 'ConfigAPP'
			dskObject.Name = 'Mod Config'
			dskObject.ButtonNumber = 6068
			dskObject.DskTexture = load("res://-Asset/App000/PC/Icons/Settings.png")
			applic.get_node('Aspect').add_child(dskObject)

func _input(event):
	if event is InputEventMouseButton:
		if event.doubleclick and event.button_index == BUTTON_LEFT:
			#if (Tab.buttonValue == 6068) and CAN_OPEN:
				var applic = get_parent().get_parent().get_node("0").get_child(0)
				var MENU = CONFIG_MENU.instance()
				var LIST_BOX = MENU.get_node("Active/Config_Container/List")
				MENU.config_node = self
				applic.add_child(MENU)
				MENU.get_node('ANIMATIONS').play('1')
				MENU.position = Vector2(40,40)
				FINISHED_LOADING = false
				CAN_OPEN = false
				for config_nodes in range(CONFIG_LIST.get_child_count()):
					var node = CONFIG_LIST.get_child(config_nodes)
					var Config_Header = CONFIG_SETTINGS.instance()
					var Config_Name = node.name
					var Config_Author = node.ModAuthor
					var Config_Header_Anim = Config_Header.get_node("ANIMATION")
					Config_Header.editable = false
					Config_Header.config_title = Config_Name + ' by [wave]' + Config_Author
					LIST_BOX.add_child(Config_Header)
					Config_Header_Anim.play("0")
					yield(get_tree().create_timer(Load_Time,false),"timeout")
					for config_values in range(node.ConfigValues.size()):
						var Config_Setting = CONFIG_SETTINGS.instance()
						var Config_Title = node.ConfigValues.keys()[config_values]
						var Config_Value = node.ConfigValues[Config_Title]
						var Config_Setting_Anim = Config_Setting.get_node("ANIMATION")
						Config_Setting.config_title = Config_Title
						Config_Setting.config_value = Config_Value
						Config_Setting.name = Config_Name + '_' + Config_Title
						LIST_BOX.add_child(Config_Setting)
						Config_Setting_Anim.play('0')
						yield(get_tree().create_timer(Load_Time,false),"timeout")
				FINISHED_LOADING = true

# UPDATE CHECK

func _request_completed(result, response_code, headers, body):
	var data = str2var(body.get_string_from_utf8())
	pr(data["VERSION"])
	if VERSION < data["VERSION"]:
		OS.alert("THIS IS AN OUTDATED VERSION OF MODCONFIG \nDOWNLOAD LATEST AT THE GITHUB \nSEE LOGS FOR MORE","MOD CONFIG")
		pr("DOWNLOAD: \nhttps://github.com/reckdave/Mod-Configuration/releases")
