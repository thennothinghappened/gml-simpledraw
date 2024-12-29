
/**
 * Convert from degrees to radians.
 * 
 * @pure
 * @param {Real} degrees
 * @returns {Real}
 */
function toRadians(degrees) {
	gml_pragma("forceinline");
	return (degrees / 180) * pi;
}
