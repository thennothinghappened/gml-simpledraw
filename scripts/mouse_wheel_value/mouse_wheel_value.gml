
/// Get the mouse wheel as up or down.
/// @returns {Real}
function mouse_wheel_value() {

    gml_pragma("forceinline");
    return real(mouse_wheel_down()) - real(mouse_wheel_up());
}