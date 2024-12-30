/// Draw the application GUI

draw_set_font(fntMain);

var toolIcon = tool.icon;
draw_sprite(toolIcon, 0, 0, 0);
draw_text(sprite_get_width(toolIcon), 0, $"{tool.name} - {tool.desc}");
