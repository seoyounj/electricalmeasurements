# electricalmeasurements
Matlab files for Professor Porter's lab at Carnegie Mellon University. Used to crunch files from I-V, C-V measurements usually from EasyExpert.

From Fall 2022-Spring 2023. 
We use a program to measure electrical values from a device of interest, mostly (for my project) to study the efficacy of a Schottky diode on a chip. These programs exist to pull data from EasyExport output formats and then find relevant data accordingly.

## IV cruncher ##
Used to take an input of I-V measurements and output the I-V measurements as an excel file. You can also a) graph them into a visual display, and b) find the reverse leakage current (which is just the current at the value closest to -1V). 

## dopingconccalc ##
Used to find the doping concentration of a diode, based on an input of C-V measurements. 

## VR cruncher ##
Used to take an input of V-R measurements and output the V-R measurements as an excel file. This graphs the V-R measurements based on whether they are in the same set of elements and fits the resistance measurements to a line based on the diode size. 

## chipheatmapgrapher ##
Currently takes reverse leakage current, doping concentration values and plots as a heatmap by their relative placement on the chip. Used to look for manufacturing issues in our case.

