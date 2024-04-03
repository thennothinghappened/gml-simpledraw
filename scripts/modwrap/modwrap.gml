/// `mod` or `%` but works as expected for negative numbers.
/// @param {Real} a
/// @param {Real} b
function modwrap(a, b) {
	return a - b * floor(a / b);
}
