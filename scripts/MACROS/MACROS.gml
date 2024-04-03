
#macro X 0
#macro Y 1
#macro Z 2

global.__is_gmrt = struct_exists({ _global: other }._global, "GPU")
#macro IS_GMRT global.__is_gmrt
