extends Node



func _ready():
	$ItemList.add_item("Hello")

func _process(_delta):
	var windowSize = get_viewport().size
	$ItemList.rect_size = windowSize

func _on_ItemList_item_selected(index):
	print($ItemList.get_item_text(index))
