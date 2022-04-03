cmake_minimum_required(VERSION 3.3)
project(ftsunami
    LANGUAGES Fortran)

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_Fortran_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/mod)

enable_language(C)      # For HDF5
find_package(HDF5 COMPONENTS C Fortran REQUIRED)

add_subdirectory(src)
