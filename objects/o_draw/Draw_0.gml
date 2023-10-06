
var _window_width = window_get_width();
var _window_height = window_get_height();

if (window_width != _window_width || window_height != _window_height) {
    on_window_resize(_window_width, _window_height);
}



#endregion