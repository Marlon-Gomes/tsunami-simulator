module mod_io
    use hdf5
    use iso_fortran_env, only: real64, int32
    implicit none
    private
    public :: write_hdf5

contains
    subroutine write_hdf5(data)
        !
        ! Declare all variables in private context
        !
        real(real64), dimension(2), intent(in) :: data
        character(len=18), parameter :: file_name = "./data/tsunami.h5"
        character(len=6), parameter :: dset_name = "height"
        integer(HID_T) :: file_id, dspace_id, dset_id
        integer(int32) :: dset_rank = 2
        integer(HSIZE_T), dimension(2) :: dset_dims = (/100,3001/)
        integer(int32) :: error ! Error flag
        ! Initialize the HDF5 Fortran interface
        call h5open_f(error)
        ! Create a new file using default properties
        call h5fcreate_f(file_name, H5F_ACC_TRUNC_F, file_id, error)
        ! Open dataspace
        call h5screate_simple_f(dset_rank, dset_dims, dspace_id, error)
        ! Create dataset
        call h5dcreate_f(file_id, dset_name, H5T_NATIVE_DOUBLE, dspace_id, &
            dset_id, error)
        ! Write to the dataset
        call h5dwrite_f(dset_id, H5T_NATIVE_DOUBLE, data, dset_dims, error)
        ! Close the dataset
        call h5dclose_f(dset_id, error)
        ! Close dataspace
        call h5sclose_f(dspace_id, error)
        ! Close the file
        call h5fclose_f(file_id, error)
        ! Close the HDF5 Fortran interface
        call h5close_f(error)
    end subroutine

end module mod_io
