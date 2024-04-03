
/// Create a shallow copy of an array.
/// @param {Array} array
function array_clone(array) {
    return array_map(array, function(element) {
        return element;
    });
}
