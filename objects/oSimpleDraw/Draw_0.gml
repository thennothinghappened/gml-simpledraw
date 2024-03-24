/// Draw the canvas & tool path!

/// Draw the canvas!

draw_sprite_tiled(sCheckerboard, 0, 0, 0);
draw_surface(canvas.__surf, 0, 0);

/// Draw current state
state_process("draw");

/// Draw the brush

draw_set_color(c_grey);
draw_circle(mouse_worldspace[X], mouse_worldspace[Y], 10, true);
draw_set_color(c_white);