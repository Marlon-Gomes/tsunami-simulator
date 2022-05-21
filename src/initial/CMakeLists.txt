add_library(initial STATIC mod_initial.f90)
# set module path to LIB_DIR/mod
set_target_properties(initial PROPERTIES
    Fortran_MODULE_DIRECTORY ${CMAKE_Fortran_MODULE_DIRECTORY})