
application_surface_enable(false);
application_surface_draw_enable(false);

window_width = window_get_width();
window_height = window_get_height();

gui_surf = surface_create(window_width, window_height);
canvas_holder_surf = surface_create(window_width, window_height);

canvas_holder_redraw = true;
gui_redraw = true;

canvas_width = window_width;
canvas_height = window_height;

canvas_surf = surface_create(canvas_width, canvas_height);
canvas_buf = buffer_create(canvas_width * canvas_height * 4, buffer_grow, 1);
buffer_get_surface(canvas_buf, canvas_surf, 0);

overlay_surf = surface_create(canvas_width, canvas_height);

canvas_pan_x = 0;
canvas_pan_y = 0;

mouse = {
    x: 0,
    y: 0,
    buttons: {
        left: false,
        right: false
    }
};

stamps = [];

colours = [
    c_white,
    c_red,
    c_orange,
    c_yellow,
    c_green,
    c_aqua,
    c_blue,
    c_purple,
    c_black,
    c_fuchsia,
    c_gray,
    c_dkgray,
    c_lime,
    c_maroon,
    c_olive
];

brush_settings = {
    size: 5,
    colour: c_white,
    stamp_index: undefined
};

brushes = {
    circle: {
        draw: function(old_mx, old_my, new_mx, new_my, brush_settings, clicked) {
            
            if (clicked) {
                draw_set_colour(brush_settings.colour);
                
                draw_circle(old_mx, old_my, brush_settings.size / 2, false);
                draw_line_width(old_mx, old_my, new_mx, new_my, brush_settings.size);
                draw_circle(old_mx, old_my, brush_settings.size / 2, false);
                
                draw_set_colour(c_white);
                
                return true;
            } else {
                
                draw_set_colour(brush_settings.colour);
                draw_circle(old_mx, old_my, brush_settings.size / 2, true);
                draw_set_colour(c_white);
                
                return false;
            }
        },
        
        min_size: 1,
        max_size: 50
    },
    stamp: {
        draw: function(old_mx, old_my, new_mx, new_my, brush_settings, clicked) {
            
            var known_stamp = brush_settings.stamp_index == undefined;
            
            show_message(known_stamp)
            
            if (!known_stamp) {
                var fname = get_open_filename("png", "img");
    
                if (fname != "") {
                    var spr = sprite_add(fname, 0, false, false, 0, 0);
                    brush_settings.stamp_index = array_length(stamps);
                    array_push(stamps, spr);
                }
                
                return false;
            }
            
            if (!clicked) {
                draw_set_alpha(0.6);
            }
            
            draw_sprite(stamps[brush_settings.stamp_index], 0, new_mx, new_my);
            
            if (!clicked) {
                draw_set_alpha(1);
            }
            
            return clicked;
            
        
        }
    }
};

brush = "circle";

canvas_restore = function() {
    buffer_set_surface(canvas_buf, canvas_surf, 0);
}

draw_canvas_container = function() {
    
    if (!surface_exists(canvas_surf)) {
        canvas_restore();
    }
    
    if (!surface_exists(overlay_surf)) {
        overlay_surf = surface_create(canvas_width, canvas_height);
    }
    
    draw_surface(canvas_surf, canvas_pan_x, canvas_pan_y);
    draw_surface(overlay_surf, canvas_pan_x, canvas_pan_y);
    draw_rectangle(canvas_pan_x, canvas_pan_y, canvas_pan_x + canvas_width, canvas_pan_y + canvas_height, true);
    
}

handle_pan = function(_mx, _my) {
    var pan_x = mouse.x - _mx;
    var pan_y = mouse.y - _my;
    
    if (pan_x != 0 || pan_y != 0) {
        canvas_pan_x -= pan_x;
        canvas_pan_y -= pan_y;
        
        canvas_holder_redraw = true;
    }
}

handle_draw = function(_mx, _my, clicked) {
    
    var old_mx = mouse.x - canvas_pan_x;
    var old_my = mouse.y - canvas_pan_y;
    var new_mx = _mx - canvas_pan_x;
    var new_my = _my - canvas_pan_y;
    
    canvas_holder_redraw = true;
    
    if (!surface_exists(overlay_surf)) {
        overlay_surf = surface_create(canvas_width, canvas_height);
    }
    
    surface_set_target(overlay_surf);
    
    draw_clear_alpha(c_white, 0);
    
    var done = brushes[$ brush].draw(old_mx, old_my, new_mx, new_my, brush_settings, clicked);
    
    surface_reset_target();
    
    if (!done) {
        return;
    }
    
    if (!surface_exists(canvas_surf)) {
        canvas_restore();
    }
    
    surface_set_target(canvas_surf);
    
    draw_surface(overlay_surf, 0, 0);
    
    surface_reset_target();
}

draw_gui = function() {
    
    var num_cols = array_length(colours);
    var width = 50;
    var height = 50;
    
    var tools = struct_get_names(brushes);
    
    draw_set_alpha(0.5);
    draw_rectangle(0, 0, num_cols * width, height, false);
    draw_set_alpha(1);
    
    for (var i = 0; i < num_cols; i ++) {
        
        var pos = {
            x1: width * i,
            y1: 0,
            x2: width * (i+1),
            y2: height
        };
        
        draw_set_colour(colours[i]);
        draw_rectangle(pos.x1, pos.y1, pos.x2, pos.y2, brush_settings.colour != colours[i]);
        draw_set_colour(c_white);
        
    }
    
    var off = height;
    
    for (var i = 0; i < array_length(tools); i ++) {
        var str = tools[i];
        off += string_height(str);
        
        draw_text(20 * (str == brush), off, str);
    }
    
}