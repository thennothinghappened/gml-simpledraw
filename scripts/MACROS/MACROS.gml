
#macro X 0
#macro Y 1
#macro Z 2

/// Returns whether we're running on GMRT or not
/// This function relies on a minor change in how global works in the new runtime.
/// 
/// @returns {Bool} Whether we're on GMRT.
function __isGMRT() {
	
	// In GMRT the root context (`other` in a script) has `global` as a child
	// where in the current runtime global is a negative sentinel value.
	static val = variable_instance_exists(other, "global");
	return val;
	
}
__isGMRT();

#macro IsGMRT __isGMRT()

#macro FEATHERHINT if (false)

#macro IsWindows (os_type == os_windows)
#macro IsWindowsCR (IsWindows && !IsGMRT)

/**
 * Pointless function that fixes Feather's confusion with FSM function binding.
 */
function ident(func) {
	return method(self, func);
}
