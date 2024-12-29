
/**
 * Euclidean `mod`, which effectively wraps numbers in the positive range.
 * 
 * @pure
 * @param {Real} a
 * @param {Real} b
 * @returns {Real}
 */
function eucmod(a, b) {
	return a - b * floor(a / b);
}
