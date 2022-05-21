program tsunami
    !
    ! First implementation: linear advection equation
    ! dh/dt + u * dh/dx = 0
    !
    use iso_fortran_env, only: int32, real32
    use mod_diff, only: diff
    use mod_initial, only: set_gaussian
    use mod_io, only: write_hdf5
    implicit none
    ! Variable declarations
    ! Iterators
    integer(int32) :: x ! Grid position
    integer(int32) :: t ! Time steps elapsed
    integer(int32), parameter :: grid_size = 100
    integer(int32), parameter :: num_time_steps = 100
    real(real32), parameter :: dt = 1.0 ! time step [s]
    real(real32), parameter :: dx = 1.0 ! grid spacing [m]
    real(real32), parameter :: c = 1.0 ! phase speed [m/s]
    ! Array h(x,t) to hold water height [m] at every time step
    real(real32) :: h(grid_size, 0:num_time_steps)
    ! Array dh(x) to hold finite differences in water height, for a fixed time,
    ! [m] at each grid position
    real(real32) :: dh(grid_size)
    ! Initial conditions
    integer(int32), parameter :: icenter = 25 ! index of center of the wave
    real(real32), parameter :: decay = 0.02 ! decay factor of shape
    ! End variable declarations

    ! Initialize water height
    call set_gaussian(h(:,0), icenter, decay)
    ! Solve iteratively in t
    time_loop: do t = 1, num_time_steps
        dh = diff(h(:,t-1))
        h(:, t) = h(:, t - 1) - c * dh / dx * dt
    end do time_loop
    ! Save data to file
    call write_hdf5(h)

end program tsunami
