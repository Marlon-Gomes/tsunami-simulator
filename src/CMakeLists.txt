add_subdirectory(io)

add_executable(tsunami tsunami.f90)

target_link_libraries(tsunami
    PUBLIC io
    PRIVATE ${HDF5_LIBRARIES}
    PRIVATE ${HDF5_Fortran_LIBRARIES}
    )
