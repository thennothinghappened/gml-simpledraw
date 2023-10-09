
mouse_state_load();

if (gui_check_input()) {
	window_set_cursor(cr_default);
	return;
}

window_set_cursor(cr_none);
handlers[state]();