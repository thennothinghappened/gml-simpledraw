function Surface() : TreeWidget() constructor {
    
    draw = function(w, h) {
        var num_children = array_length(self.children);
        
        for (var i = 0; i < num_children; i ++) {
            var child = self.children[i];
            
            child.draw(w, h);
            draw_surface(child.surf, 0, 0);
        }
    }
    
}