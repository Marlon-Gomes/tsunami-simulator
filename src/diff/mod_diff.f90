module mod_diff
    use iso_fortran_env, only: int32, real64
    implicit none
    private
    public :: diff_centered, diff_upwind
    
contains
    pure function diff_centered(x) result(dx)
        ! Calculates 1D centered finite differences with periodic boundary 
        ! conditions.
        real(real64), intent(in) :: x(:)
        real(real64) :: dx(size(x))
        integer(int32) :: i
        i = size(x)
        dx(1) = x(2) - x(i)
        dx(i) = x(1) - x(i-1)
        dx(2:i-1) = x(3:i) - x(1:i-2)
        dx = 0.5 * dx
end function diff_centered

    pure function diff_upwind(x) result(dx)
        ! Calculates 1D upwind finite diferences with periodic boundary 
        ! conditions.
        real(real64), intent(in) :: x(:)
        real(real64) :: dx(size(x))
        integer(int32) :: i
        i = size(x)
        dx(1) = x(1) - x(i)
        dx(2:i) = x(2:i) - x(1:i-1)
    end function diff_upwind
    
end module mod_diff