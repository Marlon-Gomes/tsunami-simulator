# FTsunami

A tsunami simulator written in Fortran. Waves are assumed to be subject to the shallow-water, or Saint-Venant, equations (SWE):
<!-- LaTeX in github markdown. "%2B" is the symbol for addition -->
<p align="center">
<img src="https://render.githubusercontent.com/render/math?math={
    \frac{\partial \mathbf{u}}{\partial t} %2B \mathbf{u} \cdot \nabla \mathbf{u} = -g\nabla h
    }#gh-light-mode-only">
<img src="https://render.githubusercontent.com/render/math?math={
    \color{white}
    \frac{\partial \mathbf{u}}{\partial t} + \mathbf{u} \cdot \nabla \mathbf{u} = -g\nabla h
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
