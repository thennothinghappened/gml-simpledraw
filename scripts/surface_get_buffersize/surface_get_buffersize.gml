
/// Get the size of a given surface in memory.
/// @param {Real} width
/// @param {Real} height
function surface_get_buffersize(width, height) {
    gml_pragma("forceinline");
    return width * height * buffer_sizeof(buffer_u8) * 4;
}
