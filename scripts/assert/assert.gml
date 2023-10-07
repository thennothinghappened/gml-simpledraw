/// @param {bool} cond
/// @param {string} msg
function assert(cond, msg) {
    if (!cond) {
        throw msg;
    }
}