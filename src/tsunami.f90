program tsunami
    !
    ! First implementation: linear advection equation
    ! dh/dt + u * dh/dx = 0
    !
    use io
    implicit none
    ! Variable declarations
    ! Iterators
    integer :: x ! Grid position
    integer :: t ! Time steps elapsed
    integer, parameter :: grid_size = 100
    integer, parameter :: num_time_steps = 100
    real, parameter :: dt = 1.0 ! time step [s]
    real, parameter :: dx = 1.0 ! grid spacing [m]
    real, parameter :: c = 1.0 ! phase speed [m/s]
    ! Array h(x,t) to hold water height [m] at every time step
    real :: h(grid_size, 0:num_time_steps)
    ! Array dh(x) to hold finite differences in water height, for a fixed time,
    ! [m] at each grid position
    real :: dh(grid_size)
    ! Initial conditions
    integer, parameter :: icenter = 25 ! index of center of the wave
    real, parameter :: decay = 0.02 ! decay factor of shape
    ! End variable declarations

    ! Initialize water height
    do x = 1, grid_size
        h(x,0) = exp(-decay * (x - icenter)**2)
    end do

    ! Print initial water height values to the terminal
    ! print *, 0, h

    time_loop: do t = 1, num_time_steps
        ! Periodic boundary condition
        dh(1) = h(1, t - 1) - h(grid_size, t - 1)
        ! Finite differences in space
        do concurrent (x = 2:grid_size)
            dh(x) = h(x, t - 1) - h(x - 1, t - 1)
        end do
        ! Integrates the solution
        do concurrent (x = 1:grid_size)
            h(x, t) = h(x, t - 1) - c * dh(x) / dx * dt
        end do
    end do time_loop
    ! Save data to file
    call write_hdf5(h)

end program tsunami
