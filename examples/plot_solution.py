import h5py as h5
import matplotlib as mpl
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation, ImageMagickWriter
import numpy as np
# Read data from HFD5 file
with h5.File('../build/data/tsunami.h5', 'r') as hf:
    data = np.array(hf.get('height'))

def my_func():
    # Set up matplotlib parameters
    mpl.rcParams['font.family'] = 'Avenir'
    mpl.rcParams['font.size'] = 18
    mpl.rcParams['axes.linewidth'] = 2
    mpl.rcParams['axes.spines.top'] = False
    mpl.rcParams['axes.spines.right'] = False
    # Create figure and axis
    fig = plt.figure(figsize=(9, 6))
    ax = fig.add_subplot(autoscale_on=False, xlim=(0, 100.), ylim=(0, 1.))
    ax.grid()
    # Create variable reference to plot
    x = np.arange(1,101)
    swe_line, = ax.plot(x, data[0,:], linewidth=2.5)
    # Time-stamp values
    time = np.arange(101)
    # Add text annotation and create variable reference
    temp = ax.text(1, 1, '', ha='right', va='top', fontsize=24,
        transform = ax.transAxes)

    # Set axes labels
    ax.set_xlabel('Position (m)')
    ax.set_ylabel('Height (m)')
    # Set axes limits
    ax.set_xlim(0,100)
    ax.set_ylim(0,1)
    # Animation function
    def animate(i):
        y = data[i,:]
        swe_line.set_data(x, y)
        temp.set_text(str(int(time[i])) + ' s')

    # Create animation
    ani = FuncAnimation(fig, animate, frames = len(time), interval = 200,
        repeat=False)

    # Ensure the entire plot is visible
    fig.tight_layout()

    # Save and show animation
    ani.save('./AnimatedPlot.gif',
        writer=ImageMagickWriter( extra_args=['-loop', '1']))
    plt.show()

if __name__=='__main__':
    my_func()
