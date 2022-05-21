module mod_diff
    use iso_fortran_env, only: int32, real32
    implicit none
    private
    public :: diff
    
contains
    pure function diff(x) result(dx)
        ! Calculates 1D finite differences with periodic boundary condition
        real(real32), intent(in) :: x(:)
        real(real32) :: dx(size(x))
        integer(int32) :: i
        i = size(x)
        dx(1) = x(1) - x(i)
        dx(2:i) = x(2:i) - x(1:i-1)
    end function diff
    
end module mod_diff