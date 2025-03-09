extends Button


var btn_text: String


func _ready() -> void:
    btn_text = self.text
    get_viewport().gui_focus_changed.connect(focus_text)


func focus_text(node: Control) -> void:
    if node == self:
        self.text = '- ' + btn_text + ' -'
    else:
        self.text = btn_text
