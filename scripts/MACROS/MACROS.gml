
#macro X 0
#macro Y 1
#macro Z 2

/// Returns whether we're running on GMRT or not
/// This function relies on a minor change in how global works in the new runtime.
/// 
/// @returns {Bool} Whether we're on GMRT.
function __is_gmrt() {
	
	// In GMRT the root context (`other` in a script) has `global` as a child
	// where in the current runtime global is a negative sentinel value.
	static val = variable_instance_exists(other, "global");
	return val;
	
}
__is_gmrt();

#macro IS_GMRT __is_gmrt()
