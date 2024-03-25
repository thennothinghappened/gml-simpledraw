
draw_text(0, 0, $"{fps_real}");

var tool = tools[tool_current];

var offset_y = 20;

for (var i = 0; i < array_length(tool.settings_order); i ++) {
    
    var setting = tool.settings[$ tool.settings_order[i]];
    
    setting.display(0, offset_y);
    
    offset_y += setting.height;
    
}
