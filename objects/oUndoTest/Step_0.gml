/**
 * @desc
 */

self.ensureCanvas();

if (keyboard_check(vk_control) && keyboard_check_pressed(ord("Z"))) {
	self.undo();
}

if (keyboard_check_pressed(vk_space)) {
	self.appendCommand(self.rect(
		random(self.width), 
		random(self.height), 
		random(self.width), 
		random(self.height), 
		make_color_hsv(irandom(255), 255, 255)
	));
}
