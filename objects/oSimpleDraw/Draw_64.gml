/// Draw the application GUI

var toolIcon = tool.icon;
draw_sprite(toolIcon, 0, 0, 0);
draw_text(sprite_get_width(toolIcon), 0, tool.name);
draw_text(0, 16, tool.desc);
