function GuiElement(rel_x, rel_y, rel_w, rel_h, children = []) constructor {
	
	self.rel_x = rel_x;
	self.rel_y = rel_y;
	
	self.rel_w = rel_w;
	self.rel_h = rel_h;
	
	/// whether we can be focused
	self.focusable = false;
	
	self.children = children;
	
	draw = function(x, y, w, h) {
		draw_own_content(x, y, w, h);
		
		for (var i = 0; i < array_length(self.children); i ++) {
			var child = self.children[i];
			var pos = get_child_pos(child, x, y, w, h);
			
			child.draw(pos.x, pos.y, pos.w, pos.h);
		}
	}
	
	get_child_pos = function(child, x, y, w, h) {
		var child_x = x + w * child.rel_x;
		var child_y = y + h * child.rel_y;
			
		var child_w = w * child.rel_w;
		var child_h = h * child.rel_h;
		
		return {
			x: child_x,
			y: child_y,
			w: child_w,
			h: child_h
		};
	}
	
	draw_own_content = function(x, y, w, h) {
		
	}
	
	/// get the focused element 
	get_focused = function(mouse_x, mouse_y, x, y, w, h) {
		for (var i = 0; i < array_length(self.children); i ++) {
			var child = self.children[i];
			var pos = get_child_pos(child, x, y, w, h);
			
			if (point_in_rectangle(mouse_x, mouse_y, pos.x, pos.y, pos.x + pos.w, pos.y + pos.h)) {
				if (child.focusable) {
					return child.get_focused(mouse_x, mouse_y, pos.x, pos.y, pos.w, pos.h);
				}
			}
		}
		
		if (focusable) {
			return self;
		}
		
		return undefined;
	}
	
	/// called on hover start and end
	on_hover = function(state) {
		return false;
	}
	
	/// called on click start and end
	on_click = function(state) {
		return false;
	}
	
}

function GuiText(rel_x, rel_y, rel_w, rel_h, str) : GuiElement(rel_x, rel_y, rel_w, rel_h, []) constructor {
	
	self.str = str;
	
	draw_own_content = function(x, y, w, h) {
		draw_text(x, y, self.str);
	}
	
	update_str = function(str) {
		o_draw.gui_redraw = true;
		self.str = str;
	}
}

function GuiRect(rel_x, rel_y, rel_w, rel_h, children, col, alpha) : GuiElement(rel_x, rel_y, rel_w, rel_h, children) constructor {
	
	self.col = col;
	self.alpha = alpha;
	
	draw_own_content = function(x, y, w, h) {
		draw_set_colour(self.col);
		draw_set_alpha(self.alpha);
		
		draw_rectangle(x, y, x + w, y + h, false);
		
		draw_set_color(c_white);
		draw_set_alpha(1);
	}
	
	update_col = function(col, alpha) {
		self.col = col;
		self.alpha = alpha;
		
		o_draw.gui_redraw = true;
	}
	
}

function GuiButton(rel_x, rel_y, rel_w, rel_h, children, cb) : GuiElement(rel_x, rel_y, rel_w, rel_h, children) constructor {
	
	self.focusable = true;
	self.hovered = false;
	self.clicked = false;
	
	self.cb = cb;
	
	draw_own_content = function(x, y, w, h) {
		draw_rectangle(x, y, x + w, y + h, !self.hovered);
	}
	
	get_focused = function() {
		return self;
	}
	
	on_hover = function(state) {
		
		if (state != self.hovered) {
			o_draw.gui_redraw = true;
		}
		
		self.hovered = state;
		
		return true;
	}
	
	on_click = function(state) {
		self.clicked = state;
		
		if (!state) {
			self.cb();
		}
		
		return true;
	}
	
}