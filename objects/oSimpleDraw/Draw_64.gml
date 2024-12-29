/// Draw the application GUI

draw_set_font(fntMain);

//gpu_set_blendmode(bm_subtract);
draw_text(0, 0, $"{tool.name} - {tool.desc}");
//gpu_set_blendmode(bm_normal);

