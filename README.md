# Tsunami Simulator

<!-- PROJECT SHIELDS -->
[![CMake](https://github.com/Marlon-Gomes/tsunami-simulator/actions/workflows/cmake.yml/badge.svg)](https://github.com/Marlon-Gomes/tsunami-simulator/actions/workflows/cmake.yml)

<!-- ABOUT THE PROJECT -->
## About The Project

A tsunami simulator written in Fortran. Simulates the motion of an 
incompressible fluid flowing through a constant-width, rectangular channel,
under the assumption of no shear between the fluid and the channel's boundary.

The fluid's motion is modeled by the shallow-water equations (Saint-Venant 
equations, or SWE, for short):
<!-- LaTeX in github markdown. "%2B" is the symbol for addition -->
1. Conservation of mass
<p align="center">
<img 
     src="https://render.githubusercontent.com/render/math?math={\frac{\partial \mathbf{u}}{\partial t} %2B \mathbf{u} \cdot \nabla \mathbf{u} = -g\nabla h}#gh-light-mode-only" 
     alt="Conservation of mass equation (light screen mode)">
<img 
     src="https://render.githubusercontent.com/render/math?math={\color{white}\frac{\partial \mathbf{u}}{\partial t} %2B \mathbf{u} \cdot \nabla \mathbf{u} = -g\nabla h}#gh-dark-mode-only" 
     alt="Conservation of mass equation (dark screen mode)">
</p>

2. Conservation of linear momentum
<p align="center">
<img 
     src="https://render.githubusercontent.com/render/math?math={\frac{\partial h}{\partial t} = -\mathrm{div}((H %2B h)\mathbf{u})}#gh-light-mode-only"
     alt="Conservation of linear momentum equation (light screen mode)">
<img 
     src="https://render.githubusercontent.com/render/math?math={\color{white}\frac{\partial h}{\partial t} = -\mathrm{div}((H %2B h)\mathbf{u})}#gh-dark-mode-only" 
     alt="Conservation of linear momentum equation (dark screen mode)">
</p>

where,
- H is the unperturbed fluid depth
- h is the fluid elevation relative to the unperturbed surface level
- g is the gravitational acceleration, assumed constant
- **u** is the 2D velocity vector

## Pre-requisites
- Cmake, the build system generator.
- A Fortran compiler (tested on GNU Fortran 11.3.0).
- HDF5 1.12.2

Assuming you have all installed in the default locations, CMake will find the Fortran compiler and the required HDF5 libraries for you.

## Usage 

A suite of tools was provided to facilitate usage. Assuming you have all pre-requisites, running 
```sh
cd tools
./configure.sh
./build.sh
```
will create a build folder and compile an executable called ```tsunami``` to ```./build/bin/```. Running the executable (use ```./run.sh``` from the ```tools``` folder for convenience) will output a dataset called ```tsunami.h5``` to the folder ```./bin/data/```. This dataset contains the solution to the Saint-Venant equation with pre-specified initial conditions, which can be visualized below.

![Project animation][animation]

The above animation was produced with the python script ```plot_solutions.py```, located at the ```examples``` folder. Dependencies for the python script can be found at ```environment.yml```.

## Known issues

The finite differencing scheme used in this simulation is numerically unstable.
The non-linear character of the SWE equations only accentuates this issue. 

With the current set of parameters (time-delta, grid size, fluid depth, and 
initial conditions), the simulation is known to run for about 31s before 
producing NaNs.

## Acknowledgements

This project is inspired by Milan Curcic's book *Modern Fortran: Building Efficient Parallel Applications*.
<!-- Markdown links -->
[animation]: /docs/animations/AnimatedPlot.gif
