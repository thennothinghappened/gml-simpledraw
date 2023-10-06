
var _mx = window_mouse_get_x();
var _my = window_mouse_get_y();

var _mleft = device_mouse_check_button(0, mb_left);
var _mright = device_mouse_check_button(0, mb_right);

// ...

if (_mright) {
    handle_pan(_mx, _my);
} else {
    
    handle_draw(_mx, _my, _mleft);
    
    if (_mleft) {
        
        var num_cols = array_length(colours);
        var width = 50;
        var height = 50;
        
        var tools = struct_get_names(brushes);
        
        for (var i = 0; i < num_cols; i ++) {
            
            var pos = {
                x1: width * i,
                y1: 0,
                x2: width * (i+1),
                y2: height
            };
            
            if (point_in_rectangle(_mx, _my, pos.x1, pos.y1, pos.x2, pos.y2)) {
                brush_settings.colour = colours[i];
                gui_redraw = true;
                
                break;
            }
        }
        
        var off = height;
        
        for (var i = 0; i < array_length(tools); i ++) {
            
            var str = tools[i];
            off += string_height(str);
            
            if (point_in_rectangle(_mx, _my, 0, off, string_width(str), off + string_height(str))) {
                brush = str;
                gui_redraw = true;
                
                break;
            }
        }
    }
}

if (keyboard_check_pressed(vk_f6)) {
    var fname = get_save_filename("png", "img");
    if (fname != "") {
        surface_save(canvas_surf, fname);
    }
}

// ...

mouse.x = _mx;
mouse.y = _my;
mouse.buttons.left = _mleft;
mouse.buttons.right = _mright;
