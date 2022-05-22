program tsunami
    !
    ! First implementation: linear advection equation
    ! dh/dt + u * dh/dx = 0
    !
    use iso_fortran_env, only: int32, real64
    use mod_diff, only: diff => diff_centered
    use mod_initial, only: set_gaussian
    use mod_io, only: write_hdf5
    implicit none
    ! Variable declarations
    ! Iterators
    integer(int32) :: x ! Grid position
    integer(int32) :: t ! Time steps elapsed
    integer(int32), parameter :: grid_size = 100
    integer(int32), parameter :: num_time_steps = 3000
    real(real64), parameter :: dt = 0.01 ! time step [s]
    real(real64), parameter :: dx = 1 ! grid spacing [m]
    real(real64), parameter :: g = 9.8 ! gravitational acceleration [m/s^2]
    real(real64), parameter :: depth = 10 ! base water depth [m]
    ! Array h(x,t) to hold water height [m] at every time step
    real(real64) :: h(grid_size, 0:num_time_steps)
    ! Array u(x,t) to hold water flow velocity [m/s] at every time step
    real(real64) :: u(grid_size, 0:num_time_steps) = 0
    ! Array dh(x) to hold finite differences in water height [m], for a fixed 
    ! time, at each grid position
    real(real64) :: dh(grid_size)
    ! Array du(x) to hold finite differences in water flow velocity, for a 
    ! fixed time, at each grid position
    real(real64) :: du(grid_size)
    ! Initial conditions
    integer(int32), parameter :: icenter = 25 ! index of center of the wave
    real(real64), parameter :: decay = 0.02 ! decay factor of shape
    ! End variable declarations

    ! Initialize water height
    call set_gaussian(h(:,0), icenter, decay)
    ! Solve iteratively in t
    time_loop: do t = 1, num_time_steps
        ! Compute space-centered finite differences
        dh = diff(h(:, t - 1))
        du = diff(u(:, t - 1))
        u(:, t) = u(:, t - 1) - (u(:,t-1) * du + g * dh) / dx * dt
        h(:, t) = h(:, t - 1) - diff(u(:, t - 1) * (h(:, t - 1) + depth))/ dx * dt
    end do time_loop
    ! Save data to file
    call write_hdf5(h)

end program tsunami
