add_library(io STATIC mod_io.f90)
# set module path to LIB_DIR/mod
set_target_properties(io PROPERTIES
    Fortran_MODULE_DIRECTORY ${CMAKE_Fortran_MODULE_DIRECTORY})

target_include_directories(io
    PRIVATE ${HDF5_INCLUDE_DIRS}
    PRIVATE ${HDF5_Fortran_INCLUDE_DIRS})
