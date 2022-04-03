program tsunami
    !
    ! First implementation: linear advection equation
    ! dh/dt + u * dh/dx = 0
    !
    implicit none
    ! Variable declarations
    ! Iterators
    integer :: i ! Grid position
    integer :: n ! Time steps elapsed
    integer, parameter :: grid_size = 100
    integer, parameter :: num_time_steps = 100
    real, parameter :: dt = 1.0 ! time step [s]
    real, parameter :: dx = 1.0 ! grid spacing [m]
    real, parameter :: c = 1.0 ! phase speed [m/s]
    ! Arrays to hold water height [m] and its finite differences [m] at each
    ! grid position
    real, dimension(grid_size) :: h, dh
    ! Initial conditions
    integer, parameter :: icenter = 25 ! index of center of the wave
    real, parameter :: decay = 0.02 ! decay factor of shape
    ! End variable declarations

    ! Initialize water height
    do i = 1, grid_size
        h(i) = exp(-decay * (i - icenter)**2)
    end do

    ! Print initial water height values to the terminal
    print *, 0, h

    time_loop: do n = 1, num_time_steps
        ! Periodic boundary condition
        dh(1) = h(1) - h(grid_size)
        ! Finite differences in space
        do concurrent (i = 2:grid_size)
            dh(i) = h(i) - h(i-1)
        end do
        ! Integrates the solution
        do concurrent (i = 1:grid_size)
            h(i) = h(i) - c * dh(i) / dx * dt
        end do
        ! Print current values to the terminal
        print *, n, h
    end do time_loop

end program tsunami
