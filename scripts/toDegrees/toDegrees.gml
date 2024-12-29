
/**
* Convert from radians to degrees.
* 
* @pure
* @param {Real} radians
* @returns {Real}
*/
function toDegrees(radians) {
	gml_pragma("forceinline");
	return 180 * (radians / pi);
}
