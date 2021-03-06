#!/usr/bin/env python3
import h5py as h5
import matplotlib as mpl
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation, ImageMagickWriter
import numpy as np


# Read data from HFD5 file
def read_data():
    with h5.File('../build/data/tsunami.h5', 'r') as hf:
        data = np.array(hf.get('height'))
    return data

def my_func(input_data):
    # Set up matplotlib parameters
    mpl.rcParams['font.family'] = 'Avenir'
    mpl.rcParams['font.size'] = 18
    mpl.rcParams['axes.linewidth'] = 2
    mpl.rcParams['axes.spines.top'] = False
    mpl.rcParams['axes.spines.right'] = False
    # Set y-limits according to water depth and max wave height
    ymin = -10.0
    ymax = 1.2*input_data.max()
    # Set time delta
    dt = 0.01
    # Create figure and axis
    fig = plt.figure(figsize=(9, 6))
    ax = fig.add_subplot(
        autoscale_on=False, 
        xlim=(0, 100.), 
        ylim=(ymin, ymax))
    ax.grid()
    # Create variable reference to plot
    x = np.arange(1, input_data.shape[1] + 1)
    swe_line, = ax.plot(x, input_data[0,:], linewidth=2.5)
    ax.fill_between(x, input_data[0,:], ymin, facecolor='#005476', alpha = 0.9)
    # Time-stamp values
    time = np.arange(input_data.shape[0])*dt
    # Add text annotation and create variable reference
    temp = ax.text(1, 1, '', ha='right', va='top', fontsize=24,
        transform = ax.transAxes)

    # Set axes labels
    ax.set_xlabel('Position (m)')
    ax.set_ylabel('Height (m)')
    # Animation function
    def animate(i):
        y = input_data[i,:]
        swe_line.set_data(x, y)
        ax.collections.clear()
        ax.fill_between(x, y, ymin, facecolor='#005476', alpha = 0.9)
        temp.set_text("{:.2f}".format(time[i]) + ' s')

    # Create animation
    ani = FuncAnimation(fig, animate, frames = np.arange(len(time))[::20], interval = 200,
        repeat=False)

    # Ensure the entire plot is visible
    fig.tight_layout()

    # Save and show animation
    ani.save('./AnimatedPlot.gif',
        writer=ImageMagickWriter( extra_args=['-loop', '1']))
    plt.show()

if __name__=='__main__':
    data = read_data()
    my_func(data)
