/// Draw the canvas & tool path!

// Draw the canvas!

draw_sprite_tiled(sCheckerboard, 0, 0, 0);

canvas.__ensureSurface();
draw_surface(canvas.__surf, 0, 0);

draw_set_valign(fa_bottom);
draw_text(0, 0, $"{self.canvas.width}x{self.canvas.height}");
draw_set_valign(fa_top);

// Draw current state
fsm.run("draw");
