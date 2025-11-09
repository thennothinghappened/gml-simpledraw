
function EyedropperTool() : Tool() constructor {
	static name = "Eye Dropper";
	static desc = "Pick a colour from the canvas.";
	static icon = sToolEyedropper;
	
	colour = ts.colour;
	active = false;
	
	static beginStroke = function() {
		active = true;
	}
	
	static updateStroke = function(mousePos, canvas) {
		colour = surface_getpixel(canvas.__surf, floor(mousePos[X]), floor(mousePos[Y]));
	}
	
	static endStroke = function() {
		ts.colour = colour;
		active = false;
	}
	
	static draw = function(mousePos) {
		var drawPos = array_map(mousePos, floor);
		draw_rectangle(drawPos[X], drawPos[Y], drawPos[X] + 1, drawPos[Y] + 1, true);
		
		if (active) {
			draw_rectangle_colour(mousePos[X] - 20, mousePos[Y] - 10, mousePos[X] + 20, mousePos[Y] - 50, colour, colour, colour, colour, false);
		}
	}
}
