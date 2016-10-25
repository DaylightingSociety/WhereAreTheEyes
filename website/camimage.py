#!/usr/local/bin/python2

# Normally we'd use "/usr/bin/env python2", but /usr/local/bin won't be
# in the webuser's PATH.

import sys
import numpy
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap

lats = []
lons = []

if( len(sys.argv) != 3 ):
	print "USAGE: " + sys.argv[0] + " <input.csv> <output.png>"
	sys.exit(1)

f = open(sys.argv[1])
# Skip first line, which is "latitude,longitude"
for line in f.read().split("\n")[1:]:
	if( len(line) > 0 ):
		(lat, lon) = line.split(",")
		lats += [float(lat)]
		lons += [float(lon)]
    
# Matplotlib wants numpy arrays
lats = numpy.array(lats)
lons = numpy.array(lons)

def render():
    # Dimensions in inches
    plt.figure(figsize=(6,4), tight_layout=True)

    map = Basemap(projection="robin", lat_0 = 25, lon_0 = 0)
    map.drawcoastlines(linewidth=.5)
    map.drawcountries(linewidth=.5)
    map.fillcontinents(color="darkgrey", lake_color="whitesmoke", zorder=1)
    map.drawmapboundary(fill_color="whitesmoke",zorder=0)
    
    # Draw the points
    lon, lat = map(lons, lats)

    map.scatter(lon, lat, s=5, zorder=2, color="red")
    plt.title("Current Known Cameras")
    plt.savefig(sys.argv[2], transparent=True)
    plt.close()

render()
