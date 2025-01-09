
/**
 * Central start-up script.
 */
function initialise() {
	
	prefs.init();
	window.init();
	window.fpsForeground = prefs.data.frameRate;
	
	draw_set_font(fntMain);
	
	font_enable_effects(fntMain, true, {
		outlineEnable: true,
		outlineDistance: 1,
		outlineColour: c_black
	});
	
}

gml_pragma("global", "initialise();");
