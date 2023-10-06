

function Canvas(width, height) constructor {
    
    self.width = width;
    self.height = height;
    
    self.surf = surface_create(self.width, self.height);
    self.buf = buffer_create(self.width * self.height * 4, buffer_fixed, 1);
    
    _ensure_exists = function() {
        if (surface_exists(self.surf)) {
            return;
        }
        
        self.surf = surface_create(self.width, self.height);
        buffer_set_surface(self.buf, self.surf, 0);
    }
    
    /// @param {number} width
    /// @param {number} height
    /// @param {Placement} vertical
    /// @param {Placement} horizontal
    resize = function(width, height, vertical, horizontal) {
        self._ensure_exists();
        
        var surf = surface_create(width, height);
        var pos = placement_get_fancy(vertical, horizontal, new Size(self.width, self.height), new Size(width, height));
        
        show_debug_message(pos);
        
        surface_copy(surf, pos.x.start, pos.y.start, self.surf);
        surface_free(self.surf);
        
        self.surf = surf;
    }
    
}