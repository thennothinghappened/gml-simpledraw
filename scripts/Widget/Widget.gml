function Widget() constructor {
    
    self.surf = surface_create(1, 1);
    self.has_update = true;
    self.on_update = function() {  };
    
    _draw_setup = function(w, h) {
        if (!surface_exists(self.surf)) {
            self.surf = surface_create(w, h);
            self.has_update = true;
            
            return;
        }
        
        if (surface_get_width(self.surf) != w || surface_get_height(self.surf) != h) {
            self.surf = surface_create(w, h);
            self.has_update = true;
            
            return;
        }
    }
    
    draw_content = function(w, h) {
        
        _draw_setup(w, h);
        
        if (!self.has_update) {
            return;
        }
        
        var tg = surface_get_target();
        
        if (surface_exists(tg)) {
            surface_reset_target();
        }
        
        surface_set_target(self.surf);
        
        draw(w, h);
        
        surface_reset_target();
        
        if (surface_exists(tg)) {
            surface_set_target(tg);
        }
        
        self.has_update = false;
        
    }
    
    draw = function(w, h) { return; }
    
    find_focused = function(x, y, w, h) {
        return undefined;
    }
    
    update = function() {
        self.has_update = true;
        on_update();
    }
    
}

function TreeWidget() : Widget() constructor {
    
    self.children = [];
    
    child_add = function(child) {
        
        child.on_update = self.update;
        
        array_push(self.children, child);
        self.has_update = true;
        
        return self;
    }
    
}