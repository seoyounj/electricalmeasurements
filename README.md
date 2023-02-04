# electricalmeasurements
Matlab files for Professor Porter's lab at Carnegie Mellon University. Used to crunch files from I-V, C-V measurements.

From Fall 2022. 
We use a program to measure I-V and C-V values from a device of interest, mostly (for my project) to study the efficacy of a Schottky diode on a chip. The data exported from this program is very long and annoying to actually use. These programs exist to pull data from the way this program formats outputs and then find relevant data accordingly.

## IV grapher ##
Used to take an input of I-V measurements and a) graph them into a visual display, and b) find the reverse leakage current (which is just the current at the value closest to -1V). 

## dopingconccalc ##
Used to find the doping concentration of a diode, based on an input of C-V measurements. 

## chipheatmapgrapher ##
Currently takes reverse leakage current, doping concentration values and plots as a heatmap by their relative placement on the chip. Used to look for manufacturing issues in our case.
