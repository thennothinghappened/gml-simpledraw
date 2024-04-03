/// Draw the canvas & tool path!

/// Draw the canvas!

draw_sprite_tiled(sCheckerboard, 0, 0, 0);

canvas.__ensure_surface();
draw_surface(canvas.__surf, 0, 0);

/// Draw current state
state_process("draw");
