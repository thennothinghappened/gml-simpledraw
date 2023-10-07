function Node() constructor {
    
    self.children = [];
    
    /// @param {Constraints} constraints
    measure = function(constraints) {
        
    }
    
    /// @param {Node} child
    add_child = function(child) {
        array_push(self.children, child);
        return self;
    }
    
    debug_render_node_tree = function(depth = 0) {
        var str = "\n" + string_repeat(" ", depth);
        str += $"|- {self}";
        
        for (var i = 0; i < array_length(self.children); i ++) {
            str += self.children[i].debug_render_node_tree(depth + 1);
        }
        
        return str;
    }
    
    toString = function() {
        return instanceof(self);
    }
    
}

/// @param {number} min_width
/// @param {number} min_height
/// @param {number} max_width
/// @param {number} max_height
function Constraints(min_width, min_height, max_width, max_height) constructor {
    
    assert(max_width >= min_width, $"Max width {max_width} must be >= to {min_width}");
    assert(min_height >= min_height, $"Max height {max_height} must be >= to {min_height}");
    
    self.min_width      = min_width;
    self.min_height     = min_height;
    self.max_width      = max_width;
    self.max_height     = max_height;
    
    self.bounded_width  = (self.max_width != infinity);
    self.bounded_height = (self.max_height != infinity);
    
    self.fixed_width    = (self.min_width != self.max_width);
    self.fixed_height   = (self.min_height != self.max_height);
    
    
    
}

/// @param {number} width
/// @param {number} height
function constraints_fixed(width, height) {
    return new Constraints(width, height, width, height);
}