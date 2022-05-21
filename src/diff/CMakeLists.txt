add_library(diff STATIC mod_diff.f90)
# set module path to LIB_DIR/mod
set_target_properties(diff PROPERTIES
    Fortran_MODULE_DIRECTORY ${CMAKE_Fortran_MODULE_DIRECTORY})