
application_surface_enable(false);
application_surface_draw_enable(false);

window_width = window_get_width();
window_height = window_get_height();

var node = new Node()
    .add_child(
        new Node()
            .add_child(new Node())
            .add_child(new Node()
                .add_child(new Node())))
    .add_child(new Node());


show_debug_message(node.debug_render_node_tree());

/// @param {number} new_width
/// @param {number} new_height
on_window_resize = function(new_width, new_height) {
    window_width = new_width;
    window_height = new_height;
    
    
}
