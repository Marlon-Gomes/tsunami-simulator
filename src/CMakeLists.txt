add_subdirectory(diff)
add_subdirectory(initial)
add_subdirectory(io)

add_executable(tsunami tsunami.f90)

target_link_libraries(tsunami
    PRIVATE diff
    PRIVATE initial
    PRIVATE io
    PRIVATE ${HDF5_LIBRARIES}
    PRIVATE ${HDF5_Fortran_LIBRARIES}
)
