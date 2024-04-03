
#macro X 0
#macro Y 1
#macro Z 2

global.__is_gmrt = struct_exists(global, "GPU");
#macro IS_GMRT global.__is_gmrt
