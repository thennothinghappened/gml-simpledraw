
var _mx = window_mouse_get_x();
var _my = window_mouse_get_y();

var _mleft = device_mouse_check_button(0, mb_left);
var _mright = device_mouse_check_button(0, mb_right);

// ...

if (_mright) {
    handle_pan(_mx, _my);
} else if (_mleft) {
    var draw = true;
    
    var num_cols = array_length(colours);
    var width = 50;
    var height = 50;
    
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
            draw = false;
            
            break;
        }
    }
    
    if (draw) {
        handle_draw(_mx, _my);
    }
}

// ...

mouse.x = _mx;
mouse.y = _my;
mouse.buttons.left = _mleft;
mouse.buttons.right = _mright;
