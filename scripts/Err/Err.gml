/// Generic Error type
/// @param {String} msg Readable error message
/// @param {Struct.Err|Struct.Exception|undefined} [cause] Cause of the error
function Err(msg, cause = undefined) constructor {
    
    self.msg = _msg;
    self.cause = _cause;
    self.callstack = debug_get_callstack();
    
    array_delete(callstack, 0, 1);
    
    static toString = function() {
        return $"Error: {msg}\n at {string_join_ext("\n at ", callstack)}" + (cause == undefined ? "" : $"\nCause: {cause}") + "\n";
    }
    
}
