function Text(str) : Widget() constructor {
    
    self.str = str;
    
    draw = function(w, h) {
        draw_text(0, 0, self.str);
    }
    
    update_text = function(str) {
        self.str = str;
        update();
    }
    
}