

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
    
    resize = function(width, height) {
        self._ensure_exists();
        
        var surf = surface_create(width, height);
        surface_copy_part(surf, 0, 0, self.surf, 0, 0,)
    }
    
}