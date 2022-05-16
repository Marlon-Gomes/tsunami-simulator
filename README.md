# FTsunami

<!-- PROJECT SHIELDS -->
[![CMake](https://github.com/Marlon-Gomes/ftsunami/actions/workflows/cmake.yml/badge.svg)](https://github.com/Marlon-Gomes/ftsunami/actions/workflows/cmake.yml)

<!-- ABOUT THE PROJECT -->
## About The Project

A tsunami simulator written in Fortran. Waves are assumed to be subject to the shallow-water, or Saint-Venant, equations (SWE):
<!-- LaTeX in github markdown. "%2B" is the symbol for addition -->
<p align="center">
<img src="https://render.githubusercontent.com/render/math?math={
    \frac{\partial \mathbf{u}}{\partial t} %2B \mathbf{u} \cdot \nabla \mathbf{u} = -g\nabla h
    }#gh-light-mode-only">
<img src="https://render.githubusercontent.com/render/math?math={
    \color{white}
    \frac{\partial \mathbf{u}}{\partial t} %2B \mathbf{u} \cdot \nabla \mathbf{u} = -g\nabla h
    }#gh-dark-mode-only">
</p>
<p align="center">
<img src="https://render.githubusercontent.com/render/math?math={
    \frac{\partial h}{\partial t} = -\mathrm{div}\mathbf{u}(H %2B h)
    }#gh-light-mode-only">
<img src="https://render.githubusercontent.com/render/math?math={
    \color{white}
    \frac{\partial h}{\partial t} = -\mathrm{div}\mathbf{u}(H %2B h)
    }#gh-dark-mode-only">
</p>

where,
- H is the unperturbed water depth
- h is the water elevation
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
will create a build folder and compile an executable called ```ftsunami``` to ```./build/bin/```. Running the executable (use ```./run.sh``` from the ```tools``` folder for convenience) will output a dataset called ```tsunami.h5``` to the folder ```./bin/data/```. This dataset contains the solution to the Saint-Venant equation with pre-specified initial conditions, which can be visualized below.

![Project animation][animation]

The above animation was produced with the python script ```plot_solutions.py```, located at the ```examples``` folder. Dependencies for the python script can be found at ```environment.yml```.

<!-- Markdown links -->
[animation]: /docs/animations/AnimatedPlot.gif