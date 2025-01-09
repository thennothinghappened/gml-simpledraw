/// Draw the canvas & tool path!

// Draw the canvas!

canvas.__ensureSurface();

shader_set(shdCanvas);
	shader_set_uniform_f_array(shader_get_uniform(shdCanvas, "canvasSize"), [self.canvas.width, self.canvas.height]);
	draw_surface(canvas.__surf, 0, 0);
shader_reset();

draw_set_valign(fa_bottom);
draw_text(0, 0, $"{self.canvas.width}x{self.canvas.height}");
draw_set_valign(fa_top);

// Draw current state
fsm.run("draw");
